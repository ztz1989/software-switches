-- This test does the following:
-- 	1. Execute ARP so that the devices exchange MAC-addresses
--	2. Send UDP packets from NIC 1 to NIC 2
-- 	3. Read the statistics from the recieving device
--
-- This script demonstrates how to access device specific statistics ("normal" stats and xstats) via DPDK

local mg     = require "moongen"
local memory = require "memory"
local device = require "device"
local ts     = require "timestamping"
local filter = require "filter"
local hist   = require "histogram"
local stats  = require "stats"
local timer  = require "timer"
local arp    = require "proto.arp"
local log    = require "log"

local ffi = require "ffi"

-- set addresses here
local DST_MAC     = "aa:cc:dd:cc:00:01" --nil -- resolved via ARP on GW_IP or DST_IP, can be overriden with a string here
local SRC_IP_BASE = "10.0.0.10"
local DST_IP      = "10.1.0.10"
local SRC_PORT    = 1234
local DST_PORT    = 319

-- answer ARP requests for this IP on the rx port
-- change this if benchmarking something like a NAT device
local RX_IP   = DST_IP
-- used to resolve DST_MAC
local GW_IP   = DST_IP
-- used as source IP to resolve GW_IP to DST_MAC
local ARP_IP  = SRC_IP_BASE

local C = ffi.C

function configure(parser)
	parser:description("Generates UDP traffic and prints out device statistics. Edit the source to modify constants like IPs.")
	parser:argument("txDev", "Device to transmit from."):convert(tonumber)
	parser:argument("rxDev", "Device to receive from."):convert(tonumber)
end

function master(args)
	txDev = device.config{port = args.txDev, rxQueues = 4, txQueues = 4}
	rxDev = device.config{port = args.rxDev, rxQueues = 4, txQueues = 4}
	device.waitForLinks()

	-- max 1kpps timestamping traffic timestamping
	-- rate will be somewhat off for high-latency links at low rates
	--if args.rate > 0 then
		--txDev:getTxQueue(0):setRate(args.rate - (60 + 4) * 8 / 1000)
	--txDev:getTxQueue(0):setRate(2000)	
	--end
	--rxDev:getTxQueue(0).dev:UdpGenericFilter(rxDev:getRxQueue(3))

	mg.startTask("loadSlave", txDev:getTxQueue(0), rxDev, 60)
    --mg.startTask("loadSlave", txDev:getTxQueue(1), rxDev, 60)
	--mg.startTask("receiveSlave", rxDev:getRxQueue(3))
	mg.waitForTasks()
end

local function fillUdpPacket(buf, len)
--[[		buf:getUdpPacket():fill{
		ethSrc = queue,
		ethDst = DST_MAC,
		ip4Src = SRC_IP,
		ip4Dst = DST_IP,
		udpSrc = SRC_PORT,
		udpDst = DST_PORT,
		pktLength = len
	}
]]--
        buf:getEthernetPacket():fill{
            ethDst = "aa:cc:dd:cc:00:01",
            ethType = 0x1234
        }
end

--- Runs on the sending NIC
--- Generates UDP traffic and also fetches the stats
function loadSlave(queue, rxDev, size)

	log:info(green("Starting up: LoadSlave"))


	-- retrieve the number of xstats on the recieving NIC
	-- xstats related C definitions are in device.lua
	local numxstats = 0
    local xstats = ffi.new("struct rte_eth_xstat[?]", numxstats)

	-- because there is no easy function which returns the number of xstats we try to retrieve
	-- the xstats with a zero sized array
	-- if result > numxstats (0 in our case), then result equals the real number of xstats
	local result = C.rte_eth_xstats_get(rxDev.id, xstats, numxstats)
	numxstats = tonumber(result)

	local mempool = memory.createMemPool(function(buf)
		fillUdpPacket(buf, size)
	end)
	local bufs = mempool:bufArray()

	if queue.qid == 0
	then
		txCtr = stats:newDevTxCounter(queue, "plain")
		rxCtr = stats:newDevRxCounter(rxDev, "plain")
	end

	local baseIP = parseIPAddress(SRC_IP_BASE)

	local sizes = {60, 60, 60, 60, 60, 60, 60, 566, 566, 566, 566, 1510}

    local limiter = timer:new(20)

    --local rates = {0.17, 0.84, 1.80, 2.71, 3.30, 2.51, 1.67, 0.84, 0.17}
    local rates = {473, 2366, 4732, 7098, 9464, 7098, 4732, 2366, 473}
    local r = 2
    local rate = rates[1]

	-- send out UDP packets until the user stops the script
	while mg.running() do
		bufs:alloc(size)

        if limiter:expired()
        then
            print("10s expired, reset the TX rate ")
            limiter:reset()
            if r <= #rates
            then rate = rates[r]
            else
                break
            end
            r = r + 1
        end

		queue:setRate(rate)
		for i, buf in ipairs(bufs) do
			--local pkt = buf:getEthernetPacket()
			local newSize = sizes[math.random(#sizes)]
			buf:setSize(newSize)
			--pkt:setLength(newSize)
			--buf:setDelay(10^10 / 8 / (rate * 10^6) - newSize - 24)
		end

		-- UDP checksums are optional, so using just IPv4 checksums would be sufficient here
		bufs:offloadUdpChecksums()
		queue:sendWithDelay(bufs)

		if queue.qid == 0
		then
			txCtr:update()
			rxCtr:update()
		end
	end

	if queue.qid == 0
	then
		txCtr:finalize()
		rxCtr:finalize()
	end
--[[	print("Total Loss Rate: " .. (txCtr.total - rxCtr.total)/txCtr.total)

	local drop = {}
	for i=3, #txCtr.mpps-2
	do
		drop[i-2] = txCtr.mpps[i] - rxCtr.mpps[i]
	end

	print("Avg Drop: " .. stats.average(drop) .. "  stdDev: " .. stats.stdDev(drop))
]]--
end

--- Runs on the recieving NIC
--- Basically tries to fetch a few packets to show some more interesting statistics
function receiveSlave(rxQueue)
	log:info(green("Starting up: ReceiveSlave"))

	local mempool = memory.createMemPool()
	local rxBufs = mempool:bufArray()

	-- this will catch a few packet but also cause out_of_buffer errors to show some stats
	while mg.running() do
		rxQueue:tryRecvIdle(rxBufs, 10)
		rxBufs:freeAll()
	end
end

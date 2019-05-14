local mg     = require "moongen"
local memory = require "memory"
local device = require "device"
local ts     = require "timestamping"
local stats  = require "stats"
local hist   = require "histogram"

local PKT_SIZE	= 60
local ETH_DST	= "11:12:13:14:15:16"

local function getRstFile(...)
	local args = { ... }
	for i, v in ipairs(args) do
		result, count = string.gsub(v, "%-%-result%=", "")
		if (count == 1) then
			return i, result
		end
	end
	return nil, nil
end

function configure(parser)
	parser:description("Generates bidirectional CBR traffic with hardware rate control and measure latencies.")
	parser:argument("dev", "Device to transmit/receive from."):convert(tonumber)
	--parser:argument("dev2", "Device to transmit/receive from."):convert(tonumber)
	parser:option("-r --rate", "Transmit rate in Mbit/s."):default(10000):convert(tonumber)
	parser:option("-f --file", "Filename of the latency histogram."):default("histogram.csv")
end

function master(args)
	local txDev = device.config({port = args.dev, rxQueues = 1, txQueues = 1})
	local rxDev = txDev

	device.waitForLinks()
	txDev:getTxQueue(0):setRate(args.rate)

	mg.startTask("loadSlave", txDev, txDev:getTxQueue(0))
	mg.startTask("recvSlave", rxDev) 
	stats.startStatsTask{dev1}
	mg.waitForTasks()
end

function loadSlave(dev, queue)
	local mem = memory.createMemPool(function(buf)
		buf:getEthernetPacket():fill{
			ethSrc = txDev,
			ethDst = ETH_DST,
			ethType = 0x1234
		}
	end)
	local bufs = mem:bufArray()

	local txCtr = stats:newDevTxCounter("tx_dev", dev, "plain")

	while mg.running() do
		bufs:alloc(PKT_SIZE)
		queue:send(bufs)
		txCtr:update()
	end

	txCtr:finalize()
	print("Total Tx Packets: " .. txCtr.total)
end

function recvSlave(dev)
	local ctr = stats:newDevRxCounter("RX_CTR", dev, "plain")
	local bufs = memory.bufArray()

	while mg.running() do 
    		local rx = dev:getRxQueue(0):tryRecv(bufs, 100)
    		bufs:free(rx)
		ctr:update()
	end

	ctr:finalize()
	print("Total Rx Packets: " .. ctr.total)
end

local mg     = require "moongen"
local ts     = require "timestamping"
local device = require "device"
local hist   = require "histogram"
local memory = require "memory"
local stats  = require "stats"
local timer  = require "timer"
local ffi    = require "ffi"

local PKT_SIZE = 60

local NUM_PKTS = 10^6

function master(txPort, rxPort)
	if not txPort or not rxPort then
		errorf("usage: txPort rxPort")
	end
	local txDev = device.config{port = txPort, rxQueues = 1, txQueues = 1}
	local rxDev = device.config{port = rxPort, rxQueues = 1, txQueues = 1}
	device.waitForLinks()

	mg.startTask("txTimestamper", txDev:getTxQueue(0))
	mg.startTask("rxTimestamper", rxDev:getRxQueue(0))
	mg.waitForTasks()
end

function txTimestamper(queue)
	local mem = memory.createMemPool(function(buf)
		-- just to use the default filter here
		-- you can use whatever packet type you want
		buf:getUdpPtpPacket():fill{
		ethDst = "02:00:00:00:00:00"
		}
	end)
	mg.sleepMillis(1000)
	local bufs = mem:bufArray(1)
	local rateLimit = timer:new(0.000001) -- 1mpps timestamped packets
	local i = 0
	while i < NUM_PKTS and mg.running() do
		bufs:alloc(PKT_SIZE)
		queue:sendWithTimestamp(bufs)
		rateLimit:wait()
		rateLimit:reset()
		i = i + 1
	end
	mg.sleepMillis(500)
	mg.stop()
end

function rxTimestamper(queue)
	local tscFreq = mg.getCyclesFrequency()
	print(tscFreq)
	local bufs = memory.bufArray(64)
	-- use whatever filter appropriate for your packet type
	queue:filterUdpTimestamps()
	local results = {}
	local rxts = {}
	while mg.running() do
		local numPkts = queue:recvWithTimestamps(bufs)
		for i = 1, numPkts do
			local rxTs = bufs[i].udata64
			local txTs = bufs[i]:getSoftwareTxTimestamp()
			results[#results + 1] = tonumber(rxTs - txTs) / tscFreq * 10^9 -- to nanoseconds
			rxts[#rxts + 1] = tonumber(rxTs)
		end
		bufs:free(numPkts)
	end
	local f = io.open("pings.txt", "w+")
	for i, v in ipairs(results) do
		f:write(v/1000 ..' 1'.. "\n")
	end
	f:close()
end

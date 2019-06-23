module(...,package.seeall)

local vhostuser = require("apps.vhost.vhost_user")

local lib = require("core.lib")
local main = require("core.main")

L2Fwd = {}

function L2Fwd.new(conf)
   local o = {}
   return setmetatable(o, { __index = L2Fwd })
end

function L2Fwd:push()
   local input, output = assert(self.input.input), assert(self.output.output)

   while not link.empty(input) do
      link.transmit(output, link.receive(input))
   end
end

local function show_usage(code)
   print(require("program.vm.README_inc"))
   main.exit(code)
end

local function parse_args(args)
   local handlers = {}
   local opts = { duration = 3000 }
   function handlers.h() show_usage(0) end
   function handlers.v()
      opts.verbose = true
   end
   function handlers.D(arg)
      opts.duration = assert(tonumber(arg), "duration must be a number")
   end
   args = lib.dogetopt(args, handlers, "hvD:", { help="h", verbose="v", duration="D"})
   if #args ~= 2 then show_usage(1) end
   return opts, unpack(args)
end

local function select_nic_driver(arg)
   local driver, pciaddr = arg:match("(%a+):([%w:.]+)")
   if driver == "tap" then
      return require("apps.socket.raw").RawSocket, pciaddr
   elseif driver == "virtio" then
      return require("apps.virtio_net.virtio_net").VirtioNet, pciaddr
   else
      return require("apps.intel.intel_app").Intel82599, arg
   end
end

function run(args)
   local opts, pciaddr1, pciaddr2 = parse_args(args)
   local c = config.new()

   local driver1 = select_nic_driver(pciaddr1)
   local driver2 = select_nic_driver(pciaddr2)

   --config.app(c, "nic1", driver1, {pciaddr = pciaddr1})

   config.app(c, "vi1", vhostuser.VhostUser, {socket_path="/tmp/snabb/vhost-user-1"})
   config.app(c, "vi2", vhostuser.VhostUser, {socket_path="/tmp/snabb/vhost-user-2"})

   config.link(c, "vi1.tx -> vi2.rx")

   engine.configure(c)
   if opts.verbose then
      while true do
         engine.main({duration = opts.duration, report = {showlinks=true, showload=true}})
      end
   else
      engine.main({duration = opts.duration, noreport = true})
   end
end

function selftest()
   print("selftest: vm")
   local driver, pciaddr
   driver, pciaddr = select_nic_driver("virtio:0000:00:01.0")
   assert(type(driver) == "table" and pciaddr == "0000:00:01.0")
   driver, pciaddr = select_nic_driver("tap:eth0")
   assert(type(driver) == "table" and pciaddr == "eth0")
   driver, pciaddr = select_nic_driver("0000:00:01.0")
   assert(type(driver) == "table" and pciaddr == "0000:00:01.0")
   print("OK")
end

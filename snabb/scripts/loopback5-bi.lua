module(...,package.seeall)

local vhostuser = require("apps.vhost.vhost_user")

local lib = require("core.lib")
local main = require("core.main")

loopback5 = {}

function loopback5.new(conf)
   local o = {}
   return setmetatable(o, { __index = loopback5 })
end

function loopback5:push()
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

   config.app(c, "nic1", driver1, {pciaddr = pciaddr1})
   config.app(c, "nic2", driver2, {pciaddr = pciaddr2})

   config.app(c, "vi1", vhostuser.VhostUser, {socket_path="/tmp/snabb/vhost-user-1",is_server=false})
   config.app(c, "vi2", vhostuser.VhostUser, {socket_path="/tmp/snabb/vhost-user-2",is_server=false})
   config.app(c, "vi3", vhostuser.VhostUser, {socket_path="/tmp/snabb/vhost-user-3",is_server=false})
   config.app(c, "vi4", vhostuser.VhostUser, {socket_path="/tmp/snabb/vhost-user-4",is_server=false})
   config.app(c, "vi5", vhostuser.VhostUser, {socket_path="/tmp/snabb/vhost-user-5",is_server=false})
   config.app(c, "vi6", vhostuser.VhostUser, {socket_path="/tmp/snabb/vhost-user-6",is_server=false})
   config.app(c, "vi7", vhostuser.VhostUser, {socket_path="/tmp/snabb/vhost-user-7",is_server=false})
   config.app(c, "vi8", vhostuser.VhostUser, {socket_path="/tmp/snabb/vhost-user-8",is_server=false})
   config.app(c, "vi9", vhostuser.VhostUser, {socket_path="/tmp/snabb/vhost-user-9",is_server=false})
   config.app(c, "vi10", vhostuser.VhostUser, {socket_path="/tmp/snabb/vhost-user-10",is_server=false})

   config.link(c, "nic1.tx -> vi1.rx")
   config.link(c, "vi1.tx -> nic1.rx")
   config.link(c, "vi2.tx -> vi3.rx")
   config.link(c, "vi3.tx -> vi2.rx")
   config.link(c, "vi4.tx -> vi5.rx")
   config.link(c, "vi5.tx -> vi4.rx")
   config.link(c, "vi6.tx -> vi7.rx")
   config.link(c, "vi7.tx -> vi6.rx")
   config.link(c, "vi8.tx -> vi9.rx")
   config.link(c, "vi9.tx -> vi8.rx")
   config.link(c, "vi10.tx -> nic2.rx")
   config.link(c, "nic2.tx -> vi10.rx")

   engine.configure(c)
   engine.busywait = true

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

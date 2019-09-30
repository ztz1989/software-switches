package.path = package.path ..";?.lua;test/?.lua;app/?.lua;"

require "Pktgen"
printf("Lua Version      : %s\n", pktgen.info.Lua_Version);
printf("Pktgen Version   : %s\n", pktgen.info.Pktgen_Version);
printf("Pktgen Copyright : %s\n", pktgen.info.Pktgen_Copyright);
printf("Pktgen Authors   : %s\n", pktgen.info.Pktgen_Authors);

--printf("\nHello World!!!!\n");

local seq_table = {         -- entries can be in any order
    ["eth_dst_addr"] = "0011:4455:6677",
    ["eth_src_addr"] = "0011:1234:5678",
    ["ip_dst_addr"] = "10.12.0.1",
    ["ip_src_addr"] = "10.12.0.1/16",   -- the 16 is the size of the mask value
    ["sport"] = 9,          -- Standard port numbers
    ["dport"] = 10,         -- Standard port numbers
    ["ethType"] = "ipv4",   -- ipv4|ipv6|vlan
    ["ipProto"] = "udp",    -- udp|tcp|icmp
    ["vlanid"] = 1,         -- 1 - 4095
    ["pktSize"] = 96,
    ["teid"] = 3,
    ["cos"] = 5,
    ["tos"] = 6
  };
-- seqTable( seq#, portlist, table );
pktgen.seqTable(0, "all", seq_table );
pktgen.set("all", "seq_cnt", 1);
pktgen.set("all", "size", 96);
pktgen.latency("all", "enable");
pktgen.start(0);
pktgen.delay(60000);
pktgen.stop("all");

prints("pktStats", pktgen.pktStats("all"));
pktgen.quit();

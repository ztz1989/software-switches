out	:: ToDPDKDevice(1, NDESC 4096)
IP	:: DirectIPLookup (10.0.0.0/24 0, 0.0.0.0/24 0)

FromDPDKDevice(0, NDESC 4096) -> IP -> out;
IP[1] -> out;

set terminal pdf enhanced color font "Times,11"
set output "latency-loopback.pdf"
	
set style fill solid 1.0 noborder

set xrange [0:160]
set label 2 'Normalized Frequency' at screen 0.01,0.4 rotate by 90

set multiplot layout 3,2  #otitle "Latency ({/Symbol m}s)"

#set size 2,1.5

set datafile separator ","

set logscale y

set yrange [0.0005:1]
#set ytics 

## Group arrows
#set arrow 1 from screen .25, .88 to screen .17, .88 #arrowstyle 1
#set label 1 at screen .26, .88 "Avg: 4.8; Std: 4.6; 99th: 5.6"

#set arrow 2 from screen .25, .85 to screen .20, .78 #arrowstyle 1
#set label 2 at screen .26, .85 "Avg: 7.1; Std: 4.3; 99th: 10.7"

#set arrow 3 from screen .26, .82 to screen .24, .73 #arrowstyle 1
#set label 3 at screen .26, .82 "Avg: 10.7; Std: 7.7; 99th: 19.0"

unset title
#set ylabel "CDF" offset 2

set mxtics
set xlabel "FastClick"
#set xtics format " " 
plot 'fastclick-10.DATA_parsed' u 1:($2/199185) w boxes lc rgb "#cc000000" t "0.10R^{+}" ,\
'fastclick-50.DATA_parsed' u 1:($2/29420)  w boxes lc rgb "#66000000" t "0.50R^{+}" ,\
'fastclick-99.DATA_parsed' u 1:($2/19530) w boxes lc rgb "#21000000" t "0.99R^{+}"

set xlabel "OvS-DPDK"
plot 'ovs-10.DATA_parsed' u 1:($2/25439) w boxes lc rgb "#cc000000" t "0.10R^{+}",\
'ovs-50.DATA_parsed' u 1:($2/425875) w boxes lc rgb "#66000000" t "0.50R^{+}", \
'ovs-99.DATA_parsed' u 1:($2/21173) w boxes lc rgb "#21000000" t "0.99R^{+}"

set xlabel "snabb"
plot 'snabb-10.DATA_parsed' u 1:($2/330284) w boxes lc rgb "#cc000000"  t "0.10R^{+}",\
'snabb-50.DATA_parsed' u 1:($2/129100) w boxes lc rgb "#66000000" t "0.50R^{+}",\
'snabb-99.DATA_parsed' u 1:($2/31095)  w boxes lc rgb "#21000000" t "0.99R^{+}"

set xlabel "BESS"
plot 'bess-10.DATA_parsed' u 1:($2/17115) w boxes lc rgb "#cc000000"  t "0.10R^{+}",\
'bess-50.DATA_parsed' u 1:($2/24279) w boxes lc rgb "#66000000" t "0.50R^{+}",\
'bess-99.DATA_parsed' u 1:($2/18909)  w boxes lc rgb "#21000000" t "0.99R^{+}"

set xlabel "netmap"
plot 'netmap-10.DATA_parsed' u 1:($2/19631) w boxes lc rgb "#cc000000"  t "0.10R^{+}",\
'netmap-50.DATA_parsed' u 1:($2/26880) w boxes lc rgb "#66000000" t "0.50R^{+}",\
'netmap-99.DATA_parsed' u 1:($2/23363)  w boxes lc rgb "#21000000" t "0.99R^{+}"

set xlabel "VPP"
plot 'vpp-10.DATA_parsed' u 1:($2/107895) w boxes lc rgb "#cc000000"  t "0.10R^{+}",\
'vpp-50.DATA_parsed' u 1:($2/91798) w boxes lc rgb "#66000000" t "0.50R^{+}",\
'vpp-99.DATA_parsed' u 1:($2/171548)  w boxes lc rgb "#21000000" t "0.99R^{+}"

#plot 'mix_10-final_NEW.DATA_parsed' w boxes lc rgb "#999999", 'mix_50-final_NEW.DATA_parsed' w boxes lc rgb "#6688CAF0", 'mix_99-final_NEW.DATA_parsed' w boxes lc rgb "#88CAF0"
#plot 'xc_10_NEW.DATA_parsed' w boxes lc rgb "#cc88CAF0" t "XC - 0.10R^{+}" , 'xc_50_NEW.DATA_parsed' w boxes lc rgb "#6688CAF0" t "XC - 0.50R^{+}", 'xc_99_NEW.DATA_parsed' w boxes lc rgb "#88CAF0" t "XC - 0.99R^{+}"
#plot 'ip_10_NEW.DATA_parsed' u 1:2 w boxes lc rgb "#ee009E73" t "IP - 0.10R^{+}", 'ip_50_NEW.DATA_parsed' u 1:2 w boxes lc rgb "#bb009E73" t "IP - 0.50R^{+}", 'ip_99_NEW.DATA_parsed' u 1:2 w boxes lc rgb "#009E73" t "IP - 0.99R^{+}"

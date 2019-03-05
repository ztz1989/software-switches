set terminal pdf enhanced color font "Times,11"
set output "latency_binned.pdf"
	
set style fill solid 1.0 noborder

set xrange [0:30]

set multiplot layout 4,1  title "Latency ({/Symbol m}s)"

#set size 0.1,0.2


set datafile separator ","

set logscale y

set yrange [0.005:1]
#set ytics 

## Group arrows
#set arrow 1 from screen .25, .88 to screen .17, .88 #arrowstyle 1
#set label 1 at screen .26, .88 "Avg: 4.8; Std: 4.6; 99th: 5.6"

#set arrow 2 from screen .25, .85 to screen .20, .78 #arrowstyle 1
#set label 2 at screen .26, .85 "Avg: 7.1; Std: 4.3; 99th: 10.7"

#set arrow 3 from screen .26, .82 to screen .24, .73 #arrowstyle 1
#set label 3 at screen .26, .82 "Avg: 10.7; Std: 7.7; 99th: 19.0"

unset title
set mxtics
set xlabel "Fastclick"
set xtics format " " 
plot 'fastclick-10.DATA_parsed' u 1:($2/277112) w boxes lc rgb "#cc000000" t "0.10R^{+}" ,\
'fastclick-50.DATA_parsed' u 1:($2/277057)  w boxes lc rgb "#66000000" t "0.50R^{+}" ,\
'fastclick-99.DATA_parsed' u 1:($2/117709) w boxes lc rgb "#21000000" t "0.99R^{+}"

set xlabel "OvS-DPDK"
plot 'ovs-10.DATA_parsed' u 1:($2/281623) w boxes lc rgb "#cc000000" t "0.10R^{+}",\
'ovs-50.DATA_parsed' u 1:($2/281872) w boxes lc rgb "#66000000" t "0.50R^{+}", \
'ovs-99.DATA_parsed' u 1:($2/124712) w boxes lc rgb "#21000000" t "0.99R^{+}"

set xlabel "Snabb"
plot 'snabb-10.DATA_parsed' u 1:($2/180336) w boxes lc rgb "#cc000000"  t "0.10R^{+}",\
'snabb-50.DATA_parsed' u 1:($2/275620) w boxes lc rgb "#66000000" t "0.50R^{+}",\
'snabb-99.DATA_parsed' u 1:($2/119704)  w boxes lc rgb "#21000000" t "0.99R^{+}"

set xlabel "Bess"
plot 'bess-10.DATA_parsed' u 1:($2/277377) w boxes lc rgb "#cc000000"  t "0.10R^{+}",\
'bess-50.DATA_parsed' u 1:($2/276861) w boxes lc rgb "#66000000" t "0.50R^{+}",\
'bess-99.DATA_parsed' u 1:($2/113379)  w boxes lc rgb "#21000000" t "0.99R^{+}"

set xlabel "Latency"
#plot 'mix_10-final_NEW.DATA_parsed' w boxes lc rgb "#999999", 'mix_50-final_NEW.DATA_parsed' w boxes lc rgb "#6688CAF0", 'mix_99-final_NEW.DATA_parsed' w boxes lc rgb "#88CAF0"
#plot 'xc_10_NEW.DATA_parsed' w boxes lc rgb "#cc88CAF0" t "XC - 0.10R^{+}" , 'xc_50_NEW.DATA_parsed' w boxes lc rgb "#6688CAF0" t "XC - 0.50R^{+}", 'xc_99_NEW.DATA_parsed' w boxes lc rgb "#88CAF0" t "XC - 0.99R^{+}"
#plot 'ip_10_NEW.DATA_parsed' u 1:2 w boxes lc rgb "#ee009E73" t "IP - 0.10R^{+}", 'ip_50_NEW.DATA_parsed' u 1:2 w boxes lc rgb "#bb009E73" t "IP - 0.50R^{+}", 'ip_99_NEW.DATA_parsed' u 1:2 w boxes lc rgb "#009E73" t "IP - 0.99R^{+}"

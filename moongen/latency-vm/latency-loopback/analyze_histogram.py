import os
from os import listdir
from os.path import isfile, join
import sys

mypath="."
onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]

for file in onlyfiles:
	if ".DATA" in file and "_parsed" not in file:
		print file
	else:
		continue

	# Previous, current bin
	prev_bin =		0
	prev_val = 		0
	curr_bin = 		0
	curr_val =		0

	hashtab =		{}

	# Check values
	data = open(file)
	print ("Opening: ", file)

	output = open(file+"_parsed", "w")

	lines = data.readlines()[1:]

	for l in lines:
		values = l.strip().split(",")

		curr_bin = round(float(values[0])/1000, 1)		# Putting string here for hashtabl

		if(curr_bin - prev_bin) < 0.3:
			curr_val += int(values[1])
		else:
			#print (prev_bin, prev_val)
			#output.write(str(prev_bin) + ", " + str(prev_val) + "\n" )
			curr_val = int(values[1])

		if (curr_bin not in hashtab.keys()):
			hashtab[curr_bin] = int(values[1])
		else:
			hashtab[curr_bin] += int(values[1])

		prev_bin = curr_bin
		prev_val = curr_val

	data.close()

	k = [float(x) for x in hashtab.keys()]
	k.sort()

	#print k
	#print sum( hashtab.values() )

	start = k[0]
	step = 0.3
	val = 0

	#print start
	for i in k:
		if i >= start and i < start+step:
			val += hashtab[i]
		else:
			output.write( str(start) + ", " + str(val) + "\n")
			start = i
			val = hashtab[i]

	output.write( str(start) + ", " + str(val) + "\n")
	output.close()

sys.exit()

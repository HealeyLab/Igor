import shutil
from os import listdir # used in first 2 lines of code
from os.path import join, getmtime # used in first 2 lines of code
from os import walk
import datetime as dt # to get date
#08.24.15.Cell1.Spont1.r1
#08.24.15.Cell1.-50pa.r1
#to run, ALT+R in atom
#List files in particular directory
#NOTE THAT THIS CHANGES THE "FILE TYPE"
path = 'C:\Users\danieljonathan\Desktop\New_folder'
onlyfiles = []
# for (dirpath, _, filenames) in walk(path):
# 	onlyfiles.extend(join(dirpath, filename) for filename in filenames)
# 	break
# print onlyfiles # THIS NEEDS TO BE IN THE RIGHT ORDER!!!!!!!!!!!!!!!!!!!!
				#SEE ABOVE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
f = sorted(listdir(path), key=lambda x: getmtime(join(path, x)))
onlyfiles = []
onlyfiles.extend(join(path, filename) for filename in f)
print onlyfiles

date = dt.date.today().strftime("%m.%d.%Y.") # That day's date in appropriate format
overall_count = 0; # how many files we have renamed
protocol_pos = -1; # where in Rudi's protocol are you? 0 = spont 1 = -50 2 = -40, etc
cell_num = 0 # nth cell of the day
trial = 1

for item in onlyfiles:
	overall_count = overall_count + 1
	protocol_pos = (protocol_pos + 1) % 15 # will use to get step
	cell_num = cell_num + 1

	#08.24.15.Cell1.-- up to here
	filename = date + "Cell" + str(cell_num) + "."
	filename = join(path, filename)
	if protocol_pos == 0:
		#08.24.15.Cell1.Spont.r1 up to here
		filename = filename + "Spont.r" + str(trial)
	elif protocol_pos >= 1 and protocol_pos <= 15:
		#08.24.15.Cell1.-50pa.r1 up to here
		step = protocol_pos * 10 - 60 # if pp is 1 (so -50), step = pp * 10 - 60
		filename = filename + str(step) + "pa." + str(trial)
	else:
		raise ValueError('protocol_pos outside of accepted range')

	shutil.move(item, filename) # renames file
print onlyfiles

#input: number of cells, for each cell: full or int (number of steps), and number of trials
#this will be a command line argument

# This code checks what percentage of Mobilyze and Purple Robot contacts are covered by the mappings in all.json

import csv
import json
from copy import deepcopy
import os
import math

data_dir = '/home/sohrob/Dropbox/Data/CS120/'
write_to = 'coverage.csv'
cs120_key = 'cs120'
pr_key = 'pr'

write_percentage = 0

with open('all.json') as f:
	mapping = json.load(f)
f.close()

# putting all cs120 and PR numbers in separate lists
keys = mapping.keys()
num_cs120 = []
num_pr = []
for key in keys:
	# each entry is a list, which can be empty or contain multiple numbers
	nums = mapping[key][cs120_key]
	for num in nums:
		num_cs120.append(num)
	nums = mapping[key][pr_key]
	for num in nums:
		num_pr.append(num)

subjects = os.listdir(data_dir)

#os._exit(0)

pr_perc = []
cs120_perc = []
cs120_exist_t = []
cs120_nexist_t = []

i = 0
for subj in subjects:

	i += 1

	# reading PR communication events file
	filename = data_dir + subj + '/coe.csv'
	if os.path.exists(filename):
		with open(filename) as file_in:
			data = csv.reader(file_in, delimiter='\t')
			pr_exist = []
			pr_exist_t = []
			for data_row in data:
				if data_row:
					if (data_row[1] in num_pr) or (data_row[2] in num_pr):
						pr_exist.append(1)
						pr_exist_t_row = [data_row[0], 1]
					else:
						pr_exist.append(0)
						pr_exist_t_row = [data_row[0], 0]
					pr_exist_t.append(list(pr_exist_t_row))
		file_in.close()
		pr_perc.append(sum(pr_exist) / float(len(pr_exist)))
	
		#writing temporal information to individual files for each subject
		with open('availability_temporal/pr_'+subj+'.csv', 'w') as file_out:
			spamwriter = csv.writer(file_out, delimiter='\t',quotechar='|',quoting=csv.QUOTE_MINIMAL)
			for j in range(len(pr_exist_t)):
				data_out_row = pr_exist_t[j]
				spamwriter.writerow(data_out_row)
		file_out.close()

	else:
		pr_perc.append(float('nan'))

	# reading cs120 reports file
	filename = data_dir + subj + '/emc.csv'
	if os.path.exists(filename):
		with open(filename) as file_in:
			data = csv.reader(file_in, delimiter='\t')
			cs120_exist = []
			cs120_exist_t = []
			for data_row in data:
				if data_row:
					if (data_row[2] in num_cs120) or (data_row[3] in num_cs120):
						cs120_exist.append(1)
						cs120_exist_t_row = [data_row[0], 1]
					else:
						cs120_exist.append(0)
						cs120_exist_t_row = [data_row[0], 0]
					cs120_exist_t.append(list(cs120_exist_t_row))
		file_in.close()
		cs120_perc.append(sum(cs120_exist) / float(len(cs120_exist)))
		
		#writing temporal information to individual files for each subject
		with open('availability_temporal/cs120_'+subj+'.csv', 'w') as file_out:
			spamwriter = csv.writer(file_out, delimiter='\t',quotechar='|',quoting=csv.QUOTE_MINIMAL)
			for j in range(len(cs120_exist_t)):
				data_out_row = cs120_exist_t[j]
				spamwriter.writerow(data_out_row)
		file_out.close()

	else:
		cs120_perc.append(float('nan'))

	print str(i) + '\t' + subj + '\t' + str(pr_perc[len(pr_perc)-1]) + '\t' + str(cs120_perc[len(cs120_perc)-1])


if write_percentage:
	with open(write_to, 'w') as file_out:
		spamwriter = csv.writer(file_out, delimiter='\t',quotechar='|',quoting=csv.QUOTE_MINIMAL)
		for i in range(len(subjects)):
			data_out_row = [subjects[i], pr_perc[i], cs120_perc[i]]
			spamwriter.writerow(data_out_row)
	file_out.close()

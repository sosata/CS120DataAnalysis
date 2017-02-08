# This code checks what percentage of Mobilyze and Purple Robot contacts are covered by the mappings in all.json

import csv
import json
from copy import deepcopy
import os
import math

data_dir = '/data/CS120/'
write_to = 'coverage.csv'
cs120_key = 'cs120'
pr_key = 'pr'

write_percentage = 0
write_times_pr = 1
write_times_cs120 = 0

with open('all.json') as f:
	mapping = json.load(f)
f.close()

# putting all cs120 and PR numbers in separate lists
keys = mapping.keys()

nums_cs120 = []
nums_pr = []
conn = []
for key in keys:
	# each entry is a list, which can be empty or contain multiple numbers
	nums_cs120 = mapping[key][cs120_key]
	nums_pr = mapping[key][pr_key]

	if nums_cs120 and not(nums_pr):
		conn.append(3)
	if not(nums_cs120) and nums_pr:
		conn.append(2)
	if nums_cs120 and nums_pr:
		conn.append(1)
	if not(nums_cs120) and not(nums_pr):
		conn.append(0)

if len(conn)!=len(keys):
	print "something is wrong"

print "Empty:"
print conn.count(0)/len(conn)
print "Both present:"
print conn.count(1)/float(len(conn))
print "No CS120:"
print conn.count(2)/float(len(conn))
print "No PR:"
print conn.count(3)/float(len(conn))
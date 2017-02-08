import csv
import os
import googlemaps

data_dir = '/data/CS120/'
write_to = 'timezones.csv'

gmaps = googlemaps.Client(key='AIzaSyCwHqrSA8yHkAYDjzkQXmC8YqjmgJHUOFg')

subjects = os.listdir(data_dir)

#subjects = subjects[0:3]

i = 0
timezone = []
for subj in subjects:
	# reading GPS data
	filename = data_dir + subj + '/fus.csv'
	if os.path.exists(filename):
		with open(filename) as file_in:
			reader = csv.reader(file_in, delimiter='\t')
			data = next(reader)
			t = data[0]
			lat = data[1]
			lng = data[2]

			resp = gmaps.timezone(location=(lat,lng),timestamp=t)
			timezone.append(resp['rawOffset'] / 3600)
		file_in.close()
	else:
		timezone.append(float('nan'))

	print str(i)+'\t'+subj+'\t'+str(timezone[i])
	i += 1

with open(write_to, 'w') as file_out:
	spamwriter = csv.writer(file_out, delimiter='\t',quotechar='|',quoting=csv.QUOTE_MINIMAL)
	for i in range(len(subjects)):
			spamwriter.writerow([subjects[i], timezone[i]])
file_out.close()
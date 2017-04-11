import csv
import os.path
import ast

subjects_info = '../PG2CSV_CS120/subject_info_cs120.csv'
data_path = '/home/sohrob/Dropbox/Data/CS120/'

subjects = []
with open(subjects_info) as f:
    f_csv = csv.reader(f, delimiter=';', quotechar='|')
    for row in f_csv:
        subjects.append(row[0])
f.close()

#subjects = [subjects[0]]

for subject in subjects:
    filename = data_path+subject+'/'+'eml.csv'
    if os.path.isfile(filename):
        with open(filename) as f:
            f_csv = csv.reader(f, delimiter='\t', quotechar='|')
            rows = []
            for row in f_csv:
                cat_list = ast.literal_eval(row[6])
                if cat_list:
                    row[6] = cat_list[0]
                else:
                    print "empty! (replaced with Home)"
                    row[6] = "Home"
                cat_list = ast.literal_eval(row[7])
                if cat_list:
                    row[7] = cat_list[0]
                else:
                    print "empty! (replaced with Home)"
                    row[7] = "Home"
                rows.append(row)
        f.close()

        filename = data_path+subject+'/'+'eml2.csv'
        with open(filename, 'w') as f:
            f_csv = csv.writer(f, delimiter='\t')
            for row in rows:
                f_csv.writerow(row)
        f.close()
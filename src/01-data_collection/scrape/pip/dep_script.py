import os
import csv
import pandas

fl = open('00names_prod_mature_osi_approved.csv')
csv_f = csv.reader(fl)

list = []

for row in csv_f:
	list.append(str(row[1]))


for x, name in enumerate(list):
	if x < 4969:
		pass
	else:
		try:
			os.system("johnnydep " + str(name) + " > " + str(name) + ".txt")
			print(x)
			pass
		except Exception as e:
			raise e
			os.system("touch " + str(name) + ".txt")
			print(x)



import pandas as pd

categories = ['Audio and Video', 'Business and Enterprise', 'Communications', 'Development', 'Games', 'Graphics', 'Home and Education', 'Science and Engineering', 'Security and Utilities', 'System Administration']

AV = pd.read_csv('Audio and Video.csv')
BE = pd.read_csv('Business Enterprise.csv')
COM = pd.read_csv('Communications.csv')
DEV = pd.read_csv('Development.csv')
GAM = pd.read_csv('Games.csv')
FX = pd.read_csv('Graphics.csv')
HE = pd.read_csv('Home and Education.csv')
SE = pd.read_csv('Science and Engineering.csv')
SU = pd.read_csv('Security and Utilities.csv')
SA = pd.read_csv('System Administration.csv')

abbreviations = [AV, BE, COM, DEV, GAM, FX, HE, SE, SU, SA]

i = 0
for cat in abbreviations:
	cat['Category'] = categories[i]
	i = i + 1

all_cats = [AV, BE, COM, DEV, GAM, FX, HE, SE, SU, SA]
SourceForge_Data = pd.concat(all_cats)
SourceForge_Data.to_csv('SourceForge Data.csv')

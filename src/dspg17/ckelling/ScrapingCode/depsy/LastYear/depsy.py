from bs4 import BeautifulSoup
import urllib
import pandas as pd
import numpy as np


####################################

# Change these two and let the magic begin

name = 'MASS' # MASS gives a lot
r_or_python = 'r' # choose 'r' or 'python'

####################################

def f7(seq):
    seen = set()
    seen_add = seen.add
    return [x for x in seq if not (x in seen or seen_add(x))]

names = [name]
dependency_rank = []
impact_score = []
number_reused_by = []
number_contributors = []
number_downloads = []
number_citations = []
hood_size = []
number_commits = []
is_academic = []
contrib_rank = []
all_tags = []

info = []

# This block of code gets the text mining started
r = urllib.urlopen('http://depsy.org/api/package/'+r_or_python+'/'+name).read()
soup = BeautifulSoup(r)
body1 = soup.find('body')
body = str(body1).split('\n')


# This block of code gets the names of dependent packages (only in r/python)
reused_by1 = [i - 1 for i, x in enumerate(body) if 'neighborhood_size' in x]
reused_by2 = reused_by1[1:len(reused_by1)]
reused_name = [body[x][21:len(body[x])-3] for x in reused_by2]

# This block of code gets the info about the node package
root_idx = [i for i, x in enumerate(body) if '"name": "'+name+'"' in x][-1]
k = 0
if (body[1].find(']') > 0):
    k = 1
    num_contrib = float('nan')
else:
    num_contrib = int(body[root_idx+5].split(' ')[5][:-1])
if (body[root_idx+3].split(' ')[-2][0:-1] == 'null'):
    commits = float('nan')
else:
    commits = int(body[root_idx+3].split(' ')[-2][0:-1])
num_reused_by = int(body[root_idx-3].split(' ')[5][:-3])
impact = float(body[root_idx-5].split(' ')[5][:-1])
downloads = int(body[root_idx+14-k].split(' ')[-1])
citations = int(body[root_idx+22-k].split(' ')[-1])
depend_rank = float(body[root_idx+30-k].split(' ')[-1])
neighborhood_size = float(body[root_idx+1].split(' ')[-2][0:-1])
academic = bool(body[root_idx-2].split(' ')[-2][0:-1])

# Gets the weighted contributor score -- calculated by: the product of 
# contributor impact and their credit percentage for the package, summed over all contributors
if (body[1].find('"all_contribs": [],') > -1):
    weighted_contributor_value = float('nan')
else:
    contrib_impact = [float(body[i-5].split(' ')[-2][0:-1]) for i, x in enumerate(body) if '"person_name":' in x][0:num_contrib]
    contrib_weight = [float(body[i+1].split(' ')[-2][0:-1]) for i, x in enumerate(body) if '"person_name":' in x][0:num_contrib]
    weighted_contributor_value = np.dot(contrib_impact,contrib_weight)


tags = []
i = 1
while(not ('top_contribs' in body[root_idx+34+i] or ']' in body[root_idx+34+i])):
    tags.append([x for x in body[root_idx+34+i].split(' ') if x != ''][0].replace(',','')[1:-1])
    i = i + 1

# stores everything
info.append([name,r_or_python, depend_rank,citations,impact,num_reused_by,num_contrib, downloads,reused_name,tags, neighborhood_size, commits, academic])
[names.append(x) for x in reused_name]
names = f7(names)
dependency_rank.append(depend_rank)
impact_score.append(impact)
number_reused_by.append(num_reused_by)
number_contributors.append(num_contrib)
number_downloads.append(downloads)
number_citations.append(citations)
hood_size.append(neighborhood_size)
number_commits.append(commits)
is_academic.append(academic)
contrib_rank.append(weighted_contributor_value)
all_tags.append(tags)

# iterate through the dependencies
j = 1
while(not j == len(names)):
    name = names[j]
    print(j,name)
    # This block of code gets the text mining started
    r = urllib.urlopen('http://depsy.org/api/package/'+r_or_python+'/'+name).read()
    soup = BeautifulSoup(r)
    body1 = soup.find('body')
    body = str(body1).split('\n')
    
    
    # This block of code gets the names of dependent packages (only in r/python)
    reused_by1 = [i - 1 for i, x in enumerate(body) if 'neighborhood_size' in x]
    reused_by2 = reused_by1[1:len(reused_by1)]
    reused_name = [body[x][21:len(body[x])-3] for x in reused_by2]
    
    # This block of code gets the info about the node package
    root_idx = [i for i, x in enumerate(body) if '"name": "'+name+'"' in x][-1]
    
    k = 0
    if (body[1].find(']') > 0):
        k = 1
        num_contrib = float('nan')
    else:
        num_contrib = int(body[root_idx+5].split(' ')[5][:-1])
    if (body[root_idx+3].split(' ')[-2][0:-1] == 'null'):
        commits = float('nan')
    else:
        commits = int(body[root_idx+3].split(' ')[-2][0:-1])
    num_reused_by = int(body[root_idx-3].split(' ')[5][:-3])
    impact = float(body[root_idx-5].split(' ')[5][:-1])
    downloads = int(body[root_idx+14-k].split(' ')[-1])
    citations = int(body[root_idx+22-k].split(' ')[-1])
    depend_rank = float(body[root_idx+30-k].split(' ')[-1])
    neighborhood_size = float(body[root_idx+1].split(' ')[-2][0:-1])
    academic = bool(body[root_idx-2].split(' ')[-2][0:-1])
    
    if (body[1].find('"all_contribs": [],') > -1):
        weighted_contributor_value = float('nan')
    else:
        contrib_impact = [float(body[i-5].split(' ')[-2][0:-1]) for i, x in enumerate(body) if '"person_name":' in x][0:num_contrib]
        contrib_weight = [float(body[i+1].split(' ')[-2][0:-1]) for i, x in enumerate(body) if '"person_name":' in x][0:num_contrib]
        weighted_contributor_value = np.dot(contrib_impact,contrib_weight)


    tags = []
    i = 1
    while(not ('top_contribs' in body[root_idx+34+i] or ']' in body[root_idx+34+i])):
        tags.append([x for x in body[root_idx+34+i].split(' ') if x != ''][0].replace(',','')[1:-1])
        i = i + 1
    
    # stores everything
    info.append([name,r_or_python, depend_rank,citations,impact,num_reused_by,num_contrib, downloads,reused_name,tags, neighborhood_size, commits, academic])
    [names.append(x) for x in reused_name]
    names = f7(names)
    dependency_rank.append(depend_rank)
    impact_score.append(impact)
    number_reused_by.append(num_reused_by)
    number_contributors.append(num_contrib)
    number_downloads.append(downloads)
    number_citations.append(citations)
    hood_size.append(neighborhood_size)
    number_commits.append(commits)
    is_academic.append(academic)
    contrib_rank.append(weighted_contributor_value)
    all_tags.append(tags)
        
    j = j + 1

## creates and edge list        
Source = []
Target = []
for l in range(len(info)):
    for m in range(len(info[l][8])):
        Source.append(info[l][8][m])
        Target.append(info[l][0])
            
# making the csv for the edge list
df = pd.DataFrame({'Source': Source, 'Target': Target})
df.to_csv(names[0]+'_edgelist.csv', sep=',', index = False)

# makes the csv for the node info
df2 = pd.DataFrame({'package': names, 
                    'dependency_rank': dependency_rank, 
                    'impact': impact_score, 
                    'num_reused_by': number_reused_by, 
                    'num_contributors': number_contributors, 
                    'num_downloads': number_downloads, 
                    'num_citations': number_citations,
                    'neighborhood_size': hood_size,
                    'num_commits': number_commits,
                    'is_academic': is_academic,
                    'contributors_rank': contrib_rank,
                    'tags': all_tags})
df2.to_csv(names[0]+'_nodes.csv', sep=',', index = False, columns = ['package',
                                                                  'dependency_rank',
                                                                  'impact',
                                                                  'num_reused_by',
                                                                  'num_contributors',
                                                                  'num_downloads',
                                                                  'num_citations',
                                                                  'neighborhood_size',
                                                                  'num_commits',
                                                                  'is_academic',
                                                                  'contributors_rank',
                                                                  'tags'])

from bs4 import BeautifulSoup
import urllib
import os
import time
start_time = time.time()
import pandas as pd

titles=[]
descriptions=[]
weekly_downloads=[]
url=[]
average_rating=[]
num_ratings=[]
last_update=[]

for k in range(50):
    r = urllib.urlopen('https://sourceforge.net/directory/system-administration/?page='+str(k+1)).read()
    soup = BeautifulSoup(r)
    TDD = soup.find_all("div", class_="project_info")
    R = soup.find_all("div", class_="more-info")
    for i in range(len(TDD)):
        titles.append(TDD[i].get_text().split('\n')[1].encode('ascii','ignore'))
        descriptions.append(TDD[i].get_text().split('\n')[2].encode('ascii','ignore'))
        weekly_downloads.append(int(TDD[i].get_text().split('\n')[len(TDD[i].get_text().split('\n'))-3].encode('ascii','ignore').split()[0].replace(',','')))
        url.append(TDD[i].a['href'])
counter = 1
for j in url:
    s = urllib.urlopen('https://sourceforge.net'+j).read()
    soup2 = BeautifulSoup(s)
    if soup2.find_all("section", class_="social-sharing")!=[]: # not enterprise
        review = soup2.find_all("section", class_="content")
        if str(review[0].get_text().split()[2])=='Stars': 
            average_rating.append(float(review[0].get_text().split('\n')[2].split()[0].encode('ascii','ignore').replace(',','')))
            num_ratings.append(int(review[0].get_text().split('\n')[3].encode('ascii','ignore').replace('(','').replace(')','')))
        else: 
            average_rating.append(0)
            num_ratings.append(0)
        if str(review[0].get_text().split()[1])=='Downloads':
            last_update.append(str(' '.join(review[1].get_text().split()[2:])))
        else:    
            last_update.append(str(' '.join(review[2].get_text().split()[2:])))
    else: 
        review = soup2.find_all("div", class_="project-rating")
        if str(review[0].get_text().split()[0]) == 'Last':
            average_rating.append(0)
            num_ratings.append(0)
            last_update.append(str(' '.join(review[0].get_text().split()[2:])))
        else:
            average_rating.append(float(str(review).split('"')[9]))
            num_ratings.append(int(str(review).split('"')[38][2:len(str(soup2.find_all("div", class_="project-rating")).split('"')[38])-17]))
            last_update.append(str(review[0].get_text().split('|')[1])[18:][:-1])
    print(str((float(counter)+1)*100/1250)+'%')
    counter = counter + 1
        
Dataset = pd.DataFrame(
    {'OSS': titles,
     'description': descriptions,
     'weekly_downloads': weekly_downloads,
     'URL': url,
     'average_rating': average_rating,
     'num_ratings': num_ratings,
     'last_update': last_update
    })

print("--- %s seconds ---" % (time.time() - start_time))
os.system("say 'Your code is finished runing'")
Dataset.to_csv('System Administration.csv')

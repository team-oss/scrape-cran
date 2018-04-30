##Alex Gagliano
##10/24/2016
##Script for scraping the major OSS projects on OpenHub and pulling their ActivityFacts Objects

from bs4 import BeautifulSoup
import urllib

wf = open('OpenDuckProjects_SizeFactsScrape.txt', 'a')

projectNames = list()
r = urllib.urlopen('https://www.openhub.net/').read()
soup = BeautifulSoup(r, "lxml")
Soup1 = soup.findAll("div", {"class": "top_ten_link"})[11:20]

for ana in Soup1:
    projectNames.append(str(ana.a.get('href')).replace("/p/", ""))

for name in projectNames:
    #pull data from webpage
    r = urllib.urlopen('https://www.openhub.net/projects/' + name + '/analyses/latest/size_facts.xml?api_key=d32768dd2ec65efd004d19a9f3c7262d7f30cd8959d9009ce4f9b8e7e19ff0ef&v=1').read()
    soup = BeautifulSoup(r, "lxml")
    
    for item in soup.findAll('size_fact'):
        tempProj = name
        tempDate = str(item('month')[0].text)
        tempCode = str(item('code')[0].text)
        tempComments = str(item('comments')[0].text)
        tempBlanks = str(item('blanks')[0].text)
        tempCommRatio = str(item('comment_ratio')[0].text)
        tempCommits = str(item('commits')[0].text)
        tempManMonths = str(item('man_months')[0].text)
        tempDesig = "Active"
        
        wf.write(tempProj + ", " + tempDate + ", " + tempCode + ", " + tempComments + ", " + tempBlanks + ", " + tempCommRatio + ", " + tempCommits + ", " + tempManMonths + ", " + tempDesig + "\n")
        
wf.close()
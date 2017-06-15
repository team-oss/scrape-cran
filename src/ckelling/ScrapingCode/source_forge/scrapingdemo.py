import requests
from bs4 import BeautifulSoup

# Read page from URL and parse
r = requests.get("https://sourceforge.net/directory/science-engineering/os:mac/")
r.content
soup = BeautifulSoup(r.content)

#### Big identifyer!!!!!! 
ul = soup.find('ul', {'class':"facets"})
listing=[]

for i in range(21):
    j=i*2+3
    some = ''.join(ul.contents[j].contents[0].contents[0])
    some=some.encode('ascii','ignore')
    listing.insert(i,some)
    

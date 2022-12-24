import requests
from bs4 import BeautifulSoup
import csv
from itertools import zip_longest

job_titles=[]
company_names=[]
job_skills=[]
company_location=[]
link=[]
salary=[]
datepost=[]
page_num=0

while True:
  #to bring the web page
  result = requests.get(f"https://wuzzuf.net/search/jobs/?a=hpb&q=python&start={page_num}")

  #to bring the content of the page
  src =result.content
  #print(src)
  #create soup objetc to parse content
  soup = BeautifulSoup(src,"lxml")
  #print(soup)
  page_li=int(soup.find("strong").text)
  if (page_num>page_li//15):
      print("pages ended")
      break

  #get job titels,job skills,company name,location
  job_titel = soup.find_all("h2",{"class":"css-m604qf"})
  print(job_titel)

  company_name = soup.find_all("a",{"class":"css-17s97q8"})
  #print(company_name)

  job_skill = soup.find_all("div",{"class":"css-y4udm8"})
  location = soup.find_all("span",{"class":"css-5wys0k"})
  new_posted =soup.find_all("div",{"class":"css-4c4ojb"})
  old_posted = soup.find_all("div", {"class": "css-do6t5g"})
  posted =[*new_posted,*old_posted]

  for i in range(len(job_titel)):
    job_titles.append(job_titel[i].text)
    link.append(job_titel[i].find("a").attrs["href"])
    company_names.append(company_name[i].text)
    job_skills.append(job_skill[i].text)
    company_location.append(location[i].text)
    datepost.append(posted[i].text)
  page_num+=1


#for links in link:
    #result=requests.get(links)
    #src= result.content
    #soup= BeautifulSoup(src,"lxml")
    #salaries=soup.find("span",{"class":"4xky9y"})
    #salary.append(salaries.text)

#print(job_titles)
#print(company_names)
#print(job_skills)
#print(company_location)

file_list=[job_titles,company_names,datepost,company_location,link,job_skill]
exported = zip_longest(*file_list)
with open("jobs","w") as results1 :
    wr=csv.writer(results1)
    wr.writerow(["job_titels","company_names","datepost","company_location","link","job_skills"])
    wr.writerows(exported)
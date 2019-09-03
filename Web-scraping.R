# Packages

# install.packages("rvest")
# install.packages("selectr")

# Attaching package

library(rvest)
library(selectr)

#Example 1: Wikipedia table
#read html
wikipedia_page = 
  read_html("https://en.wikipedia.org/wiki/World_Health_Organization_ranking_of_health_systems_in_2000")

# browse
wikipedia_page

#xpath
section_of_wikipedia<-html_node(wikipedia_page,xpath='//*[@id="mw-content-text"]/div/table')

#section_of_wikipedia<-html_node(wikipedia_page,xpath=//*[@id="mw-content-text"]/div/table[2]/tbody
head(section_of_wikipedia) 

#browse the first rows
health_rankings <-html_table(section_of_wikipedia)
head(health_rankings[,(1:2)])


#Example 2: Duke website
duke_page<-read_html("https://www.duke.edu")
duke_events<-html_nodes(duke_page, css="li:nth-child(1) .epsilon")
html_text(duke_events)

#Selenium
#automate your entire web browser. 
#This means that we will write code that will tell our computer to a) open a web browser; b) load a web page; c) interact with the web page by clicking on the search bar and entering text; and c) downloading the resultant data.

#First install selenium
#1. install Java SE Development Kit. 
#2. ownload Docker and install it. 
#3. provide the user name you setup to download Docker
#4. make Docker available to RSelenium using the following command:

#Example: pass the word "data science"

system('docker run -d -p 4445:4444 selenium/standalone-chrome')

#install and attach package 
install.packages("RSelenium")
library(RSelenium)

# Check available versions of chromedriver
binman::list_versions("chromedriver")

# start a Selenium server
rD <- rsDriver(browser = c("chrome"), chromever = "75.0.3770.8")

# open the browser
remDr <- rD$client
#launch the website
remDr$navigate("https://www.duke.edu")
#find elements
#use the Selector Gadget or some other method to identify the part of the web page 
#where the “search” bar is. After some trial and error, 
#I discovered the CSS selector was fieldset input:
search_box <- remDr$findElement(using = 'css selector', 'fieldset input')
    #by far, the search bar is highlighted in your browser

search_box$sendKeysToElement(list("data science", "\uE007"))

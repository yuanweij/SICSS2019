#Geo-coding
#install packages
install.packages("ggmap")
install.packages("RJSONIO")
install.packages("RCurl")
install.packages("readr")
install.packages('bitops')
install.packages("tidyverse")
install.packages('plyr')
install.packages('googleway')

#attach packages
library(ggplot2)
library(ggmap)
library(RJSONIO)
library(RCurl)
library(readr)
library(tidyverse)
library(googleway)


# setting working directory 
setwd("")

# keys
keys <- c("")
keynum <- 1
register_google(key = "")

#get map
map.LA <- get_map("LA")
ggmap(map.LA)
# same~
t<-get_map("Westwood Village", zoom = 16) %>% ggmap()

#set keys for google_places
keys <- c("")
set_key(key=keys)
google_keys()

#search with google maps
df_places <- google_places(search_string="restaurant",
                           location= c(34.062, -118.444),
                           radius = 50000,
                           key = keys)

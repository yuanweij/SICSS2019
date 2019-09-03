#API call
#1. base url
#2. specific url
#3 define entitiy

#Twitter API
#install rtweet
install.packages('rtweet')
install.packages("devtools")
install_github("mkearney/rtweet")
library(rtweet)
library(devtools)

#define credentials
app_name<-"YOURAPPNAMEHERE"
consumer_key<-"YOURKEYHERE"
consumer_secret<-"YOURSECRETHERE"
access_token<-"YOURACCESSTOKENHERE"
access_token_secret<-"YOURACCESSTOKENSECRETHERE"

#authenticate with twitter API
create_token(app=app_name, consumer_key=consumer_key, consumer_secret=consumer_secret)

#3000 tweets with #korea
korea_tweets<-search_tweets("#Korea", n=50, include_rts = FALSE)
#browse the results
names(korea_tweets)
  #browse the tweets
head(korea_tweets$text)

#plots
ts_plot(korea_tweets, "3 hours") +
  ggplot2::theme_minimal() +
  ggplot2::theme(plot.title = ggplot2::element_text(face = "bold")) +
  ggplot2::labs(
    x = NULL, y = NULL,
    title = "Frequency of Tweets about Korea from the Past Day",
    subtitle = "Twitter status (tweet) counts aggregated using three-hour intervals",
    caption = "\nSource: Data collected from Twitter's REST API via rtweet")

#search by location
nk_tweets <- search_tweets("korea",
                           "lang:en", geocode = lookup_coords("usa"), 
                           n = 1000, type="recent", include_rts=FALSE)
geocoded <- lat_lng(nk_tweets)

#plot location
par(mar = c(0, 0, 0, 0))
maps::map("state", lwd = .25)
with(geocoded, points(lng, lat, pch = 20, cex = .75, col = rgb(0, .3, .7, .75)))

#last 5 tweets of a user
sanders_tweets <- get_timelines(c("sensanders"), n = 5)
head(sanders_tweets$text)

#general information
sanders_twitter_profile <- lookup_users("sensanders")

#browse field
sanders_twitter_profile$location

#trending topics by location
get_trends("New York")

#tweet -- for bots building
post_tweet("I'm a bot")


install.packages("twitteR")
install.packages("wordcloud")
install.packages("tm")

library("twitteR")
library("wordcloud")
library("tm")

consumer_key <- 'SKiuZFKrK2p7njrbJWLnC91oF'
consumer_secret <- '2bBRVu0EZ0pJIQJLjLt42p6hJKkrwsikjeE0klPnppJPo5LTo1'
access_token <- '89095218-SMM7OMwn0VqeH96clH1LAXrZUmO83aN2Rpgg23AO8'
access_secret <- 'GdN5ozybpudWpIhCPWFofvC5FOoPorbAbOVzedn3C3kqp'

setup_twitter_oauth(consumer_key,
                    consumer_secret,
                    access_token,
                    access_secret)


#Get followers
install.packages("rtweet")
library(rtweet)

# Retrieve a list of the accounts following a user.

## get user IDs of accounts following @jgerteis
jgerteis_flw <- get_followers("jgerteis", n = 75000)

# lookup data on those accounts 
jgerteis_flw_data <- lookup_users(jgerteis_flw$user_id) 

# Or if you really want ALL of their followers:
# how many total follows does cnn have? 
cnn <- lookup_users("jgerteis")
# get them all (this would take a little over 5 days) 
jgerteis_flw <- get_followers(   "jgerteis", n = jgrteis$followers_count, 
                            retryonratelimit = TRUE )



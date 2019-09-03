#install packages
install.packages("topicmodels")
install.packages("tm")

#attach packages
library(topicmodels)
library(tm)

#load dataset
load("/Users/Ginger/Downloads/Trump_Tweets.Rdata")

#browse test data
head(trumptweets$text)

#create corpus
trump_corpus <- Corpus(VectorSource(as.vector(trumptweets$text))) 
trump_corpus  #meta data corpus, document 3196

#install tidytext to create corpus
install.packages("tidytext")
library(tidytext)
library(dplyr)

#load our database of Trump tweets into tidytext format
tidy_trump_tweets <- trumptweets %>%
  select(created_at, text) %>%
  unnest_tokens('word', text)

#count the most popular
tidy_trump_tweets %>%
  count(word) %>%
  arrange(desc(n))

#remove stop words
data("stop_words")
tidy_trump_tweets<-tidy_trump_tweets %>%
  anti_join(stop_words)
#count the most popular
trump_tweet_top_words <- tidy_trump_tweets %>%
  count(word) %>%
  arrange(desc(n))

trump_tweet_top_words

#removing html
trump_tweet_top_words<-
  trump_tweet_top_words[-grep("https|t.co|amp|rt",
                              trump_tweet_top_words$word),]
#browse again
trump_tweet_top_words

#graph top 20 words
top_20<-trump_tweet_top_words[1:20,]

#create factor variable to sort by frequency
trump_tweet_top_words$word <- factor(trump_tweet_top_words$word, levels = trump_tweet_top_words$word[order(trump_tweet_top_words$n,decreasing=TRUE)])

library(ggplot2)
ggplot(top_20, aes(x=word, y=n))+
  geom_bar(stat="identity")+
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  ylab("Number of Times Word Appears in Trump's Tweets")+
  xlab("")+
  guides(fill=FALSE)

#tf-idf
tidy_trump_tfidf<- trumptweets %>%
  select(created_at,text) %>%
  unnest_tokens("word", text) %>%
  anti_join(stop_words) %>%
  count(word, created_at) %>%
  bind_tf_idf(word, created_at, n)

top_tfidf<-tidy_trump_tfidf %>%
  arrange(desc(tf_idf))

top_tfidf

top_tfidf$word[1]

#create own dictionay (Economics)
economic_dictionary<-c("economy","unemployment","trade","tariffs")
library(stringr)
economic_tweets<-trumptweets[str_detect(trumptweets$text, paste(economic_dictionary, collapse="|")),]
economic_tweets

#dictionary based sentiment
      #bing sentiment
trump_tweet_sentiment <- tidy_trump_tweets %>%
  inner_join(get_sentiments("bing")) %>%
  count(created_at, sentiment) 

head(trump_tweet_sentiment)
     #create_at  add date
tidy_trump_tweets$date<-as.Date(tidy_trump_tweets$created_at, 
                                format="%Y-%m-%d %x")

trumptweets$date<-as.Date(trumptweets$created_at, format="%m/%d/%Y")
trumptweets$date

?as.Date()

#get the sentiment count by date
trump_sentiment_plot <-
  tidy_trump_tweets %>%
  inner_join(get_sentiments("bing")) %>% 
  filter(sentiment=="negative") %>%
  count(date, sentiment)

trump_sentiment_plot

     #plot postive tweets over time
library(ggplot2)
ggplot(trump_sentiment_plot, aes(x=date, y=n, group=sentiment, color=sentiment))+
  geom_line()+
  theme_minimal()+
  ylab("Frequency of Positive and negative Words in Trump's Tweets")+
  xlab("Date")

#retweets x sentiment
install.packages('lattice')
library(lattice)

#get the retweet count by date

#plot

xyplot(trump_tweet_sentiment$n ~ trumptweets$retweet_count,
       xlab = "sentiment",
       ylab = "retweet",
       main = "sentiment and retweet"
)


install.packages('twitteR')
install.packages('igraph')
library(twitteR)
library(igraph)
library(stringr)
library(ggplot2)


#approval rate x sentiment
trump_approval<-read.csv("https://projects.fivethirtyeight.com/trump-approval-data/approval_topline.csv")

trump_approval$date<-as.Date(trump_approval$modeldate, format="%m/%d/%Y")

approval_plot<-
  trump_approval %>%
  filter(subgroup=="Adults") %>%
  filter(date>min(trump_sentiment_plot$date)) %>% 
  group_by(date) %>%
  summarise(approval=mean(approve_estimate))

#plot
ggplot(approval_plot, aes(x=date, y=approval))+
  geom_line(group=1)+
  theme_minimal()+
  ylab("% of American Adults who Approve of Trump")+
  xlab("Date")




data('AssociatedPress')

AP_topic_model<-LDA(AssociatedPress, k=10, control = list(seed = 321))

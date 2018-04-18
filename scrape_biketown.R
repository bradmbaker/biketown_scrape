library(curl,warn.conflicts = FALSE)
library(jsonlite,warn.conflicts = FALSE)
library(dplyr,warn.conflicts = FALSE)

# cycle through tokens to help avoid rate limiting.
load(file = "~/Documents/R/biketown_scrape/Tokens.Rdata")
load(file = "~/Documents/R/biketown_scrape/TokenUsage.Rdata")
last_used_token <- last_used_token + 1
ifelse(last_used_token > length(tokens), last_used_token <- 1, "")
auth_token <- tokens[last_used_token]
save(last_used_token, file = "~/Documents/R/biketown_scrape/TokenUsage.Rdata")


setwd("~/Documents/R/biketown_scrape/")

# set up curl
h <- new_handle()
handle_setopt(h)
handle_setheaders(h,
                  "Authorization" = paste("Bearer",auth_token)
)

# find number of bikes in network
req <- curl_fetch_memory("https://app.socialbicycles.com/api/networks/92/bikes.json", handle = h)
num_bikes <- fromJSON(rawToChar(req$content))$total_entries


# build data frame for adding all bike info to
bikes_df <- fromJSON(rawToChar(req$content))$items
# flatten the dataset so that it can be rbinded to later data
options(digits=10)
pnt_data <- data.frame(matrix(unlist(bikes_df$current_position$coordinates), ncol=2, byrow=T))
colnames(pnt_data) <- c("lon", "lat")
bikes_df <- cbind(bikes_df, pnt_data)
bikes_df <- bikes_df[,c('id', 'name', 'network_id', 'hub_id', 'inside_area', 
                        'address', 'sponsored', 'lon','lat')]

# loop through remaining bikes
n_pages <- ceiling(num_bikes/100)
for (i in 2:n_pages) {
  req_url <- paste("https://app.socialbicycles.com/api/networks/92/bikes.json?page=", i,sep = "")
  req <- curl_fetch_memory(req_url, handle = h)
  tmp_df <- fromJSON(rawToChar(req$content))$items
  pnt_data <- data.frame(matrix(unlist(tmp_df$current_position$coordinates), ncol=2, byrow=T))
  colnames(pnt_data) <- c("lon", "lat")
  tmp_df <- cbind(tmp_df, pnt_data)
  tmp_df <- tmp_df[,c('id', 'name', 'network_id', 'hub_id', 'inside_area', 
                          'address', 'sponsored', 'lon','lat')]
  bikes_df <- rbind(bikes_df, tmp_df)
}

# add a timestamp
time <- format(Sys.time())
bikes_df$ts <- time
bikes_df$hub_id[is.na(bikes_df$hub_id)] <- 0
write.table(bikes_df, file="tmp.csv", row.names=F, col.names=F,sep=",")

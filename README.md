# biketown_scrape

I ran a scrape of all the Biketown bikes in Portland every 5 minutes for about a week to see how they were used. The code in this repository is how that was generated.

The raw dataset is in the ________ file. A row exists in this table if the bike was seen during that scrape. My interpretation is that if the bike is not there it is being used or transported. The columns are as follows:

 Column name | Description  
 ----------- | ----------- 
 id          | The bike ID 
 name        | The name of the bike which looks like some other type of ID and a name for the different styles of Biketowns 
 hub_id      | If the bike is at a hub, the ID of that hub, otherwise 0 
 inside_area | If the bike is inside the Biketown network 
 address     | It looks like Biketown adds an address everytime a bike is parked. This is that address 
 sponsored   | A flag if it is a special type of bike and not the Biketown orange 
 lon         | Current longitude of the bike 
 lat         | Current latitude of the bike 
 ts          | the timestamp when the data was scraped 

<<<<<<< HEAD
=======
I ran a scrape of all the Biketown bikes in Portland every 5 minutes for about a week to see how they were used. The code in this repository is how that was generated.

The raw dataset is in the ________ file. A row exists in this table if the bike was seen during that scrape. My interpretation is that if the bike is not there it is being used or transported. The columns are as follows:

 Column name | Description  
 ----------- | ----------- 
 id          | The bike ID 
 name        | The name of the bike which looks like some other type of ID and a name for the different styles of Biketowns 
 network_id  | Always 92 for Portland. Probably should remove this... 
 hub_id      | If the bike is at a hub, the ID of that hub, otherwise 0 
 inside_area | If the bike is inside the Biketown network 
 address     | It looks like Biketown adds an address everytime a bike is parked. This is that address 
 sponsored   | A flag if it is a special type of bike and not the Biketown orange 
 lon         | Current longitude of the bike 
 lat         | Current latitude of the bike 
 ts          | the timestamp when the data was scraped 


>>>>>>> fce698a... Update README.md

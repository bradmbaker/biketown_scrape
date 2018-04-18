cd ~/Documents/R/biketown_scrape/
echo "kicking it off at" `date +%Y-%m-%d-%T`
echo "running R"
Rscript scrape_biketown.R
echo "R done"
echo "running SQL"
mysql < "load_data.sql"
echo "SQL done"
echo "cleaning up"
rm tmp.csv
echo "done at" `date +%Y-%m-%d-%T`
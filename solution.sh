#!/bin/bash

echo "Task_1"
csvsort -c release_date -r project1_data.csv > task1.csv

echo "Task_2"
csvsql --query 'select * from project1_data where vote_average > 7.5' project1_data.csv > task2.csv

echo "Task_3"
echo "Phim co doanh thu cao nhat"
sort -t',' -k5 -nr project1_data.csv | cut -d',' -f6,5 | head -1
echo "Phim co doanh thu thap nhat"
sort -t',' -k5 -n project1_data.csv | cut -d',' -f6,5 | head -1

echo "Task_4"
awk -F',' 'NR>1 {sum += $5} END {print sum}' project1_data.csv

echo "Task_5"
awk -F',' 'NR>1 {profit = $5 - $4; print profit, $6}' project1_data.csv | sort -gr | head -10

echo "Task_6"
echo "Dao dien co nhieu phim nhat"
csvcut -c director project1_data.csv | tr '|' '\n' | sort | uniq -c | sort -nr | head -10
echo "Dien vien dong nhieu phim nhat"
csvcut -c cast project1_data.csv | tr '|' '\n' | sort | uniq -c | sort -nr | head -10

echo "Task_7"
csvcut -c genres project1_data.csv | tr '|' '\n' | sort | uniq -c | sort -n

echo "End."

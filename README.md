# Bellabeat-Marketing-Case-Study-Tableau

## Introduction
This Case Study is the capstone project in the Google Data Analytics [Professional Certificate on Coursera](https://www.coursera.org/professional-certificates/google-data-analytics). As part of the case study, I’ll be using a dataset from Kaggle made available by [Möbius](https://www.kaggle.com/datasets/arashnic/fitbit) to analyze trends in fitness tracker usage to answer key business questions and make high-level recommendations for a wellness brand’s marketing strategy. Due to the limitations of the dataset, I would highly recommend collecting additional data to draw more accurate conclusions and make effective recommendations. 

## Business Task
I am acting as a data analyst working on the marketing analyst team at Bellabeat, a high-tech manufacturer of health-focused products for women. Bellabeat is a successful small company, but they aspire to become a larger player in the global smart device market. Urska Srsen, co-founder and Chief Creative Officer of Bellabeat, has asked the marketing analytics team to focus on one of Bellabeat’s products and analyze smart device data to gain insight into how consumers are already using their devices. The insights I discover will then help guide the marketing strategy for the company. I will create a presentation and present my high-level recommendations for Bellabeat’s marketing strategy.

## About The Data
The dataset used in this case study is publicly available on Kaggle. It consists of 18 total files containing fitness tracker data from 33 Fitbit users who consented to the submission of personal tracker data. Variation between output represents the use of different types of Fitbit trackers and individual tracking behaviors and preferences. The data contains a single month of data collected between 04.12.2016 and 05.12.2016. 

To focus my efforts on high-level insights, I chose to incorporate data from 4 of the files that I felt would provide the most relevant information: daily_activity, hourly_steps, sleep_day, & weight_log_info. Unfortunately, there was no way to determine the age or gender of participants, which would have been valuable information to help inform Bellabeat’s marketing strategy.

I used MySQL to import, clean, transform and analyze the data.

My SQL code includes the use of the following statements:
1. UPDATE / ALTER TABLE
2. Aggregate functions
3. Subqueries
4. Joins / Unions
5. CASE statements
6. COALESCE
7. WINDOW functions
8. VIEWS & Temporary tables

Instead of one long script, I split my analysis into separate files for readability.

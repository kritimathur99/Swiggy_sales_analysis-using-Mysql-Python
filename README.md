# Swiggy Sales Analysis Using MySQL & Python

## Project Overview

This project presents an end-to-end Sales Analysis of a Swiggy dataset containing 197,403 records. The objective was to transform raw transactional data into meaningful business insights through data cleaning, database modeling, SQL analytics, and Python-based visualization.

## Data Cleaning & Validation

The project began with extensive data quality checks to ensure accuracy and reliability of the analysis. The following steps were performed:

* Data validation and integrity checks
* Null value identification and verification
* Detection and removal of blank or empty string values
* Duplicate record identification and elimination
* Data consistency checks across key attributes

After cleaning, the dataset was prepared for analytical modeling and reporting.

## Database Design & Data Modeling

To create an efficient analytical structure, the original dataset was transformed into a Star Schema consisting of:

* 1 Fact Table
* 5 Dimension Tables

This dimensional modeling approach improves query performance and follows industry-standard data warehousing practices.

## SQL Analysis (MySQL)

Key Performance Indicators (KPIs) generated using MySQL:

* Total Orders
* Total Revenue
* Average Dish Price
* Average Rating

### Business Analysis Performed

* Monthly Order Trends
* Revenue Analysis
* Quarterly Performance Trends
* Yearly Performance Trends
* Orders by Day of Week
* Top 10 Cities by Order Volume
* Top 10 Cities by Revenue
* Revenue Contribution by State
* Top 10 Restaurants by Orders
* Top Categories by Order Volume
* Most Ordered Dishes
* Cuisine Performance Analysis
* Orders by Price Range
* Rating Distribution Analysis

## Python Analytics & Visualization

The cleaned MySQL data was imported into Python using MySQL Connector and analyzed using:

* Pandas
* NumPy
* Matplotlib
* Seaborn
* Plotly Express

### Additional KPIs Generated

* Total Orders
* Total Revenue
* Average Order Value
* Highest Order Value
* Average Rating
* Total Restaurants
* Total Cities
* Total Categories
* Total Dishes

### Visualizations Created

* Monthly Sales Trend
* Weekly Sales Trend
* Quarterly Performance Analysis
* Total Sales by State
* Top 10 Cities by Sales
* Sales Distribution by Food Type (Veg vs Non-Veg)

## Key Skills Demonstrated

MySQL, SQL Analytics, Data Cleaning, Data Validation, Data Modeling, Star Schema Design, ETL Concepts, Python, Pandas, NumPy, Matplotlib, Seaborn, Plotly, Business Intelligence, KPI Development, Exploratory Data Analysis (EDA), Data Visualization, and Business Insights Generation.

This project showcases a complete data analytics workflow, starting from raw data preparation and database design to business analysis and interactive visual storytelling.

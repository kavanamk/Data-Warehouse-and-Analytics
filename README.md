# Data-Warehouse-and-Analytics

An end-to-end data warehouse and analytics project built on Snowflake, modeled after a supply chain and manufacturing operations. Raw data is ingested, cleaned, and transformed using dbt in Sonwflake Data Warehouse, across a standard bronze-silver-gold ETL architecture, then surfaced through business dashboards in Tableau and Snowsight.

# Demo


https://github.com/user-attachments/assets/3d44e628-5f50-4963-936d-c4b7cff99445



### What This Project Does

ETL & Data Modeling
Raw CSV data from two public datasets is loaded into Snowflake's Bronze layer as-is, then transformed through Silver (cleaned, typed, renamed) and Gold (aggregated business metrics) using SQL. The Gold layer follows a star schema — fact tables joined to shared dimension tables- optimized for dashboard queries.


The pipeline separates raw ingestion from transformation logic. Bronze preserves the source data untouched, Silver handles all type casting, null handling, and column standardization, and Gold produces the final business-ready tables that power every dashboard.

###Tech Stack
Snowflake (data warehouse), SQL (transformations), SnowSQL CLI (data loading), Tableau (executive dashboards), Snowsight (operational dashboards), dbt Cloud (mart-layer models), GitHub (version control).

# Data Story

Dashboard 1 — Executive Sales Summary

$23.2M in total revenue across 101K orders, but the story is in what happened after 2016.
![Revenue](https://github.com/user-attachments/assets/4ea65025-a85c-40a2-aec3-4436135967c3)

Revenue peaked sharply in 2016 and has been declining since, dropping close to zero by 2018. Despite strong top-line numbers, the overall profit margin sits at just $93K - a signal that discounting or high COGS is compressing margins. Oceania leads all regions in revenue, followed by Central America and Western USA. The Consumer segment is the dominant buyer, making up the majority of the customer pie. On the product side, Fishing, Cleats, and Camping & Hiking are the top three profitable categories - all showing positive margins, while Computers lag at the bottom.

Dashboard 2 — Manufacturing & Machine Health

Fleet health score of 3.39 out of 100. 118 machines are in danger. The data tells us exactly why.
![MH](https://github.com/user-attachments/assets/4112b96e-f03f-4ccb-8f7b-34f0d2164a16)

The heatmap is the key insight: machines with High tool wear run failure rates of 10.96% (Type H), 10.5% (Type L), and 10.58% (Type M) -roughly 5x higher than Low wear machines. Type L machines account for the most total failures by a wide margin (250+), followed by Type M. Looking at failure causes, Heat Dissipation, Overstrain, and Power Failure each account for ~100 failures, while Tool Wear and Random failures are lower but present across all types. The line chart is the clearest signal: failure rate stays flat until tool wear crosses 150 minutes, then spikes exponentially toward 100% as wear approaches 250 minutes. This is a predictive maintenance opportunity -machines can be flagged before they fail.
Snowflake Link-> https://app.snowflake.com/lrgpcjv/fn69555/#/manufacturing-and-machine-health-dZPU8c3xN

Dashboard 3 — Customer Performance

18,296 customers generating $23.2M in revenue — but not all of them are profitable.

![CP](https://github.com/user-attachments/assets/574538bb-eb80-4edd-828b-4ccdd32c3b9e)

The average order value sits at $228, with top customers like Kenneth Smith and Betty Phillips each driving over $6,700 in revenue individually. The Consumer segment dominates by a wide margin at ~$13M, nearly double Corporate's ~$7M, with Home Office trailing at ~$2M. The leaderboard tells a more nuanced story — several high-revenue Corporate customers like Kelly Smith ($6,485) and Rebecca Stewart ($6,349) are actually running negative profit margins of -6.2% and -9.45% respectively, meaning Aptiv is losing money on them despite strong order volumes. The most valuable customers by profit are Betty Phillips (22.1% margin) and Catherine Smith (24.2% margin), both from the Consumer segment. Customers are primarily concentrated in the US and Puerto Rico, with lifespans ranging from 500 to nearly 1,000 days — suggesting a loyal but thin customer base that needs margin protection.

Snowflake Link -> https://app.snowflake.com/lrgpcjv/fn69555/#/aptiv-customer-dDLUH6eZg

# Datasets

DataCo Smart Supply Chain — 180K rows, orders, customers, shipping, revenue
AI4I 2020 Predictive Maintenance — 10K rows, machine sensors, failure types

Both datasets are available on Kaggle.

# Architecture
Bronze (raw)  →  Silver (cleaned)  →  Gold (business metrics)
LayerTablesBronzeRAW_SUPPLY_CHAIN, RAW_MAINTENANCESilverSTG_ORDERS, STG_CUSTOMERS, STG_PRODUCTS, STG_MACHINE_EVENTSGoldDIM_DATE, DIM_CUSTOMER, DIM_PRODUCT, FACT_SALES_MONTHLY, FACT_SUPPLY_CHAIN, FACT_PRODUCTION_QUALITY, FACT_CUSTOMER_PERFORMANCE



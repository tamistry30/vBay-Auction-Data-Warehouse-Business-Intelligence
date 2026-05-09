# 🏷️ vBay Auction Data Warehouse & Business Intelligence

A cloud-native data warehouse built on **AWS S3, AWS Glue, Snowflake, and dbt** to centralize and analyze auction platform data, surfacing insights on bidding trends, category performance, and regional engagement through interactive Power BI dashboards.

---

## 🗂️ Project Overview

vBay is an eBay-like online auction platform. This project transforms raw, fragmented auction data into a unified, analytics-ready data warehouse using a **Medallion Architecture (Bronze/Silver/Gold)** and a **star-schema dimensional model**, enabling stakeholders to make data-driven decisions on pricing, inventory, and user engagement.

**Key business questions answered:**
- What is the auction success rate across categories?
- Which item types receive the most bids?
- Which cities have the highest bidder engagement?
- What drives unsold item rates in categories like Collectables and Antiques?

---

## 🏗️ Architecture

```
Raw CSV Data (S3)
      ↓
  AWS Glue (ETL)
      ↓
Snowflake (3-tier: Raw → Staging → Star Schema)
      ↓
   dbt (Data Models)
      ↓
Power BI (Dashboards)
```

**Medallion Layers:**
- **Bronze (Raw):** Ingested CSV files: bids, items, users, ratings, zipcodes
- **Silver (Staging):** Cleaned, deduplicated, normalized, ZIP-enriched
- **Gold (Star Schema):** Fact and dimension tables optimized for analytics

---

## 📐 Dimensional Model

### Fact Tables

| Table | Type | Granularity | Key Metrics |
|---|---|---|---|
| `fact_bids` | Transaction | One row per bid | bid_amount, bid_time |
| `fact_items` | Accumulating Snapshot | One row per listed item | listing_price, final_price, num_bids |
| `fact_auction_status` | Periodic Snapshot | Item status per time period | inventory_level, reorder_count |

### Dimension Tables

| Table | Description | Key Attributes |
|---|---|---|
| `dim_bidder` | Bidder information | bidder_id, zip_code, city |
| `dim_item` | Item catalog | item_id, item_type, category, listing_duration |
| `dim_time` | Time intelligence | date_id, day, month, quarter, year |

---

## 📊 Power BI Dashboard Highlights

| KPI | Value |
|---|---|
| Average Bid Amount | $1.73K |
| Auction Success Rate | 17.65% |
| Total Bids Analyzed | 236 |
| Total Ratings | 64 |

**Visuals included:**
- User-wise average bid value and total bids
- Bids and ratings by city (North P., Chattanooga, San Jose)
- Breakdown of unsold items by category
- Distribution of total bids by item type (Collectables lead at 45.83%)

---

## 🛠️ Tech Stack

| Layer | Tools |
|---|---|
| Storage | AWS S3 |
| ETL | AWS Glue, PySpark, SQL, Python |
| Data Warehouse | Snowflake |
| Data Modeling | dbt (star schema) |
| BI & Visualization | Power BI (DAX, Power Query) |
| Database | PostgreSQL |

---

## 📁 Repository Structure

```
├── vbay_warehouse.sql       # Snowflake SQL: setup, staging tables, business queries
├── README.md                # Project documentation
```

---

## 🔍 SQL Scripts Included

1. Warehouse, database, and raw schema setup
2. Raw layer table creation (Users, Bids, Items, Ratings, Zipcodes)
3. Auction success rate calculation
4. Top 10 bidders by engagement
5. Item type popularity analysis
6. City-wise bidding and rating activity
7. Sold vs. unsold items by category
8. Bidding activity over time

---

## 🚀 How to Run

1. Set up a Snowflake account and create a warehouse
2. Run `vbay_warehouse.sql` in order: setup first, then table creation, then queries
3. Load your CSV data files into the raw tables via Snowflake's `COPY INTO` command
4. Connect Snowflake to Power BI using the Snowflake connector
5. Import the dashboard and refresh data

---

## 📈 Key Insights

- **17.65% auction success rate** highlights pricing and targeting improvement opportunities
- **Collectables dominate** with 45.83% of total bids but also have the highest unsold rate
- **North P. and Chattanooga** show the highest regional bid volume, strong targets for geo-personalized campaigns
- Top bidders like Ray Ovlight and Otto Moni drive disproportionate bid activity

---

## 👥 Contributors

- **Tejas Mistry** - Data Engineer & BI Analyst (data profiling, transformation logic, Power BI dashboards)
- **Saarthak Joshi** - Data Warehouse Architect & ETL Developer (star schema design, SQL ETL pipelines)

---

## 📄 License

MIT License

-- ============================================================
-- vBay Auction Data Warehouse - SQL Implementation
-- Project: Designing an eBay-Like Data Warehouse
-- Team: Fact Finders | Tejas Mistry & Saarthak Joshi
-- Course: IST 722 Data Warehouse | Syracuse University
-- ============================================================


-- ============================================================
-- 1. SETUP: Data Warehouse, Database, and Raw Schema
-- ============================================================

-- Create the warehouse
CREATE WAREHOUSE my_warehouse;

-- Create the database
CREATE DATABASE auctions_db;

-- Create the schema
CREATE SCHEMA auction_db.raw;


-- ============================================================
-- 2. TABLE CREATION: Raw Layer (Staging Zone)
-- ============================================================

-- Users table
CREATE TABLE auction_db.raw.Users (
    user_id        INT,
    user_email     STRING,
    user_firstname STRING,
    user_lastname  STRING,
    user_zip_code  INT
);

-- Bids table
CREATE TABLE auction_db.raw.Bids (
    bid_id       INT,
    bid_user_id  INT,
    bid_item_id  INT,
    bid_datetime STRING,
    bid_amount   FLOAT,
    bid_status   STRING
);

-- Items table
CREATE OR REPLACE TABLE auction_db.raw.items (
    item_id              INT,
    item_name            STRING,
    item_type            STRING,
    item_description     STRING,
    item_reserve         FLOAT,
    item_enddate         STRING,
    item_sold            INT,
    item_seller_user_id  INT,
    item_buyer_user_id   FLOAT,
    item_soldamount      FLOAT
);

-- Ratings table
CREATE TABLE auction_db.raw.Ratings (
    rating_id          INT,
    rating_by_user_id  INT,
    rating_for_user_id INT,
    rating_astype      STRING,
    rating_value       INT,
    rating_comment     STRING
);

-- Zipcodes table
CREATE TABLE auction_db.raw.Zipcodes (
    zip_code  INT,
    zip_city  STRING,
    zip_state STRING,
    zip_lat   FLOAT,
    zip_lng   FLOAT
);


-- ============================================================
-- 3. BUSINESS PROBLEM: Auction Success Rate
-- Calculates % of successful auctions (item sold and sold amount >= reserve)
-- ============================================================

SELECT
    COUNT(*) AS total_auctions,
    SUM(CASE WHEN item_sold = 1 AND item_soldamount >= item_reserve THEN 1 ELSE 0 END) AS successful_auctions,
    ROUND(
        100.0 * SUM(CASE WHEN item_sold = 1 AND item_soldamount >= item_reserve THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS success_rate_percentage
FROM auction_db.raw.items;


-- ============================================================
-- 4. BUSINESS PROBLEM: User Behavior and Bid Engagement
-- Top 10 bidders by total bids and their average bid amount
-- ============================================================

SELECT
    u.user_id,
    u.user_firstname || ' ' || u.user_lastname AS bidder_name,
    COUNT(b.bid_id)                            AS total_bids,
    ROUND(AVG(b.bid_amount), 2)                AS avg_bid_amount
FROM auction_db.raw.Bids b
JOIN auction_db.raw.Users u ON b.bid_user_id = u.user_id
GROUP BY u.user_id, u.user_firstname, u.user_lastname
ORDER BY total_bids DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


-- ============================================================
-- 5. BUSINESS PROBLEM: Item Type Popularity
-- Number of bids per item type
-- ============================================================

SELECT
    i.item_type,
    COUNT(b.bid_id) AS total_bids
FROM auction_db.raw.Bids b
JOIN auction_db.raw.items i ON b.bid_item_id = i.item_id
GROUP BY i.item_type
ORDER BY total_bids DESC;


-- ============================================================
-- 6. BUSINESS PROBLEM: City-Wise Bidding & Rating Activity
-- Total bids by city and associated user ratings
-- ============================================================

SELECT
    z.zip_city,
    r.rating_value,
    COUNT(b.bid_id) AS total_bids
FROM auction_db.raw.Bids b
JOIN auction_db.raw.Users   u ON b.bid_user_id        = u.user_id
JOIN auction_db.raw.Zipcodes z ON u.user_zip_code      = z.zip_code
JOIN auction_db.raw.Ratings  r ON u.user_id            = r.rating_for_user_id
GROUP BY z.zip_city, r.rating_value
ORDER BY total_bids DESC;


-- ============================================================
-- 7. BUSINESS PROBLEM: Sold vs. Unsold Items by Category
-- Auction outcome stats by item type
-- ============================================================

SELECT
    item_type,
    ROUND(AVG(item_reserve),    2) AS avg_reserve_price,
    ROUND(AVG(item_soldamount), 2) AS avg_sold_price,
    COUNT(CASE WHEN item_sold = 1 THEN 1 END) AS sold_count,
    COUNT(CASE WHEN item_sold = 0 THEN 1 END) AS unsold_count
FROM auction_db.raw.items
GROUP BY item_type
ORDER BY sold_count DESC;


-- ============================================================
-- 8. BUSINESS PROBLEM: Bidding Activity Over Time
-- Tracks total bids per item and shows when the auction ends
-- ============================================================

SELECT
    i.item_id,
    i.item_type,
    COUNT(b.bid_id) AS total_bids,
    i.item_enddate
FROM auction_db.raw.items i
JOIN auction_db.raw.Bids b ON i.item_id = b.bid_item_id
GROUP BY i.item_id, i.item_type, i.item_enddate
ORDER BY i.item_enddate;

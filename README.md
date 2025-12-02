# Amazon Echo Dot (2nd Gen) 2017 – Interactive Customer Reviews Dashboard

*(https://lookerstudio.google.com/reporting/30e6eb77-2818-4174-b084-cc16b6917053)*

## Live Dashboard (Public – No Login Required)
https://lookerstudio.google.com/reporting/30e6eb77-2818-4174-b084-cc16b6917053

## Project Overview
This is a **fully interactive, production-ready Looker Studio dashboard** built from **6,855 real Amazon customer reviews** of the **Amazon Echo Dot 2nd Generation** collected during its launch period (September – October 2017).

The dashboard tells the complete customer story:
- Massive launch success (64% 5-star)
- Color preference & satisfaction impact
- Review authenticity (97% verified)
- Daily, weekly, and monthly trends
- Sentiment evolution over time
- The critical October 7–9 rating dip (likely firmware issue)

## Key Business Insights

| Insight                                   | Value / Observation                                      | Recommendation                                      |
|-------------------------------------------|----------------------------------------------------------|-----------------------------------------------------|
| Overall Satisfaction                      | **4.21 / 5** – 64% gave 5 stars                          | One of the most loved smart speakers of 2017        |
| Dominant Color                            | **Black = 79%** of purchases (White = 21%)               | Stock more Black; promote White to balance inventory|
| Review Trustworthiness                    | **97% Verified Purchase** (avg 4.22 vs 3.90 non-verified)| Extremely credible dataset                          |
| Launch Wave                               | Sep ≈ 4,700 reviews → Oct ≈ 2,100                        | Classic promo-driven spike                          |
| Peak Review Days                          | Tuesday & Wednesday (highest volume & rating)           | Best days for follow-up campaigns                   |
| Angry Customers Write More                | 1-star reviews ≈ **3× longer** than 5-star               | Long reviews = early warning system                 |
| October 7–9 Issue                         | Sharp rating drop + negative sentiment spike             | Likely firmware / multi-room audio change           |

## Dashboard Features
- Fully interactive filters (Rating, Verified, Color, Date range, Day of week)
- Click-to-filter across all charts
- Amazon-style blue/orange theme with emojis
- Mobile-responsive
- 10 professional charts (Scorecards, Donut, Bar, Time series combo, Stacked area, etc.)

## Data Source
PostgreSQL table: `Amazon_Echo_Reviews`  
Original columns cleaned: `Review_Useful_Count` and `Declaration_Text` dropped.

## ALL SQL Queries Used in This Project

```sql
-- Table creation and cleanup
CREATE TABLE Amazon_Echo_Reviews (
    Pageurl VARCHAR,
    Title TEXT,
    Review_Text TEXT,
    Review_Color VARCHAR,
    User_Verified VARCHAR,
    Review_Date DATE,
    Review_Useful_Count INT,
    Configuration_Text VARCHAR,
    Rating INT,
    Declaration_Text VARCHAR
);

ALTER TABLE Amazon_Echo_Reviews
DROP COLUMN Review_Useful_Count,
DROP COLUMN Declaration_Text;

-- Clean nulls in user_verified
UPDATE Amazon_Echo_Reviews
SET user_verified = 'NonUser Verified'
WHERE user_verified IS NULL;

-- 1. Overall Average Rating (Scorecard)
SELECT ROUND(AVG(rating), 2) AS avg_rating FROM Amazon_Echo_Reviews;

-- 2. Total Reviews (Scorecard)
SELECT COUNT(*) AS total_reviews FROM Amazon_Echo_Reviews;

-- 3. Rating Distribution (Donut / Pie)
SELECT rating,
       COUNT(*) AS review_count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percentage
FROM Amazon_Echo_Reviews
GROUP BY rating
ORDER BY rating;

-- 4. Color Preference + Avg Rating Impact (Grouped Bar)
SELECT review_color,
       COUNT(*) AS total_reviews,
       ROUND(AVG(rating), 2) AS avg_rating
FROM Amazon_Echo_Reviews
WHERE review_color IS NOT NULL
GROUP BY review_color
ORDER BY total_reviews DESC;

-- 5. Verified vs Non-Verified (Pie Chart)
SELECT COALESCE(user_verified, 'Non-Verified') AS verification_status,
       COUNT(*) AS reviews,
       ROUND(AVG(rating), 2) AS avg_rating
FROM Amazon_Echo_Reviews
GROUP BY verification_status;

-- 6. Daily Volume + Average Rating (Combo Chart)
SELECT DATE_TRUNC('day', review_date) AS review_day,
       COUNT(*) AS reviews_that_day,
       ROUND(AVG(rating), 2) AS avg_daily_rating
FROM Amazon_Echo_Reviews
GROUP BY review_day
ORDER BY review_day;

-- 7. Positive / Negative / Neutral Over Time (Stacked Area)
WITH sentiment AS (
  SELECT *,
         CASE 
           WHEN LOWER(review_text) SIMILAR TO '%(love|great|awesome|excellent|amazing|perfect|best|easy|fun)%' THEN 'Positive'
           WHEN LOWER(review_text) SIMILAR TO '%(not work|disappoint|hate|terrible|waste|return|problem|died|broke|fail)%' THEN 'Negative'
           ELSE 'Neutral' 
         END AS mood
  FROM Amazon_Echo_Reviews
)
SELECT DATE_TRUNC('day', review_date) AS day,
       mood,
       COUNT(*) AS reviews
FROM sentiment
GROUP BY day, mood
ORDER BY day;

-- 8. Rating by Day of Week (Horizontal Bar)
SELECT TRIM(TO_CHAR(review_date, 'Day')) AS day_name,
       ROUND(AVG(rating), 2) AS avg_rating,
       COUNT(*) AS reviews
FROM Amazon_Echo_Reviews
GROUP BY day_name, EXTRACT(DOW FROM review_date)
ORDER BY EXTRACT(DOW FROM review_date);

-- 9. Monthly Review Volume (Column Chart)
SELECT DATE_TRUNC('month', review_date) AS month,
       COUNT(*) AS review_count
FROM Amazon_Echo_Reviews
GROUP BY month
ORDER BY month;

-- 10. Average Review Length (Scorecard – passion proxy)
SELECT ROUND(AVG(LENGTH(review_text)), 0) AS avg_review_length_chars
FROM Amazon_Echo_Reviews;

-- Bonus: Review Length vs Rating (for future scatter chart)
SELECT rating,
       ROUND(AVG(LENGTH(review_text))) AS avg_characters,
       COUNT(*) AS reviews
FROM Amazon_Echo_Reviews
GROUP BY rating
ORDER BY rating;

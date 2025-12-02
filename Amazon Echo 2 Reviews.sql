CREATE TABLE Amazon_Echo_Reviews
  (
    Pageurl	VARCHAR,
    Title TEXT,
	Review_Text TEXT,
	Review_Color VARCHAR,
	User_Verified VARCHAR,
	Review_Date	DATE,
	Review_Useful_Count	INT,
	Configuration_Text VARCHAR,
	Rating INT,
	Declaration_Text VARCHAR		
	);
SELECT * FROM Amazon_Echo_Reviews;

ALTER TABLE Amazon_Echo_Reviews
DROP COLUMN Review_Useful_Count,
DROP COLUMN Declaration_Text;

---NULL in user_verified
UPDATE Amazon_Echo_Reviews
SET user_verified = 'NonUser Verified'
WHERE user_verified IS NULL;


---The average customer satisfaction score
SELECT
ROUND(AVG(rating), 2) AS avg_rating
FROM Amazon_Echo_Reviews;

---Which product color customers prefe
SELECT 
  review_color, 
  COUNT(*) AS total
FROM Amazon_Echo_Reviews
GROUP BY Review_Color
ORDER BY total DESC;

---Trustworthiness of reviews
SELECT 
 User_Verified, 
 COUNT(*) AS total
FROM Amazon_Echo_Reviews
GROUP BY User_Verified;

---How detailed people write their reviews IN WHICH MORE DETAILED REVIEWS MEAN
SELECT AVG(LENGTH(review_text)) AS avg_review_length
FROM Amazon_Echo_Reviews;

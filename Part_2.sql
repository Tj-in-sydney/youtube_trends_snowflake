USE DATABASE assignment_1;

/* Q1 */

SELECT DISTINCT category_title
FROM table_youtube_category
GROUP BY country, category_title
HAVING count(*)>1;

/* Q2 */
SELECT category_title
FROM table_youtube_category
GROUP BY category_title
HAVING COUNT(DISTINCT country) = 1;

/* Q3 */
SELECT DISTINCT categoryid
FROM table_youtube_final
WHERE category_title IS NULL;

/* Q4 Updated 1,563 rows */
UPDATE table_youtube_final
    SET category_title = (SELECT category_title
    FROM table_youtube_category WHERE categoryID = '29')
WHERE category_title IS NULL;

/* Q5 */
SELECT title from table_youtube_final
where channeltitle is NULL;

/* Q6 = 32,081 rows */
DELETE FROM table_youtube_final
WHERE video_id = '#NAME?';

/* Q7 = 37,466 rows */
CREATE OR REPLACE TABLE table_youtube_duplicates AS
SELECT *
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY country, video_id, trending_date
        ORDER BY view_count
        ) AS row_number
    FROM table_youtube_final
) 
WHERE row_number > 1;

/* Q8 */
DELETE FROM table_youtube_final f
USING table_youtube_duplicates d
WHERE f.id = d.id
  AND f.video_id = d.video_id
  AND f.title = d.title
  AND f.country = d.country
  AND f.trending_date = d.trending_date
  AND f.view_count = d.view_count;

/* Q9 */
SELECT COUNT(*) FROM table_youtube_final;
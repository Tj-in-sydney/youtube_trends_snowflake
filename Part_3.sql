/* Q1 */
SELECT *
FROM (SELECT 
    COUNTRY,
    TITLE,
    CHANNELTITLE,
    VIEW_COUNT,
    RANK() OVER (PARTITION BY COUNTRY ORDER BY VIEW_COUNT DESC) as rk
FROM table_youtube_final
WHERE category_title = 'Gaming'
AND trending_date = '2024-04-01')
WHERE rk < 4
ORDER BY COUNTRY, rk;

/* Q2 */
SELECT 
    country,
    count(*) as CT
FROM (SELECT
    DISTINCT video_id,
    title,
    country
    FROM table_youtube_final
) sub1
WHERE LOWER(sub1.title) LIKE '%bts%'
GROUP BY COUNTRY
ORDER BY CT DESC;

/* Q3 */
SELECT 
    COUNTRY,
    TO_CHAR(DATE_TRUNC('month', trending_date), 'YYYY-MM-01') AS YEAR_MONTH,
    TITLE,
    CHANNELTITLE,
    CATEGORY_TITLE,
    VIEW_COUNT,
    TRUNC(LIKES::NUMERIC / NULLIF(VIEW_COUNT, 0) * 100, 2) AS LIKES_RATIO
FROM (SELECT 
        COUNTRY,
        TITLE,
        CHANNELTITLE,
        CATEGORY_TITLE,
        VIEW_COUNT,
        LIKES,
        trending_date,
        RANK() OVER (PARTITION BY COUNTRY, DATE_TRUNC('month', trending_date) ORDER BY VIEW_COUNT DESC) AS rk
    FROM table_youtube_final
    WHERE EXTRACT(YEAR FROM trending_date) = 2024
    and country is not null
) sub1
WHERE sub1.rk = 1
ORDER BY YEAR_MONTH, COUNTRY;

/* Q4 */
WITH Counts AS (
    SELECT 
    country,
    category_title,
    total_category_video,
    SUM(total_category_video) OVER (PARTITION BY country) AS total_country_video,
    RANK() OVER (PARTITION BY country ORDER BY total_category_video DESC) AS rk
    FROM (
     SELECT
        country,
        category_title,
        COUNT(DISTINCT video_id) AS total_category_video
     FROM table_youtube_final
     WHERE EXTRACT(YEAR FROM trending_date) >= 2022
     and country is not null
     GROUP BY country, category_title
    )
)

SELECT 
    country,
    Category_title,
    total_category_video,
    total_country_video,
    TRUNC(total_category_video::NUMERIC / NULLIF(total_country_video, 0) * 100, 2) AS PERCENTAGE
FROM counts c
WHERE c.rk = 1
ORDER BY CATEGORY_TITLE, COUNTRY;

/* Q5 */    
SELECT 
    channelTitle,
    COUNT(DISTINCT video_id) AS counts
FROM table_youtube_final
GROUP BY channelTitle
ORDER BY counts DESC
LIMIT 1;
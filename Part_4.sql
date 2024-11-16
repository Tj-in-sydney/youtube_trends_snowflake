USE DATABASE assignment_1;

/* Comparsion each categories by year */
SELECT 
    EXTRACT(YEAR FROM trending_date) AS year,
    CATEGORY_TITLE,
    COUNT(DISTINCT CHANNELTITLE) AS Channel_count,
    SUM(VIEW_COUNT) AS total_view_count,
    TRUNC(total_view_count::NUMERIC / NULLIF(Channel_count, 0), 2) AS Channel_View_ratio,
    SUM(LIKES) AS total_likes
FROM table_youtube_final
WHERE EXTRACT(YEAR FROM trending_date) >= 2022
AND CATEGORY_TITLE NOT IN ('Entertainment', 'Music')
GROUP BY year,CATEGORY_TITLE
ORDER BY year, total_view_count DESC;

/* COUNTRY / CATEGORY / TOTAL VIEW COUNT  */

WITH YearlyData AS (
    SELECT 
        EXTRACT(YEAR FROM trending_date) AS year,
        CATEGORY_TITLE,
        COUNT(DISTINCT CHANNELTITLE) AS channel_count,
        SUM(VIEW_COUNT) AS total_view_count
    FROM table_youtube_final
    WHERE EXTRACT(YEAR FROM trending_date) IN (2022, 2023)
    GROUP BY EXTRACT(YEAR FROM trending_date), CATEGORY_TITLE
)
SELECT 
    yd_2023.CATEGORY_TITLE,
    yd_2022.channel_count AS channel_count_2022,
    yd_2023.channel_count AS channel_count_2023,
    yd_2023.channel_count - yd_2022.channel_count AS channel_count_change,
    yd_2022.total_view_count AS total_view_count_2022,
    yd_2023.total_view_count AS total_view_count_2023,
    yd_2023.total_view_count - yd_2022.total_view_count AS view_count_change,
    TRUNC(view_count_change::NUMERIC / NULLIF(total_view_count_2022, 0) * 100, 2) AS Change_ratio
FROM YearlyData yd_2022
INNER JOIN YearlyData yd_2023 ON yd_2022.CATEGORY_TITLE = yd_2023.CATEGORY_TITLE AND yd_2022.year = 2022 AND yd_2023.year = 2023
WHERE yd_2022.CATEGORY_TITLE NOT IN ('Entertainment', 'Music')
ORDER BY channel_count_change DESC, view_count_change DESC;

/* Counts by Category_title, video_counts */
WITH MaxViewCounts AS (
    SELECT 
        COUNTRY,
        TITLE,
        CHANNELTITLE,
        CATEGORY_TITLE,
        MAX(VIEW_COUNT) AS max_view_count,
        TO_CHAR(DATE_TRUNC('month', trending_date), 'YYYY-MM-01') AS YEAR_MONTH,
        TRUNC(MAX(LIKES)::NUMERIC / NULLIF(MAX(VIEW_COUNT), 0) * 100, 2) AS LIKES_RATIO
    FROM table_youtube_final
    WHERE 
        EXTRACT(YEAR FROM trending_date) >= 2023
        AND COUNTRY IS NOT NULL
        AND CATEGORY_TITLE NOT IN ('Music', 'Entertainment')
        AND TITLE NOT ILIKE '%Trailer%'
        AND TITLE NOT ILIKE '%M/V%'
        AND TITLE NOT ILIKE '%TEASER%'
        AND CHANNELTITLE NOT ILIKE '%Beast%'
        AND CHANNELTITLE NOT ILIKE '%BABY%'
    GROUP BY 
        COUNTRY, TITLE, CHANNELTITLE, CATEGORY_TITLE, YEAR_MONTH
),
RankedVideos AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY COUNTRY, YEAR_MONTH ORDER BY max_view_count DESC) AS rk,
    FROM MaxViewCounts
)
SELECT 
    CATEGORY_TITLE,
    COUNT(CATEGORY_TITLE) AS Category_count,
    SUM(max_view_count) AS TOTAL_VIEW_COUNT,
    COUNT(DISTINCT CHANNELTITLE) AS Channel_count,
    COUNT(DISTINCT TITLE) AS video_count
FROM RankedVideos
WHERE rk <= 5
GROUP BY CATEGORY_TITLE
ORDER BY Category_count DESC;

/* Counts by Country, Channel_count, video_counts */
WITH MaxViewCounts AS (
    SELECT 
        COUNTRY,
        TITLE,
        CHANNELTITLE,
        CATEGORY_TITLE,
        MAX(VIEW_COUNT) AS max_view_count,
        TO_CHAR(DATE_TRUNC('month', trending_date), 'YYYY-MM-01') AS YEAR_MONTH,
        TRUNC(MAX(LIKES)::NUMERIC / NULLIF(MAX(VIEW_COUNT), 0) * 100, 2) AS LIKES_RATIO
    FROM table_youtube_final
    WHERE 
        EXTRACT(YEAR FROM trending_date) >= 2023
        AND COUNTRY IS NOT NULL
        AND CATEGORY_TITLE NOT IN ('Music', 'Entertainment')
        AND TITLE NOT ILIKE '%Trailer%'
        AND TITLE NOT ILIKE '%M/V%'
        AND TITLE NOT ILIKE '%TEASER%'
        AND CHANNELTITLE NOT ILIKE '%Beast%'
        AND CHANNELTITLE NOT ILIKE '%BABY%'
    GROUP BY 
        COUNTRY, TITLE, CHANNELTITLE, CATEGORY_TITLE, YEAR_MONTH
),
RankedVideos AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY COUNTRY, YEAR_MONTH ORDER BY max_view_count DESC) AS rk,
    FROM MaxViewCounts
)
SELECT 
    COUNTRY,
    CATEGORY_TITLE,
    SUM(max_view_count) AS TOTAL_VIEW_COUNT,
    COUNT(DISTINCT CHANNELTITLE) AS Channel_count,
    COUNT(DISTINCT TITLE) AS video_count
FROM RankedVideos
WHERE rk <= 5
GROUP BY COUNTRY, CATEGORY_TITLE
ORDER BY COUNTRY, video_count DESC;

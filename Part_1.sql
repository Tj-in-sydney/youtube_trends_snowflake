CREATE DATABASE assignment_1;

USE DATABASE assignment_1;

CREATE OR REPLACE STAGE stage_assignment
URL='azure://tjinsydney.blob.core.windows.net/youtube-trending'
CREDENTIALS=(AZURE_SAS_TOKEN='')
;

list @stage_assignment;

CREATE OR REPLACE FILE FORMAT file_format_csv
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
NULL_IF = ('\\N', 'NULL', 'NUL', '')
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
;

CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending 
(
video_id varchar as (value:c1::varchar),
title varchar as (value:c2::varchar),
publishedAt date as (value:c3::date),
channelId varchar as (value:c4::varchar),
channelTitle varchar as (value:c5::varchar),
categoryId int as (value:c6::int),
trending_date date as (value:c7::date),
view_count int as (value:c8::int),
likes int as (value:c9::int),
dislikes int as (value:c10::int),
comment_count int as (value:c11::int)
)
WITH LOCATION = @stage_assignment
FILE_FORMAT = file_format_csv
PATTERN = '^.._youtube_trending_data\.csv';

CREATE OR REPLACE TABLE table_youtube_trending AS
SELECT
    video_id,
    title,
    publishedAt,
    channelId,
    channelTitle,
    categoryId,
    trending_date,
    view_count,
    likes,
    dislikes,
    comment_count,
    split_part(metadata$filename, '_', 1)::VARCHAR AS Country
FROM ex_table_youtube_trending;
    
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_category
WITH LOCATION = @stage_assignment
FILE_FORMAT = (TYPE=JSON)
PATTERN = '.*[.]json';

CREATE OR REPLACE TABLE table_youtube_category AS
SELECT
    split_part(metadata$filename, '_', 1)::VARCHAR AS Country,
    l.value:id::DECIMAL(32, 0) AS CategoryId,
    l.value:snippet:title::VARCHAR AS Category_title
FROM
    ex_table_youtube_category,
    LATERAL FLATTEN(input => ex_table_youtube_category.value:items) l;


CREATE OR REPLACE TABLE table_youtube_final AS
SELECT
    UUID_STRING() as id,
    t.video_id as video_id,
    t.title as title,
    t.publishedAt as publishedAt,
    t.channelId as channelId,
    t.channelTitle as channelTitle,
    t.categoryId as categoryId,
    c.category_title as category_title,
    t.trending_date as trending_date,
    t.view_count as view_count,
    t.likes as likes,
    t.dislikes as dislikes,
    t.comment_count as comment_count,
    c.country as country
FROM table_youtube_trending t
LEFT JOIN table_youtube_category c ON t.country = c.country and t.CATEGORYID = c.CATEGORYID;

SELECT count(*) from table_youtube_final;
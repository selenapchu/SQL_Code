COPY retail_sales 
FROM 'C:\Users\Selena Chu\Downloads\us_retail_sales.csv' -- change to the location you saved the csv file
DELIMITER ','
CSV HEADER
;

SELECT sales_month
,sales
FROM retail_sales
WHERE kind_of_business = 'Retail and food services sales, total'
ORDER BY 1
;

--order by 1 = first column in select

SELECT date_part('year',sales_month) as sales_year ,sum(sales) as sales
FROM retail_sales
WHERE kind_of_business = 'Retail and food services sales, total'
GROUP BY 1   --will work only on some platforms (no on oracle)
ORDER BY 1
;

--extract() and to_char() are alternatives to date_part()


-- Comparing components
SELECT date_part('year',sales_month) as sales_year
,kind_of_business
,sum(sales) as sales
FROM retail_sales
WHERE kind_of_business in ('Book stores','Sporting goods stores','Hobby, toy, and game stores')
GROUP BY 1,2
ORDER BY 1,2
;

--if data for the three kinds of business for a given year were on the same row, would be easier to review (and to plot)   < try to do this on your own after seeing the queries below.

-- Monthly sales for two kinds of business:
SELECT sales_month
,kind_of_business
,sales
FROM retail_sales
WHERE kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
ORDER BY 1,2
;

--Reducing the number of rows, aggregating to year
SELECT date_part('year',sales_month) as sales_year
,kind_of_business
,sum(sales) as sales
FROM retail_sales
WHERE kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
GROUP BY 1,2
;

--pivoting, to get Men’s and Women’s on same row
SELECT date_part('year',sales_month) as sales_year
,sum(case when kind_of_business = 'Women''s clothing stores' then sales end) as womens_sales
,sum(case when kind_of_business = 'Men''s clothing stores' then sales end) as mens_sales
FROM retail_sales
WHERE kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
GROUP BY 1
ORDER BY 1
;

--Using above query as a sub-query to find difference between Men’s and Women’s sales for each year, both ways
SELECT sales_year
,womens_sales - mens_sales as womens_minus_mens
,mens_sales - womens_sales as mens_minus_womens
FROM
(
        SELECT date_part('year',sales_month) as sales_year
        ,sum(case when kind_of_business = 'Women''s clothing stores' then sales end) as womens_sales
        ,sum(case when kind_of_business = 'Men''s clothing stores' then sales end) as mens_sales
        FROM retail_sales
        WHERE kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
        and sales_month <= '2019-12-01'
        GROUP BY 1
) a
ORDER BY 1
;
-- ( w - m ) / m =  w/m -1

--It appears women’s clothing sells more. Next query focuses on Women’s - Men’s. And does not use a subquery.
SELECT date_part('year',sales_month) as sales_year
,sum(case when kind_of_business = 'Women''s clothing stores' then sales end) 
 - sum(case when kind_of_business = 'Men''s clothing stores' then sales end) as womens_minus_mens
FROM retail_sales
WHERE kind_of_business in ('Men''s clothing stores'
 ,'Women''s clothing stores')
and sales_month <= '2019-12-01'
GROUP BY 1
ORDER BY 1
;

--Earlier subquery being reused, to generate ratio of Women’s to Men’s clothing sales.

SELECT sales_year
,womens_sales / mens_sales as womens_times_of_mens
FROM
(
        SELECT date_part('year',sales_month) as sales_year
        ,sum(case when kind_of_business = 'Women''s clothing stores' then sales end) as womens_sales
        ,sum(case when kind_of_business = 'Men''s clothing stores' then sales end) as mens_sales
        FROM retail_sales
        WHERE kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
        and sales_month <= '2019-12-01'
        GROUP BY 1
) a
ORDER BY 1
;

--Women’s annual sales difference as a percentage of Men’s: (x-y)/ y * 100 =( x/y - 1) * 100
--Again using subquery technique.  (one advantage is that you can keep reusing the query you already wrote)
SELECT sales_year
,(womens_sales / mens_sales - 1) * 100 as womens_pct_of_mens
FROM
(
        SELECT date_part('year',sales_month) as sales_year
        ,sum(case when kind_of_business = 'Women''s clothing stores' 
                  then sales 
                  end) as womens_sales
        ,sum(case when kind_of_business = 'Men''s clothing stores' 
                  then sales 
                  end) as mens_sales
        FROM retail_sales
        WHERE kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
        and sales_month <= '2019-12-01'
        GROUP BY 1
) a
ORDER BY 1
;


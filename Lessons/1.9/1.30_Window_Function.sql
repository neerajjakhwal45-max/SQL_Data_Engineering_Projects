-- COUNT ROWS - Aggregations Only
SELECT 
    COUNT(*)
FROM 
    job_postings_fact;

-- Count Rows - Window Function

SELECT job_id,
COUNT(*) OVER ()
FROM job_postings_fact;

-- Partition BY - Find hourly salary
SELECT 
    job_id,
    job_title_short,
    company_id,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short, company_id
    )
FROM job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL
ORDER BY 
    RANDOM()
LIMIT 10;

SELECT 
    AVG(salary_hour_avg)
FROM 
    job_postings_fact;


-- ORDER BY - Ranking hourly salary

SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        ORDER BY salary_hour_avg DESC
    ) AS salary_rank
FROM job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL
ORDER BY 
    salary_hour_avg DESC
LIMIT 10;

-- PARTITION BY and ORDER BY - Running Average Hourly Salary
SELECT 
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    SUM(salary_hour_avg) OVER (
        PARTITION BY job_title_short,company_id
        ORDER BY job_posted_date DESC
    ) AS running_avg_hourly_by_title
FROM 
    job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL AND
    job_title_short = 'Data Engineer'
ORDER BY 
    job_title_short,
    job_posted_date
LIMIT 10;


--Partition by and Order by - Ranking by job_title_short

SELECT 
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        PARTITION BY job_title_short 
        ORDER BY salary_hour_avg DESC
    ) AS running_avg_hourly_by_title
FROM 
    job_postings_fact
WHERE 
    salary_hour_avg 
ORDER BY 
    salary_hour_avg DESC,
    job_title_short
LIMIT 10;


-- Ranking Functions - RANK() vs DENSE_RANK

SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    DENSE_RANK() OVER (
        ORDER BY salary_hour_avg DESC
    ) AS running_avg_hourly_by_title
FROM 
    job_postings_fact
WHERE 
    salary_hour_avg 
ORDER BY 
    salary_hour_avg DESC
LIMIT 20;

-- ROW_NUMBER() - Providing a new job_id
SELECT 
    *,
    ROW_NUMBER() OVER (
        ORDER BY job_posted_date
    )
FROM 
    job_postings_fact
ORDER BY
    job_posted_date
LIMIT 
    20;

-- LAG() - Time Based Comparison of Company Yearly Salary
SELECT 
    job_id,
    company_id,
    job_title,
    job_title_short,
    job_posted_date,
    salary_year_avg,
    LAG(salary_year_avg) OVER (PARTITION BY company_id
    ORDER BY job_posted_date) AS previous_posting_salary,
    salary_year_avg - LAG(salary_year_avg) OVER (
        PARTITION BY  company_id
        ORDER BY job_posted_date
    ) AS salary_change
FROM 
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 60;

-- LEAD()

SELECT 
    job_id,
    company_id,
    job_title,
    job_title_short,
    job_posted_date,
    salary_year_avg,
    LAG(salary_year_avg) OVER (PARTITION BY company_id
    ORDER BY job_posted_date) AS previous_posting_salary,
    salary_year_avg - LEAD(salary_year_avg) OVER (
        PARTITION BY  company_id
        ORDER BY job_posted_date
    ) AS salary_change
FROM 
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 60;

WITH monthly_jobs AS (

    SELECT
        DATE_TRUNC('month', job_posted_date) AS job_month,
        COUNT(*) AS total_jobs

    FROM job_postings_fact

    WHERE job_title_short = 'Data Engineer'

    GROUP BY job_month
)

SELECT
    job_month,
    total_jobs,

    LAG(total_jobs) OVER (
        ORDER BY job_month
    ) AS previous_month_jobs,

    total_jobs - LAG(total_jobs) OVER (
        ORDER BY job_month
    ) AS job_difference

FROM monthly_jobs

ORDER BY job_month;

WITH high_paying AS (
    SELECT 
        job_title_short,
        job_country,
        MAX(salary_year_avg) AS highest_salary
    FROM job_postings_fact
    WHERE job_title LIKE '%Data Engineer%'
    GROUP BY job_title_short,job_country
)
SELECT 
    job_country,
    job_title_short,
    highest_salary,
    RANK() OVER (PARTITION BY job_country ORDER BY highest_salary DESC) AS salary_rank
FROM high_paying
GROUP BY job_title_short,job_country,highest_salary
ORDER BY salary_rank ASC;


WITH high_paying AS (

    SELECT
        job_id,
        job_title,
        job_country,
        salary_year_avg,

        RANK() OVER (
            PARTITION BY job_country
            ORDER BY salary_year_avg DESC
        ) AS salary_rank

    FROM job_postings_fact

    WHERE job_title_short = 'Data Engineer'
      AND salary_year_avg IS NOT NULL
)

SELECT
    job_id,
    job_title,
    job_country,
    salary_year_avg,
    salary_rank

FROM high_paying

WHERE salary_rank <= 3

ORDER BY job_country, salary_rank;


WITH monthly_salary AS (
    SELECT 
        DATE_TRUNC('month',job_posted_date) AS job_month,
        AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    WHERE job_title_short = 'Data Engineer'
        AND salary_year_avg IS NOT NULL
    GROUP BY job_month
),
salary_comparison AS (
SELECT
    job_month,
    avg_salary,
    LAG(avg_salary) OVER (
        ORDER BY job_month
    ) AS previous_month_salary
FROM monthly_salary
)
SELECT 
    job_month,
    avg_salary,
    previous_month_salary,
    avg_salary - previous_month_salary AS salary_change,
    CASE
        WHEN previous_month_salary IS NULL THEN 'N/A'
        WHEN previous_month_salary < avg_salary THEN 'Increased'
        WHEN previous_month_salary > avg_salary THEN 'Decreased'
        ELSE 'No Change'
    END AS salary_trend
FROM salary_comparison
ORDER BY job_month;


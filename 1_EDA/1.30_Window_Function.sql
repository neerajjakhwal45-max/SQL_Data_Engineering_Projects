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
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short,company_id
    ) AS avg_salary_filtered
FROM 
    job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL
ORDER BY 
    RANDOM()
LIMIT 10;


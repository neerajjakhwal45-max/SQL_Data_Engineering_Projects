SELECT LOWER ('SQL');

SELECT UPPER ('sql');

SELECT LEFT ('SQL',2);

SELECT RIGHT ('SQL',2);

SELECT SUBSTRING ('SQL',2,1);

SELECT CONCAT('SQL', '-', 'FUNCTIONS');

SELECT 'SQL' || '-' || 'Functions';

SELECT TRIM ('        SQL ');

SELECT LTRIM ('  SQL      ');

SELECT RTRIM('   SQL   ');

SELECT REPLACE('SQL', 'Q', '-');

-- Final example - Cleanup this using Text  Functions.

WITH title_lower AS (
    SELECT 
        job_title,
        LOWER(TRIM(job_title)) AS job_title_clean
    FROM job_postings_fact
)
SELECT 
    job_title,
    CASE 
        WHEN job_title_clean LIKE '%Data%'
         AND job_title_clean LIKE '%Analsyt%' THEN 'Data Analyst'
        WHEN job_title_clean LIKE '%Data%'
         AND job_title_clean LIKE '%Scientist%' THEN 'Data Scientist'
        WHEN job_title_clean LIKE '%Data%' 
         AND job_title_clean LIKE '%Engineer%' THEN 'Data Engineer'
        ELSE 'Other'
    END AS job_title_category
FROM title_lower
ORDER BY RANDOM()
LIMIT 30;

SELECT NULLIF(10, 20);

SELECT 
    MEDIAN(NULLIF(salary_year_avg,0)),
    MEDIAN(NULLIF(salary_hour_avg,0))
FROM
    data_jobs.job_postings_fact
WHERE 
    salary_year_avg IS NOT NULL AND salary_hour_avg IS NOT NULL
GROUP BY salary_year_avg
LIMIT 10;

SELECT COALESCE(NULL,NULL,2);


SELECT 
    salary_year_avg,
    salary_year_avg
FROM job_postings_
WHERE salary_year_avg IS NOT NULL AND salary_hour_avg IS NOT NULL
LIMIT 10;

SHOW TABLES FROM data_jobs;


SELECT 
    salary_year_avg,
    salary_year_avg,
    COALESCE(salary_year_avg, salary_year_avg * 2080)
FROM 
    job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 10;


-- FINAL EXAMPLE - Simplify with Coalesce

SELECT
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_year_avg * 2080) AS standardized_salary,
    CASE
        WHEN COALESCE(salary_year_avg, salary_year_avg * 2080) IS NULL THEN 'Missing'
        WHEN COALESCE(salary_year_avg, salary_year_avg * 2080) < 75_000 THEN 'Low'
        WHEN COALESCE(salary_year_avg, salary_year_avg * 2080) <150_000 THEN 'Medium'
        ELSE 'High'
    END AS salary_bucket
FROM job_postings_fact
ORDER BY standardized_salary DESC;
































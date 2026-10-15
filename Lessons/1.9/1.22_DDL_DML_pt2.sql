-- ============================================================
-- STEP 1: Create a flattened staging table for job postings
-- ============================================================
-- This table combines job posting information with company names.
-- LEFT JOIN keeps all job postings even if company details are missing.



CREATE OR REPLACE TABLE staging.job_postings_flat AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.name AS company_name
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id;


-- ============================================================
-- STEP 2: Validate the number of records in the staging table
-- ============================================================

-- Staging was created under data mart so first we have to use 

-- use jobs_mart;

SELECT COUNT(*)
FROM staging.job_postings_flat;


-- ============================================================
-- STEP 3: Display all tables available in the staging schema
-- ============================================================

SHOW TABLES FROM staging;


-- ============================================================
-- STEP 4: Inspect the priority role reference table
-- ============================================================

SELECT *
FROM staging.priority_role;


-- ============================================================
-- STEP 5: Match job postings with configured priority roles
-- ============================================================
-- INNER JOIN returns only job titles that exist in priority_role.

SELECT *
FROM staging.job_postings_flat AS jpf
INNER JOIN staging.priority_role AS r
    ON jpf.job_title_short = r.role_name;


-- ============================================================
-- STEP 6: Filter only Priority Level 1 jobs
-- ============================================================
-- jpf.* returns only columns from job_postings_flat.

SELECT jpf.*
FROM staging.job_postings_flat AS jpf
INNER JOIN staging.priority_role AS r
    ON jpf.job_title_short = r.role_name
WHERE r.priority_level = 1;


-- ============================================================
-- STEP 7: Create a reusable view for Priority Level 1 jobs
-- ============================================================
-- A VIEW stores the query definition rather than a separate
-- physical copy of the result.

CREATE OR REPLACE VIEW staging.pritority_jobs_flat_view AS
SELECT jpf.*
FROM staging.job_postings_flat AS jpf
INNER JOIN staging.priority_role AS r
    ON jpf.job_title_short = r.role_name
WHERE r.priority_level = 1;


-- ============================================================
-- STEP 8: Correct the spelling mistake in the view name
-- ============================================================
-- pritority_jobs_flat_view -> priority_jobs_flat_view

ALTER VIEW staging.pritority_jobs_flat_view
RENAME TO priority_jobs_flat_view;


-- ============================================================
-- STEP 9: Validate the number of Priority Level 1 jobs
-- ============================================================

SELECT COUNT(*)
FROM staging.priority_jobs_flat_view;


-- ============================================================
-- STEP 10: Count priority jobs by job title
-- ============================================================
-- GROUP BY creates one group for each job title.

SELECT
    job_title_short,
    COUNT(*) AS job_count
FROM staging.priority_jobs_flat_view
GROUP BY job_title_short
ORDER BY job_count DESC;


-- ============================================================
-- STEP 11: Filter Senior Data Engineer jobs
-- ============================================================

SELECT *
FROM staging.priority_jobs_flat_view
WHERE job_title_short = 'Senior Data Engineer';


-- ============================================================
-- STEP 12: Create a temporary Senior Data Engineer table
-- ============================================================
-- TEMPORARY tables normally exist only for the current session.
-- The result is physically materialized temporarily.

CREATE TEMPORARY TABLE priority_jobs_flat_temp AS
SELECT *
FROM staging.priority_jobs_flat_view
WHERE job_title_short = 'Senior Data Engineer';


-- ============================================================
-- STEP 13: Rename the temporary table
-- ============================================================
-- The new name better describes what the table contains.

ALTER TABLE priority_jobs_flat_temp
RENAME TO senior_jobs_flat_temp;


-- ============================================================
-- STEP 14: Validate records in the temporary table
-- ============================================================

SELECT
    job_title_short,
    COUNT(*) AS job_count
FROM senior_jobs_flat_temp
GROUP BY job_title_short
ORDER BY job_count DESC;


-- ============================================================
-- STEP 15: Compare row counts before modifying staging data
-- ============================================================

SELECT COUNT(*) AS priority_role_count
FROM staging.priority_role;

SELECT COUNT(*) AS job_postings_count
FROM staging.job_postings_flat;

SELECT COUNT(*) AS senior_temp_count
FROM senior_jobs_flat_temp;


-- ============================================================
-- STEP 16: Delete older job postings
-- ============================================================
-- Removes records posted before January 1, 2024.
-- DELETE removes matching rows but keeps the table structure.

DELETE FROM staging.job_postings_flat
WHERE job_posted_date < '2024-01-01';


-- ============================================================
-- STEP 17: Validate row counts after DELETE
-- ============================================================

SELECT COUNT(*) AS priority_role_count
FROM staging.priority_role;

SELECT COUNT(*) AS job_postings_count
FROM staging.job_postings_flat;

SELECT COUNT(*) AS senior_temp_count
FROM senior_jobs_flat_temp;


-- ============================================================
-- STEP 18: Remove ALL records from job_postings_flat
-- ============================================================
-- TRUNCATE removes every row but keeps the table itself.
-- The table structure/columns remain available.

TRUNCATE TABLE staging.job_postings_flat;


-- ============================================================
-- STEP 19: Confirm that the staging table is empty
-- ============================================================

SELECT *
FROM staging.job_postings_flat;


-- ============================================================
-- STEP 20: Reload job postings from the source tables
-- ============================================================
-- Re-populates the existing staging table.
-- Only records after January 1, 2024 are loaded.

INSERT INTO staging.job_postings_flat
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.name AS company_name
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE jpf.job_posted_date > '2024-01-01';


-- ============================================================
-- STEP 21: Final validation after reloading the staging table
-- ============================================================

SELECT COUNT(*) AS priority_role_count
FROM staging.priority_role;

SELECT COUNT(*) AS job_postings_count
FROM staging.job_postings_flat;

SELECT COUNT(*) AS senior_temp_count
FROM senior_jobs_flat_temp;


SELECT * 
FROM staging.job_postings_flat AS jpf
JOIN staging.priority_roles AS r
    ON jpf.job_title_short = r.role_name;

SELECT *
FROM INFORMATION_schema.schemata;

USE staging;

SHOW TABLES FROM staging;


SELECT COUNT(*) FROM staging.job_postings_flat;




WITH high_sal AS (
    SELECT 
        job_id,
        job_title_short,
        CASE 
            WHEN salary_year_avg IS NULL THEN 'Missing'
            WHEN salary_year_avg < 50_000 THEN 'Low'
            WHEN salary_year_avg < 150_000 THEN 'Medium'
            ELSE 'High'
        END AS salary_status
    FROM job_postings_fact
) 
SELECT 
    job_id,
    job_title_short,
    salary_status
FROM high_sal
ORDER BY RANDOM()
LIMIT 10;
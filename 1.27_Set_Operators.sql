-- UNION: Combines rows from multiple queries and removes duplicates. It produces a distinct set of rows.

SELECT UNNEST([1,1,1,2])
UNION 
SELECT UNNEST([1,1,3]);

-- ┌─────────────────────────────────────┐
-- │ unnest(main.list_value(1, 1, 1, 2)) │
-- │                int32                │
-- ├─────────────────────────────────────┤
-- │                                   3 │
-- │                                   2 │
-- │                                   1 │
-- └─────────────────────────────────────┘

-- UNION ALL: Combines rows from multiple queries without removing duplicates. It includes all rows returned by each query, making it faster than UNION because it skips the deduplication step.

SELECT UNNEST([1,1,1,2])
UNION ALL
SELECT UNNEST([1,1,3]);

-- ┌─────────────────────────────────────┐
-- │ unnest(main.list_value(1, 1, 1, 2)) │
-- │                int32                │
-- ├─────────────────────────────────────┤
-- │                                   1 │
-- │                                   1 │
-- │                                   1 │
-- │                                   2 │
-- │                                   1 │
-- │                                   1 │
-- │                                   3 │
-- └─────────────────────────────────────┘

-- INTERSECT: Returns only the rows that exist in both query result sets and removes duplicates from the final output.
SELECT UNNEST([1,1,1,2])
INTERSECT
SELECT UNNEST([1,1,3]);

-- ┌─────────────────────────────────────┐
-- │ unnest(main.list_value(1, 1, 1, 2)) │
-- │                int32                │
-- ├─────────────────────────────────────┤
-- │                                   1 │
-- └─────────────────────────────────────┘
-- INTERSECT ALL combines the result sets of two queries by returning only the overlapping rows, but preserves duplicates based on the row count matching between the datasets.

SELECT UNNEST([1,1,1,2])
INTERSECT ALL
SELECT UNNEST([1,1,3]);

-- ┌─────────────────────────────────────┐
-- │ unnest(main.list_value(1, 1, 1, 2)) │
-- │                int32                │
-- ├─────────────────────────────────────┤
-- │                                   1 │
-- │                                   1 │
-- └─────────────────────────────────────┘

-- EXCEPT (called MINUS in Oracle) returns all distinct rows from the first query that do not appear in the second query.

SELECT UNNEST([1,1,1,2])
EXCEPT
SELECT UNNEST([1,1,3]);

-- ┌─────────────────────────────────────┐
-- │ unnest(main.list_value(1, 1, 1, 2)) │
-- │                int32                │
-- ├─────────────────────────────────────┤
-- │                                   2 │
-- └─────────────────────────────────────┘

-- EXCEPT ALL subtracts matching rows from the first dataset based on how many times they appear in the second dataset, keeping remaining duplicates.

SELECT UNNEST([1,1,1,2])
EXCEPT ALL
SELECT UNNEST([1,1,3]);

-- ┌─────────────────────────────────────┐
-- │ unnest(main.list_value(1, 1, 1, 2)) │
-- │                int32                │
-- ├─────────────────────────────────────┤
-- │                                   1 │
-- │                                   2 │
-- └─────────────────────────────────────┘

CREATE TEMP TABLE jobs_2023 AS 
SELECT * EXCLUDE (job_id, job_posted_date)
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2023;

SELECT * FROM jobs_2023;

CREATE TEMP TABLE jobs_2024 AS 
SELECT * EXCLUDE (job_id, job_posted_date)
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2024;

SELECT * FROM jobs_2024;

-- Which unique job postings appeared in either 2023 or 2024?

SELECT 
'jobs_2023' AS table_name,
COUNT(*) AS record_count
FROM jobs_2023
UNION 
SELECT
    'jobs_2024' AS table_name,
     COUNT(*) FROM jobs_2024;

SELECT job_title_short FROM jobs_2023
UNION
SELECT job_title_short FROM jobs_2024;

-- Which job postings appreared across both years, counting duplicates?

SELECT * FROM jobs_2023
UNION ALL
SELECT * FROM jobs_2024;

-- Which job postings appeared in 2023 but not in 2024?

SELECT * FROM jobs_2023
EXCEPT
SELECT * FROM jobs_2024;


 SELECT 'jobs_2023' AS table_name, COUNT(*) AS total_apprearence FROM jobs_2023
 EXCEPT
 SELECT 'jobs_2024' AS table_name, COUNT(*) AS total_apprearence FROM jobs_2024;


-- Which job posting from 2023 remain after subtracting matching 2024 postings, one-for-one?

SELECT * FROM jobs_2023
EXCEPT ALL
SELECT * FROM jobs_2024;

-- Which job postings appreared in both 2023 and 2024?

SELECT * FROM jobs_2023
INTERSECT
SELECT * FROM jobs_2024;
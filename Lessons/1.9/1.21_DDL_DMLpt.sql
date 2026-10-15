-- ============================================================
-- STEP 1: Switch to the source database
-- ============================================================
-- USE tells SQL which database should be active.

USE data_jobs;


-- ============================================================
-- STEP 2: Delete the old jobs_mart database if it exists
-- ============================================================
-- WARNING: DROP DATABASE removes the database and its objects.
-- Useful here because we want to rebuild the project from scratch.
DROP DATABASE IF EXISTS jobs_mart;


-- ============================================================
-- STEP 3: Create a fresh jobs_mart database
-- ============================================================

CREATE DATABASE IF NOT EXISTS jobs_mart;


-- ============================================================
-- STEP 4: Check all available databases
-- ============================================================

SHOW DATABASES;



-- ============================================================
-- STEP 5: Inspect available schemas
-- ============================================================

SELECT *
FROM information_schema.schemata;


-- ============================================================
-- STEP 6: Switch to the newly created jobs_mart database
-- ============================================================

USE jobs_mart;


-- ============================================================
-- STEP 7: Create a staging schema
-- ============================================================
-- Staging is our working area for preparing and transforming data.

CREATE SCHEMA IF NOT EXISTS staging;


-- Optional:
-- Use this only when you intentionally want to remove the schema.

-- DROP SCHEMA IF EXISTS staging;


-- ============================================================
-- STEP 8: Create the preferred_roles table
-- ============================================================
-- role_id uniquely identifies each role.
-- role_name stores the name of the job role.

CREATE TABLE IF NOT EXISTS staging.preferred_roles (
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL
);


-- ============================================================
-- STEP 9: Check tables created inside jobs_mart
-- ============================================================

SELECT *
FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';


-- ============================================================
-- STEP 10: Insert initial preferred job roles
-- ============================================================

INSERT INTO staging.preferred_roles (role_id, role_name)
VALUES
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer');


-- ============================================================
-- STEP 11: Verify inserted records
-- ============================================================

SELECT *
FROM staging.preferred_roles;


-- ============================================================
-- STEP 12: Insert another role
-- ============================================================

INSERT INTO staging.preferred_roles (role_id, role_name)
VALUES
    (3, 'Software Engineer');


-- ============================================================
-- STEP 13: Add a new Boolean column
-- ============================================================
-- This column initially identifies whether a role is preferred.

ALTER TABLE staging.preferred_roles
ADD COLUMN preferred_role BOOLEAN;


-- ============================================================
-- STEP 14: Verify the new column
-- ============================================================

SELECT *
FROM staging.preferred_roles;


-- ============================================================
-- OPTIONAL: Remove the preferred_role column
-- ============================================================
-- Kept commented because we currently need this column.
-- ALTER TABLE staging.preferred_roles
-- DROP COLUMN preferred_role;


-- ============================================================
-- STEP 15: Mark Data Engineer and Senior Data Engineer as preferred
-- ============================================================
UPDATE staging.preferred_roles
SET preferred_role = TRUE
WHERE role_id = 1 OR role_id = 2;


-- ============================================================
-- STEP 16: Mark Software Engineer as not preferred
-- ============================================================
UPDATE staging.preferred_roles
SET preferred_role = FALSE
WHERE role_id = 3;


-- ============================================================
-- STEP 17: Verify the updates
-- ============================================================
SELECT *
FROM staging.preferred_roles;


-- ============================================================
-- STEP 18: Rename preferred_roles table to priority_role
-- ============================================================
-- We are changing the table name because the table will now
-- represent role priorities instead of only preferred roles.
ALTER TABLE staging.preferred_roles
RENAME TO priority_role;


-- ============================================================
-- STEP 19: Verify the renamed table
-- ============================================================
SELECT *
FROM staging.priority_role;


-- ============================================================
-- STEP 20: Rename preferred_role column to priority_level
-- ============================================================
ALTER TABLE staging.priority_role
RENAME COLUMN preferred_role TO priority_level;


-- ============================================================
-- STEP 21: Convert priority_level from BOOLEAN to INTEGER
-- ============================================================
-- Previously:
-- TRUE  = preferred
-- FALSE = not preferred
--
-- Now we want numerical priority levels such as:
-- 1 = Highest Priority
-- 2 = Medium Priority
-- 3 = Lower Priority
ALTER TABLE staging.priority_role
ALTER COLUMN priority_level TYPE INTEGER;


-- ============================================================
-- STEP 22: Assign priority level 3 to Software Engineer
-- ============================================================
UPDATE staging.priority_role
SET priority_level = 3
WHERE role_id = 3;


-- ============================================================
-- STEP 23: View the final priority_role table
-- ============================================================
SELECT *
FROM staging.priority_role;
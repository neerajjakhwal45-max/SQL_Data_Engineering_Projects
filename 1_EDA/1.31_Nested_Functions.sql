-- Array Intro
SELECT ['sql','python'];


WITH skills AS(
SELECT 'pyhton' AS skill,
UNION ALL 
SELECT 'SQL'
UNION ALL
SELECT 'R'
), skills_array AS (
SELECT ARRAY_AGG (skill) AS skills
FROM skills
)
SELECT 
    skills[1] AS first_skill
FROM skills_array;

-- STRUCT
SELECT {skill:'python', type:'Programming'} AS skill_struct;

WITH skill_struct AS (
    SELECT 
        STRUCT_PACK(
            skill:='Python',
            type:='Programming'
        ) AS s 
)
SELECT 
    s.skill,
    s.type
FROM skill_struct;

WITH skill_table AS (
    SELECT 'python' AS skills,'programing' AS types
    UNION ALL
    SELECT 'sql','query_language'
    UNION ALL
    SELECT 'r','programming'
)
SELECT 
    STRUCT_PACK (
        skill:=skills,
        type:=types
    )
FROM skill_table;

--Array of Structs
SELECT [    
    { skill: 'Python', type: 'programming' },
    { skill: 'sql', type: 'query_language' }
] AS skills_array_of_structs;

WITH skill_table AS (
    SELECT 'python' AS skills,'programing' AS types
    UNION ALL
    SELECT 'sql','query_language'
    UNION ALL
    SELECT 'r','programming'
), skills_array_struct AS (
    SELECT 
        ARRAY_AGG(
            STRUCT_PACK (
                skill:=skills,
                type:=types
            )
        )
    FROM skill_table
)
SELECT *
FROM skills_array_struct;

--Map
WITH skill_map AS (
    SELECT MAP {'skill' : 'python','type':'programming'} AS skill_type
)
SELECT 
    skill_type['skill'],
    skill_type['type']
FROM skill_map;

--JSON
WITH raw_skill_json AS (
    SELECT 
        '{"skill":"python","type":"programming"}':: JSON AS skill_json
)
SELECT
    STRUCT_PACK(
        skill:=json_extract_string(skill_json,'$.skill'),
        type:=json_extract_string(skill_json,'$.type')
    )
FROM raw_skill_json;

-- JSON to Array of Structs

WITH raw_json AS (

    SELECT
        '[
            {"skill":"python","type":"programming"},
            {"skill":"sql","type":"query_language"},
            {"skill":"r","type":"programming"}
        ]'::JSON AS skills_json

)

SELECT
    ARRAY_AGG(
        STRUCT_PACK(
            skill := json_extract_string(e.value, '$.skill'),
            type := json_extract_string(e.value, '$.type')
        )
        ORDER BY json_extract_string(e.value, '$.skill')
    ) AS skills

FROM raw_json,
     json_each(skills_json) AS e;


-- Arrays _FinalExample
--  Build a flat skill table for co-workers to access job-titles, salary info, and skills in one table

SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd 
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id
GROUP BY ALL
LIMIT 10;
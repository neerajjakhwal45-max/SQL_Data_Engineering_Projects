/*
Question: What are the most optimal skills for data engineers—balancing both demand and salary?
- Create a ranking column that combines demand count and median salary to identify the most valuable skills.
- Focus only on remote Data Engineer positions with specified annual salaries.
- Why?
    - This approach highlights skills that balance market demand and financial reward. It weights core skills appropriately instead of letting rare, outlier skills distort the results.
    - The natural log transformation ensures that both high-salary and widely in-demand skills surface as the most practical and valuable to learn for data engineering careers.
*/


SELECT
    sd.skills, 
    ROUND(MEDIAN(jpf.salary_year_avg),2) AS median_salary,
    COUNT(jpf.*) AS demand_count,
    ROUND(LN(COUNT(jpf.*)),1) AS ln_deman_count,
    ROUND((MEDIAN(jpf.salary_year_avg) * LN(COUNT(jpf.*))),2) AS optimal_skill_score
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE 
    jpf.job_title_short = 'Data Engineer'
    AND jpf.job_work_from_home = TRUE
GROUP BY 
    sd.skills
HAVING
    COUNT(jpf.*) > 100
ORDER BY 
    optimal_skill_score DESC
LIMIT 25;



/*


Question: What are the most optimal skills for data engineers—balancing both demand and salary?
- Create a ranking column that combines demand count and median salary to identify the most valuable skills.
- Focus only on remote Data Engineer positions with specified annual salaries.
- Why?
    - This approach highlights skills that balance market demand and financial reward. It weights core skills appropriately instead of letting rare, outlier skills distort the results.
    - The natural log transformation ensures that both high-salary and widely in-demand skills surface as the most practical and valuable to learn for data engineering careers.



┌────────────┬───────────────┬──────────────┬────────────────┬─────────────────────┐
│   skills   │ median_salary │ demand_count │ ln_deman_count │ optimal_skill_score │
│  varchar   │    double     │    int64     │     double     │       double        │
├────────────┼───────────────┼──────────────┼────────────────┼─────────────────────┤
│ terraform  │      184000.0 │         3248 │            8.1 │          1487786.23 │
│ python     │      135000.0 │        28776 │           10.3 │          1386085.09 │
│ airflow    │      150000.0 │         9996 │            9.2 │          1381491.04 │
│ aws        │     137320.31 │        17823 │            9.8 │          1344124.87 │
│ sql        │      130000.0 │        29221 │           10.3 │          1336743.58 │
│ spark      │      140000.0 │        12799 │            9.5 │          1323997.13 │
│ kafka      │      145000.0 │         6415 │            8.8 │          1271127.17 │
│ kubernetes │      150500.0 │         4202 │            8.3 │          1255669.04 │
│ golang     │      184000.0 │          912 │            6.8 │          1254077.76 │
│ snowflake  │      135500.0 │         8639 │            9.1 │          1228177.71 │
│ azure      │      128000.0 │        14143 │            9.6 │          1223292.81 │
│ scala      │     137290.48 │         6304 │            8.7 │          1201146.16 │
│ java       │      135000.0 │         7267 │            8.9 │          1200298.34 │
│ databricks │      132750.0 │         8183 │            9.0 │          1196052.82 │
│ gcp        │      136000.0 │         6446 │            8.8 │          1192885.25 │
│ pyspark    │      140000.0 │         4898 │            8.5 │          1189521.51 │
│ git        │      140000.0 │         4641 │            8.4 │          1181975.92 │
│ hadoop     │      135000.0 │         5447 │            8.6 │          1161380.74 │
│ rust       │      210000.0 │          232 │            5.4 │          1143814.85 │
│ nosql      │      134415.0 │         4514 │            8.4 │          1131094.02 │
│ docker     │      135000.0 │         4316 │            8.4 │          1129961.38 │
│ redshift   │      130000.0 │         5737 │            8.7 │          1125109.92 │
│ pandas     │      140000.0 │         2929 │            8.0 │          1117538.29 │
│ mongodb    │      135750.0 │         3512 │            8.2 │          1108254.98 │
│ bigquery   │      135000.0 │         3523 │            8.2 │           1102554.2 │
└────────────┴───────────────┴──────────────┴────────────────┴─────────────────────┘
  25 rows                                                                5 columns

*/
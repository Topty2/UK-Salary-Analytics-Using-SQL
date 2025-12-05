SELECT * FROM uk_salary LIMIT 10;

ALTER TABLE uk_salary
ALTER COLUMN pay_annual TYPE numeric
USING pay_annual::numeric;


-- 1️ What is the Top 5 Regions based on the Average Pay

SELECT region, ROUND(AVG(pay_annual::numeric),2) AS Average_Pay
FROM uk_salary
GROUP BY region
ORDER BY Average_Pay DESC
LIMIT 5

-- 2 Which occupations have the highest average annual salary in the UK?

SELECT occupation,
       ROUND(AVG(pay_annual::numeric), 2) AS avg_salary,
       COUNT(*) AS samples
FROM uk_salary
GROUP BY occupation
HAVING COUNT(*) > 5
ORDER BY avg_salary DESC
LIMIT 10;

-- 3 What is the gender pay gap by occupation?

SELECT occupation, COUNT(*),
       ROUND(AVG(CASE WHEN sex='Male' THEN pay_annual END),2) AS male_avg,
       ROUND(AVG(CASE WHEN sex='Female' THEN pay_annual END),2) AS female_avg,
       ROUND(
            100 * (AVG(CASE WHEN sex='Male' THEN pay_annual END) -
                   AVG(CASE WHEN sex='Female' THEN pay_annual END))
            / NULLIF(AVG(CASE WHEN sex='Male' THEN pay_annual END),0), 2
       ) AS pct_gap_vs_male
FROM uk_salary
GROUP BY occupation
HAVING COUNT(*) > 5
ORDER BY pct_gap_vs_male DESC;

-- 4. What are the top 3 highest-paying occupations per region?
WITH ranked_jobs AS (
    SELECT region, occupation,
           ROUND(AVG(pay_annual),2) AS avg_salary,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY AVG(pay_annual) DESC) AS rn
    FROM uk_salary
    GROUP BY region, occupation
)
SELECT region, occupation, avg_salary
FROM ranked_jobs
WHERE rn <= 3;

-- 5. How does pay change by age group?
SELECT age_group,
       COUNT(*) AS worker_count,
       ROUND(AVG(pay_annual),2) AS avg_salary
FROM uk_salary
GROUP BY age_group
ORDER BY avg_salary DESC;


-- 6. What is the salary distribution across salary bands?
SELECT 
    CASE 
        WHEN pay_annual < 25000 THEN 'Low'
        WHEN pay_annual BETWEEN 25000 AND 39999 THEN 'Lower-Middle'
        WHEN pay_annual BETWEEN 40000 AND 59999 THEN 'Upper-Middle'
        ELSE 'High'
    END AS salary_band,
    COUNT(*) AS employees,
    ROUND(AVG(pay_annual),2) AS avg_salary
FROM uk_salary
GROUP BY 1
ORDER BY employees DESC;

--7 Does full-time vs part-time work affect salary?

SELECT work_pattern,
       COUNT(*) AS Number_of_Workers,
       ROUND(AVG(pay_annual),2) AS avg_salary
FROM uk_salary
GROUP BY work_pattern;


-- 8 Which occupations experience the largest regional salary differences?

SELECT occupation,
       ROUND(MAX(pay_annual) - MIN(pay_annual), 2) AS regional_salary_gap,
       ROUND(AVG(pay_annual), 2) AS avg_salary,
       COUNT(*) AS samples
FROM uk_salary
GROUP BY occupation
HAVING COUNT(*) > 5
ORDER BY regional_salary_gap DESC
LIMIT 10;



















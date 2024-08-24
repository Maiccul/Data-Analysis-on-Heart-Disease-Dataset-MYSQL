SELECT *
FROM heart_staging
;


#1 Distribution of age for individuals in dataset

SELECT
	MIN(age) AS min_age,
    MAX(age) AS max_age,
    AVG(age) AS avg_age,
    STDDEV(age) AS stddev_age
FROM heart_staging
;

# Age distribution in brackets of 10 years
SELECT 
	FLOOR(age /10) *10 AS age_group,
    COUNT(*) AS count
FROM heart_staging
GROUP BY age_group
ORDER BY age_group
;

# Age distribution where heart disease are present
SELECT
	FLOOR(age / 10) *10 AS age_group,
    target,
    COUNT(*) AS count
FROM heart_staging
GROUP BY age_group, target
ORDER BY age_group, target
;

# Age distribution of ill individuals in 5-year brackets 
SELECT 
    CONCAT(FLOOR((age - 30) / 5) * 5 + 30, '-', FLOOR((age - 30) / 5) * 5 + 34) AS age_group,
    COUNT(*) AS total_count,
    CONCAT(ROUND(COUNT(*) /(SELECT COUNT(*) AS total_count FROM heart_staging WHERE target='ill')
    * 100,2),'%') AS percentage
FROM heart_staging
WHERE 
    target='ill'
GROUP BY 
    age_group
ORDER BY 
    age_group;

#2 How does the incidence of heart disease vary between genders    

SELECT
	sex,
    COUNT(*) AS count
FROM heart_staging
GROUP BY sex;

# Count the number of heart disease by gender
SELECT
	sex,
    COUNT(*) AS count
FROM heart_staging
WHERE target ='ill'
GROUP BY sex;

# Calculate the proportion of heart diseases by gender
SELECT sex,
	COUNT(*) AS total_count,
	SUM(CASE WHEN target ='ill' THEN 1 ELSE 0 END) AS count_disease,
    CONCAT(ROUND((SUM(CASE WHEN target ='ill' THEN 1 ELSE 0 END)/ COUNT(*))*100,2),'%') AS proportion_with_disease
FROM heart_staging
GROUP BY sex
;

#3 What are the predominant types of chest pain experienced by individuals with heart disease

SELECT 
	chest_pain_type,
	COUNT(*) AS total_count
FROM heart_staging
GROUP BY chest_pain_type
;

# Count the number of heart disease cases by chest pain type
SELECT 
	chest_pain_type,
	COUNT(*) AS total_count
FROM heart_staging
WHERE target = 'ill'
GROUP BY chest_pain_type
;

# Calculate the proportion of individuals with heart disease for each chest pain type
SELECT 
	chest_pain_type,
	COUNT(*) AS total_count,
    SUM(CASE WHEN target ='ill' THEN 1 ELSE 0 END) AS count_with_disease,
    CONCAT(ROUND((SUM(CASE WHEN target ='ill' THEN 1 ELSE 0 END)/ COUNT(*))*100,2),'%') AS proportion_with_disease
FROM heart_staging
GROUP BY chest_pain_type
;
	
SELECT chest_pain_type,
COUNT(*) AS count,
CONCAT(ROUND(COUNT(*) /(SELECT COUNT(*) AS total_count FROM heart_staging WHERE target='ill')
    * 100,2),'%') AS percentage
FROM heart_staging
CROSS JOIN (SELECT COUNT(*) from heart_staging where target='ill') AS sx
WHERE 
target ='ill'
GROUP BY 
chest_pain_type
ORDER BY 
chest_pain_type
;

#4 Are there any correlations between resting blood pressure, serum cholesterol, and the presence of heart disease
# Basic statistics for resting blood pressure & serum cholesterol
-- For individuals without heart disease (target = 'normal'/0)
SELECT
	'No heart disease' AS category,
    ROUND(MIN(resting_bps),4) AS min_resting_bps,
    ROUND(MAX(resting_bps),4) AS max_resting_bps,
    ROUND(AVG(resting_bps),4) AS avg_resting_bps,
    ROUND(STDDEV(resting_bps),4) AS stddev_resting_bps,
    ROUND(MIN(cholesterol),4) AS min_cholesterol,
    ROUND(MAX(cholesterol),4) AS max_cholesterol,
    ROUND(AVG(cholesterol),4) AS avg_cholesterol,
    ROUND(STDDEV(cholesterol),4) AS stddev_cholesterol
FROM heart_staging
WHERE target ='normal'

UNION ALL
-- For individuals with heart disease (target = 'normal'/1)
SELECT
	'Heart disease' AS category,
    ROUND(MIN(resting_bps),4) AS min_resting_bps,
    ROUND(MAX(resting_bps),4) AS max_resting_bps,
    ROUND(AVG(resting_bps),4) AS avg_resting_bps,
    ROUND(STDDEV(resting_bps),4) AS stddev_resting_bps,
    ROUND(MIN(cholesterol),4) AS min_cholesterol,
    ROUND(MAX(cholesterol),4) AS max_cholesterol,
    ROUND(AVG(cholesterol),4) AS avg_cholesterol,
    ROUND(STDDEV(cholesterol),4) AS stddev_cholesterol
FROM heart_staging
WHERE target ='ill'
;

# Compare resting blood pressure, serum cholesterol by heart disease presence
SELECT
	FLOOR(resting_bps / 10)*10 AS resting_bps_range,
    target,
    COUNT(*) AS count
FROM heart_staging
GROUP BY resting_bps, target
ORDER BY resting_bps, target
;

SELECT
	FLOOR(cholesterol / 10)*10 AS cholesterol_range,
    target,
    COUNT(*) AS count
FROM heart_staging
GROUP BY cholesterol_range, target
ORDER BY cholesterol_range, target
;

#5 How do maximum heart rate and exercise-induced angina relate to the likelihood of heart disease

SELECT max_heart_rate, exercise_angina,target
FROM heart_staging
ORDER BY target,exercise_angina 
;

# Calculating average maximum heart rate based on heart disease presence
SELECT target, AVG(max_heart_rate) AS avg_max_heart_rate
FROM heart_staging
GROUP BY target
;

# Counting the occurrence of exercise-induced angina based on the presence of heart disease
SELECT target, exercise_angina, COUNT(*) as count
FROM heart_staging
GROUP BY target, exercise_angina
;

# View of maximum heart rate and exercise-induced angina based on heart disease presence
SELECT target,
	AVG(max_heart_rate) AS avg_max_heart_rate,
    SUM(CASE WHEN exercise_angina ='yes' THEN 1 ELSE 0  END) AS count_angina,
    SUM(CASE WHEN exercise_angina = 'no' THEN 1 ELSE 0  END) AS count_no_angina
FROM heart_staging
GROUP BY target
;
SHOW TABLES
;
SELECT *
FROM heart_statlog_cleveland_hungary_final
;

ALTER TABLE heart_statlog_cleveland_hungary_final
RENAME TO heart_stalog_cleveland_hungary_final_raw
;

#Creating table for work, keeping original file intact for reference

DROP TABLE IF EXISTS heart_staging
;

CREATE TABLE heart_staging
LIKE heart_stalog_cleveland_hungary_final_raw
;

INSERT heart_staging
SELECT *
FROM heart_stalog_cleveland_hungary_final_raw
;

SELECT *
FROM heart_staging
;
#Given the nature of the data (lacking unique identifier such as serial number or name)
#No duplicate checking/removing shall be performed

SHOW COLUMNS
FROM heart_staging
;

#Data formatting
#Name formatting to replace whitespace with _ 
#Since only a few columns had to be changed, no loop function was used.

ALTER TABLE heart_staging
RENAME COLUMN `chest pain type` TO `chest_pain_type`,
RENAME COLUMN `resting bp s` TO `resting_bps`,
RENAME COLUMN `fasting blood sugar` TO `fasting_blood_sugar`,
RENAME COLUMN `resting ecg` TO `resting_ecg`,
RENAME COLUMN `max heart rate` TO `max_heart_rate`,
RENAME COLUMN `exercise angina` TO `exercise_angina`,
RENAME COLUMN `ST slope` TO `ST_slope`
;

Select resting_bps
FROM heart_staging;

SHOW COLUMNS
FROM heart_staging
;

#Formatting data based on Attribute Description
#Changing sex column from binary (nominal in the table format) to string
ALTER TABLE heart_staging
MODIFY COLUMN sex VARCHAR(10)
;

UPDATE heart_staging
SET sex = CASE
	WHEN sex = 1 THEN 'male'
    WHEN sex = 0 THEN 'female'
    ELSE NULL
END
;

/* Modifying Chest Pain Type as follows:
-- Value 1: typical angina 
-- Value 2: atypical angina 
-- Value 3: non-anginal pain 
-- Value 4: asymptomatic 
*/

ALTER TABLE heart_staging
MODIFY COLUMN chest_pain_type VARCHAR(20)
;

UPDATE heart_staging
SET chest_pain_type = CASE
	WHEN chest_pain_type = 1 THEN 'typical_angina'	
    WHEN chest_pain_type = 2 THEN 'atypical_angina'
	WHEN chest_pain_type = 3 THEN 'non_anginal_pain'
    WHEN chest_pain_type = 4 THEN 'asymptomatic'
    ELSE NULL
END
;

/* Modifying Resting ECG	column as it follows:
-- Value 0: normal 
-- Value 2: ST_deviation 
-- Value 3: QRS_deviation */

ALTER TABLE heart_staging
MODIFY COLUMN resting_ecg VARCHAR(15)
;

UPDATE heart_staging
SET resting_ecg = CASE
	WHEN resting_ecg = 0 THEN 'normal'
	WHEN resting_ecg = 1 THEN 'ST_deviation'
	WHEN resting_ecg = 2 THEN 'QRS_deviation'
	ELSE NULL
END
;

#Changing the values in exercise_angina (exercise induced angina) binary->text

ALTER TABLE heart_staging
MODIFY COLUMN exercise_angina VARCHAR(20)
;

UPDATE heart_staging
SET exercise_angina = CASE
	WHEN exercise_angina = 1 THEN 'yes' 
    WHEN exercise_angina = 0 THEN 'no'
    ELSE NULL
END
;

/* Changing ST Slope which refers to the Slope of the peak exercise ST segment
-- Value 0: upsloping 
-- Value 1: flat 
-- Value 2: downsloping 
*/

ALTER TABLE heart_staging
MODIFY COLUMN ST_slope VARCHAR(15)
;

UPDATE heart_staging
SET ST_slope = CASE
	WHEN ST_slope =  0 THEN 'upsloping'
	WHEN ST_slope =  1 THEN 'flat'
	WHEN ST_slope =  2 THEN 'downsloping'
    ELSE NULL
END
;

Select MAX(oldpeak),MIN(oldpeak)
FROM heart_staging;
/* OLDpeak refers to the peak of ST in normal settings
   With values from -2.6 to 6.2 
   Although ambigous it provides the baseline for the ST_Slope */

ALTER TABLE heart_staging
RENAME COLUMN `oldpeak` TO `STpeak` 
;

#Altering the class column (healthy or ill)
-- Value 0 : Normal
-- Value 1 : Heart disease


ALTER TABLE heart_staging
MODIFY COLUMN target VARCHAR(15)
;

UPDATE heart_staging
SET target = CASE
	WHEN target = 0 THEN 'normal'
    WHEN target = 1 THEN 'ill'
    ELSE NULL
END
;

#Removing null values in columns:cholesterol, resting_bps
SELECT MIN(cholesterol), MIN(resting_bps)
FROM heart_staging
;

CREATE TEMPORARY TABLE class_averages AS
SELECT target, 
       AVG(CASE WHEN cholesterol != 0 THEN cholesterol ELSE NULL END) AS avg_cholesterol, 
       AVG(CASE WHEN resting_bps != 0 THEN resting_bps ELSE NULL END) AS avg_resting_bps
FROM heart_staging
GROUP BY target;

UPDATE heart_staging AS t1
JOIN class_averages t2 
ON (t1.target = t2.target)
SET t1.cholesterol = IF(t1.cholesterol =0, t2.avg_cholesterol, t1.cholesterol),
	t1.resting_bps = IF(t1.resting_bps =0, t2.avg_resting_bps, t1.resting_bps)
WHERE t1.cholesterol = 0 or t1.resting_bps =0
;

DROP TEMPORARY TABLE class_averages
;

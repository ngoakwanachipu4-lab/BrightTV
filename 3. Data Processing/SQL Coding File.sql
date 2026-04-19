------------------------------------------------------
---Data Inspection
-----------------------------------------------------

---Dataset has 4 columns
----------------------------------------------------
---Checking datase columnst-------------------------------
---1. Channels----- 
  SELECT DISTINCT (Channel2) AS Total_Channels
  FROM workspace.default.viewership_tv;
---Answer: we have 21 channels---
------------------------------------------------------
---2. Number of users------
 SELECT COUNT ( UserID) AS Total_Users
 FROM workspace.default.viewership_tv;
 ---Answer:there is 10000 viewers in TotaL
 ------------------------------------------------------
 ---3. Unique viewers
 SELECT COUNT ( DISTINCT UserID) AS Total_Viewers
 FROM workspace.default.viewership_tv;
 ---Answer: there are 4368 unique viewers
 ----------------------------------------------- 
---4. checking the dates range

SELECT MIN(RecordDate2) AS Min_Date
FROM workspace.default.viewership_tv;

---Answer: Minimum_Date is 2016-01-01

SELECT MAX(Recorddate2) AS Max_Date
FROM workspace.default.viewership_tv;

---Checking dataset period---
SELECT DATEDIFF(DAY,'2016-01-01', '2016-03-31') AS Date_Range;

---Answer Maximum Date is 2016-03-31
---The data was recorded over a 3 month period or 90days--
---------------------------------------------------------------------
---5. Checking the specific dates
SELECT RecordDate2 AS Watch_Date,
       DAY(RecordDate2) AS Day_name,
       MONTH(RecordDate2) AS Month_name,
       YEAR(RecordDate2) AS Year
 FROM workspace.default.viewership_tv;   

 SELECT RecordDate2 AS Watch_Date,
       DAYNAME(RecordDate2) AS Day_name,
       MONTHNAME(RecordDate2) AS Month_name,
       YEAR(RecordDate2) AS Year
 FROM workspace.default.viewership_tV
 ORDER BY Watch_date ASC; 

 ----------------------------------------------------------------------
---6. Converting Time
SELECT from_utc_timestamp(RecordDate2, 'Africa/Johannesburg') AS SA_time
FROM workspace.default.viewership_tv;  

SELECT DATE_FORMAT(RecordDate2 + interval'2 hour', 'HH:mm:ss') SA_Time
FROM workspace.default.viewership_tv;  

SELECT
 DATE_FORMAT(RecordDate2, 'yyyy-MM-dd')AS Date,
 DATE_FORMAT(RecordDate2 + INTERVAL'2 hour', 'HH:mm:ss') SA_Time
FROM workspace.default.viewership_tv; 

SELECT DATEADD(HOUR,2,RecordDate2) AS SA_Time
FROM workspace.default.viewership_tv
ORDER BY SA_Time ASC;

-------------------------------------------------------
---7. Checking nulls

SELECT*
FROM workspace.default.viewership_tv
WHERE UserID IS NULL
      OR Channel2 IS NULL
      OR RecordDate2 IS NULL
      OR `Duration 2` IS NULL;

---No Nulls Have been found
------------------------------------------------------------------------
---Checking None

SELECT COUNT(Channel2) AS None,
       COUNT(RecordDate2) AS None,
       COUNT(`Duration 2`) AS None
  FROM workspace.default.viewership_tv;
     

  SELECT*
  FROM workspace.default.viewership_tv
  WHERE Channel2 = 'None';


  SELECT*
  FROM workspace.default.viewership_tv
  WHERE RecordDate2 IS NULL;
---No Nones Have been found
---------------------------------------------------------------

---Inspecting dataset on UserProfile Table---

SELECT *
FROM workspace.default.profile_bright;

---Answer: There are 7 columns on this table
-----------------------------------------
---Checking the Number of users
-----------------------------------------------
SELECT COUNT ( UserID) AS Total_Users
FROM workspace.default.profile_bright;
---Total users: 5375
------------------------------------------------
---Checking Number of Province--
SELECT DISTINCT province
FROM workspace.default.profile_bright;
---All 9 province are there, including others and non---
---------------------------------------------------
---Checking Users Per Province---
SELECT Province, 
       COUNT(UserID) AS Number_of_users
FROM workspace.default.profile_bright
GROUP BY Province
ORDER BY Number_of_users DESC;
---Gauteng has lots of users, followed by Western Cape
--------------------------------------
---checking Race----
SELECT Race, COUNT(UserID) AS User_per_Race
FROM workspace.default.profile_bright
GROUP BY Race
ORDER BY User_per_race DESC;
---black community is the highest user
----------------------------------------------------
---Checking Gender
SELECT Gender, COUNT(UserID) AS User_per_Gender
FROM workspace.default.profile_bright
GROUP BY Gender
ORDER BY User_per_gender DESC;
---Male community is the highest user
-----------------------------------------------------------------
---cleaning data removing none and blanks
------------------
SELECT 
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN UserID IS NULL THEN 1 ELSE 0 END) AS Null_UserID,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Null_Age,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Null_Gender,
    SUM(CASE WHEN Province IS NULL THEN 1 ELSE 0 END) AS Null_Province
FROM workspace.default.profile_bright;

SELECT 
    UserID,
    COALESCE(Age, 0) AS Age,
    COALESCE(Gender, 'Unknown') AS Gender,
    COALESCE(Province, 'Unknown') AS Province,
    COALESCE(Race, 'Unknown') AS Race
FROM workspace.default.profile_bright;

---None----

SELECT 
    UserID,
    
    -- Clean Race--
    CASE 
        WHEN Race IS NULL OR Race = 'None'  THEN 'Unknown'
        ELSE Race
    END AS Race,
    
    -- Clean Gender
    CASE 
        WHEN Gender IS NULL OR Gender = 'None' THEN 'Unknown'
        ELSE Gender
    END AS Gender,
    
    -- Clean Province
    CASE 
        WHEN Province IS NULL OR Province = 'None' THEN 'Unknown'
        ELSE Province
    END AS Province

FROM workspace.default.profile_bright;



SELECT 
CASE
    WHEN Gender IN ('male', 'm') THEN 'Male'
    WHEN Gender IN ('female', 'f') THEN 'female'
    ELSE 'unknown'
    END AS gender_complete
FROM `workspace`.`default`.`profile_bright`;

---There are 702 unknown Gender
---------------------------------------------
SELECT COUNT (UserID) AS Unknown
FROM workspace.default.profile_bright;


-------------------------------------------------------------
---JOINING THE TABLES USING LEFT JOIN
--------------------------------------------------------------
SELECT
v.UserID,
v.Channel2,
v.RecordDate2,
v.WatchTime,
v.`Duration 2`,

u.Name,
u.Surname,
u.Email,
u.Race,
u.Age,
u.Province,
u.`Social Media Handle`,

---Adding columns to enhance the data set

---Watch count added---
COUNT(v.Channel2) OVER (PARTITION BY v.UserID, v.Channel2) AS Watch_Count,
---Total Users added---
COUNT(v.UserID) OVER() AS Total_Number_Users,
---Total Viewers Added...
COUNT(v.UserID) OVER() AS Total_Views_Per_User,

---Total users per province added
COUNT(v.UserID) OVER(PARTITION BY u.Province) AS Number_of_users_province,
---Total users per race added
COUNT(v.UserID) OVER(PARTITION BY u.Race) AS Number_of_users_race,
---Total users per Gender
COUNT(v.UserID) OVER(PARTITION BY u.Gender) AS Number_of_users_gender,
---Total Rows added----
COUNT(v.UserID) OVER() AS Total_Rows,
---Adding column 1
   Dayname(v.RecordDate2) AS Day_name, 

---Adding column 2
 Monthname(v.RecordDate2) AS Month_name,

 ---Adding Column 3
 DayofMonth(v.RecordDate2) AS Day_month,

  ---Adding Column 4
from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg') AS sast_time,
 
---Cleaned Data 5

    CASE 
        WHEN u.Race IS NULL OR u.Race = 'None'  THEN 'Unknown'
        ELSE u.Race
    END AS Race,
    
    
    CASE 
        WHEN u.Gender IS NULL OR u.Gender = 'None' THEN 'Unknown'
        ELSE u.Gender
    END AS Gender,
    
    
    CASE 
        WHEN u.Province IS NULL OR u.Province = 'None' THEN 'Unknown'
        ELSE u.Province
    END AS Province,
COALESCE(
        TRY_CAST(NULLIF(TRIM(u.Age), 'None') AS INT),
        0
    ) AS Age,

    COALESCE(
        NULLIF(TRIM(u.Gender), 'None'),
        'Unknown'
    ) AS Gender,

    COALESCE(
        NULLIF(TRIM(u.Province), 'None'),
        'Unknown'
    ) AS Province,

 ----Adding New Column 6 -Determining Weekends
 CASE
    WHEN Dayname(v.RecordDate2) IN ('Sun', 'Sat') THEN 'Weekend'
    ELSE 'Weekday'
    END AS day_classification,

---Adding New column 7-to classify duration
CASE
     WHEN date_format(v.`Duration 2`, 'HH:mm:ss') BETWEEN '00:00:01' AND '00:00:59' THEN '01. Low consumption'
     WHEN date_format(v.`Duration 2`, 'HH:mm:ss') BETWEEN '00:01:00' AND '00:30:59' THEN '02. Medium consumption'
     WHEN date_format(v.`Duration 2`, 'HH:mm:ss') BETWEEN '00:32:00' AND '01:59:59' THEN '03. High consumption'
      ELSE '04.Very High Consumption' 
END AS Duration_classification,
---Adding New Column 8- to Classify Age group
CASE
    WHEN u.Age < 12 THEN 'Minor'
    WHEN u.Age BETWEEN 13 AND 19 THEN 'Teen'
    WHEN u.Age BETWEEN 20 AND 35 THEN 'Youth'
    WHEN u.Age BETWEEN 36 AND 59 THEN 'Adult' 
    ELSE 'Senior citizen'
END AS Age_Classification,

---Adding New Column 9-about Time Watch Series
CASE
    
    WHEN date_format(to_timestamp(v.WatchTime, 'h:mm:ss a'),'HH:mm:ss') BETWEEN '00:00:00' AND '06:59:59' THEN '01. Morning'
    WHEN date_format(to_timestamp(v.WatchTime, 'h:mm:ss a'),'HH:mm:ss') BETWEEN '07:00:00' AND '11:59:59' THEN '02. Mid-Morning' 
    WHEN date_format(to_timestamp(v.WatchTime, 'h:mm:ss a'),'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
    WHEN date_format(to_timestamp(v.WatchTime, 'h:mm:ss a'),'HH:mm:ss') BETWEEN '17:00:00' AND '20:59:59' THEN '04. Evening'
    ELSE '05.Night' 
    END AS Time_Classification

FROM workspace.default.viewership_tv AS v
LEFT JOIN workspace.default.profile_bright AS u
ON v.UserID=u.UserID;

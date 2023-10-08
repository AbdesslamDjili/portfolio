create database Falcon9

select*from [dbo].[SpaceX_Launches_Data]
 

--calculating the ratio of lunch for each orbit 
SELECT
    (SUM(CASE WHEN [Orbit] = 'GTO' THEN 1 ELSE 0 END) * 100.0 / COUNT([FlightNumber])) AS 'GTO%',
    (SUM(CASE WHEN [Orbit] = 'LEO' THEN 1 ELSE 0 END) * 100.0 / COUNT([FlightNumber])) AS 'LEO%',
	(SUM(CASE WHEN [Orbit] = 'ISS' THEN 1 ELSE 0 END) * 100.0 / COUNT([FlightNumber])) AS 'ISS%',
	(SUM(CASE WHEN [Orbit] = 'PO' THEN 1 ELSE 0 END) * 100.0 / COUNT([FlightNumber])) AS 'PO%',
	(SUM(CASE WHEN [Orbit] = 'ES-L1' THEN 1 ELSE 0 END) * 100.0 / COUNT([FlightNumber])) AS 'ES-L1%',
	(SUM(CASE WHEN [Orbit] = 'SSO' THEN 1 ELSE 0 END) * 100.0 / COUNT([FlightNumber])) AS 'SSO%',
	(SUM(CASE WHEN [Orbit] = 'VLEO' THEN 1 ELSE 0 END) * 100.0 / COUNT([FlightNumber])) AS 'VLEO%',
	(SUM(CASE WHEN [Orbit] = 'SO' THEN 1 ELSE 0 END) * 100.0 / COUNT([FlightNumber])) AS 'SO%',
	(SUM(CASE WHEN [Orbit] = 'MEO' THEN 1 ELSE 0 END) * 100.0 / COUNT([FlightNumber])) AS 'MEO%'
FROM [dbo].[SpaceX_Launches_Data]
WHERE [Orbit] IN ('GTO', 'LEO','ISS','PO','ES-L1','SSO','VLEO','SO','MEO');


--selecting the heaviest PayLoadMass and the exact flights
select [FlightNumber],[Date] ,[PayloadMass] from [dbo].[SpaceX_Launches_Data]
where [PayloadMass] =(select max([PayloadMass])
from [dbo].[SpaceX_Launches_Data]) 
order by [Date] desc

--determining the most common PayloadMass and orbits 
select ([Orbit]),
MIN([PayloadMass]) as 'Minimum PayloadMass',
MAX([PayloadMass])as 'Maximum PayloadMass',
AVG([PayloadMass]) as 'Average PayloadMass'
from [dbo].[SpaceX_Launches_Data]
GROUP BY [Orbit]
ORDER BY [Average PayloadMass] desc 

--determining LunchSite for each orbit 
SELECT
    [LaunchSite],
    [Orbit],
    COUNT(*) AS LaunchCount
FROM [dbo].[SpaceX_Launches_Data]
GROUP BY [LaunchSite], [Orbit]
ORDER BY [LaunchSite], [Orbit];


--Reused boosters
select distinct([Serial]),[ReusedCount]
from [dbo].[SpaceX_Launches_Data]
order by ReusedCount desc

-- Calculate the frequency of booster reuse
SELECT
    SUM(CASE WHEN [Reused] = 1 THEN 1 ELSE 0 END) AS ReusedCount,
    SUM(CASE WHEN [Reused] = 0 THEN 1 ELSE 0 END) AS NotReusedCount,
    (SUM(CASE WHEN [Reused] = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS ReusePercentage
FROM [dbo].[SpaceX_Launches_Data]

-- Calculate success rates for reused and non-reused boosters
SELECT
    SUM(CASE WHEN Reused = 1 AND Outcome IN ('True ASDS', 'True Ocean', 'True RTLS') THEN 1 ELSE 0 END) AS ReusedSuccessCount,
    SUM(CASE WHEN Reused = 0 AND Outcome IN ('False ASDS', 'False Ocean', 'None ASDS', 'None None') THEN 1 ELSE 0 END) AS NotReusedSuccessCount,
    (SUM(CASE WHEN Reused = 1 AND Outcome IN ('True ASDS', 'True Ocean', 'True RTLS') THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN Reused = 1 THEN 1 ELSE 0 END)) AS ReusedSuccessRate,
    (SUM(CASE WHEN Reused = 0 AND Outcome IN ('False ASDS', 'False Ocean', 'None ASDS', 'None None') THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN Reused = 0 THEN 1 ELSE 0 END)) AS NotReusedSuccessRate
FROM
    [dbo].[SpaceX_Launches_Data];


--landing analysis 
 --success and fail landings 
select
   SUM(CASE WHEN [GridFins]=1 and [Legs] =1 and [Outcome] IN ('True ASDS', 'True Ocean', 'True RTLS') THEN 1 ELSE 0 END) AS GEAR_OPENED_SUCCESSLANDING,
   SUM(CASE WHEN [GridFins]=1 and [Legs] =1 and [Outcome] IN ('False ASDS', 'False Ocean', 'None ASDS', 'None None') THEN 1 ELSE 0 END) AS GEAR_OPENED_FAILEDLANDING,
   SUM(CASE WHEN [GridFins]=0 and [Legs] =1 and [Outcome] IN ('True ASDS', 'True Ocean', 'True RTLS') THEN 1 ELSE 0 END) AS LEGS_OPENED_SUCCESSLANDING,
   SUM(CASE WHEN [GridFins]=1 and [Legs] =0 and [Outcome] IN ('True ASDS', 'True Ocean', 'True RTLS') THEN 1 ELSE 0 END) AS GRID_OPENED_SUCCESSLANDING
   
from [dbo].[SpaceX_Launches_Data]

 --NOTICABLE !
SELECT  [FlightNumber] FROM [dbo].[SpaceX_Launches_Data] 
WHERE ([GridFins]=1 and [Legs] =0 and [Outcome] IN ('True ASDS', 'True Ocean', 'True RTLS'))

 --Geographic distribution
 -- Count and distribution of landing sites
SELECT
    [Outcome],
    COUNT(*) AS LandCount,
    (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()) AS LandPercentage
FROM
   [dbo].[SpaceX_Launches_Data]
GROUP BY [Outcome] 
order by LandCount desc

--

-- Count and distribution of landing sites with latitude and longitude
SELECT
    [Outcome],
    COUNT(*) AS LandCount,
    (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()) AS LandPercentage,
    AVG([Latitude]) AS AvgLatitude,
    AVG([Longitude]) AS AvgLongitude
FROM
    [dbo].[SpaceX_Launches_Data]
GROUP BY [Outcome]
ORDER BY LandCount DESC;

-- Most repeated latitude and longitude for each landing site outcome
WITH LandingSiteCoords AS (
    SELECT
        [Outcome],
        [Latitude],
        [Longitude],
        COUNT(*) AS CoordCount
    FROM
        [dbo].[SpaceX_Launches_Data]
    GROUP BY [Outcome], [Latitude], [Longitude]
),
RankedCoords AS (
    SELECT
        [Outcome],
        [Latitude],
        [Longitude],
        CoordCount,
        ROW_NUMBER() OVER(PARTITION BY [Outcome] ORDER BY CoordCount DESC) AS RowNum
    FROM
        LandingSiteCoords
)
SELECT
    [Outcome],
    [Latitude],
    [Longitude],
    CoordCount AS LandCount,
    (CoordCount * 100.0 / SUM(CoordCount) OVER(PARTITION BY [Outcome])) AS LandPercentage
FROM
    RankedCoords
WHERE
    RowNum = 1
ORDER BY
    [Outcome], LandCount DESC;


-- Count and distribution of Falcon 9 booster block versions
SELECT
    [Block],
    COUNT(*) AS LaunchCount,
    (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()) AS LaunchPercentage
FROM
    [dbo].[SpaceX_Launches_Data]
GROUP BY [Block]
ORDER BY LaunchCount DESC;

create view sum_of_chakes as 
select distinct(year),COUNT([ID_Earthquake]) as sumearth, avg([Mw_Magnitude]) as average_magnitude from [dbo].[earthquake-database2]
WHERE YEAR >1899
group by year

select*from sum_of_chakes
order by year desc

create view tsunami as 
select distinct year,country,count([Flag_Tsunami]) as sum_tsunami ,avg([Focal_Depth]) as average_depth ,
avg([Mw_Magnitude]) as average_magnitude ,sum([Earthquake_Deaths]) as deathes , sum([Earthquake_Damage_in_M]) as damage_in_millions
from [dbo].[earthquake-database2]
where year >1899 and [Flag_Tsunami] is not null
group by country,[Flag_Tsunami],year

select*from tsunami
order by year desc

create view magnitude as 
select year,country,[Mw_Magnitude],[Focal_Depth],[Earthquake_Deaths],[Earthquake_Injuries],[Earthquakes_Houses_destroyed],[Earthquake_Damage_in_M]
from [dbo].[earthquake-database2]
where year>1899 and [Mw_Magnitude]>4 

select*from magnitude
order by [Mw_Magnitude] desc



select*from CovidDeaths$ order by 3,4
--select*from Covidvacsination$ order by 3,4

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as percentage
from [dbo].[CovidDeaths$] order by 1,2

--alter proc covid_serach_by_country
--@country varchar (20)
--as 
--begin
-- select location,total_cases,total_deaths,(total_deaths/total_cases)*100 as percentage
-- from [dbo].[CovidDeaths$] where location like '%@country%'
--end 

select Location,population,MAX(total_cases) as maxcases_num,max((total_cases/population))*100 as percentage
from [dbo].[CovidDeaths$] where continent is not null
group by location,population 
order by maxcases_num desc

create view maxxases as
select Location,population,MAX(total_cases) as maxcases_num,max((total_cases/population))*100 as percentage
from [dbo].[CovidDeaths$] where continent is not null
group by location,population 
order by maxcases_num desc


select continent,max(population),MAX(cast(total_deaths as int)) as maxdeath_num
from [dbo].[CovidDeaths$] where continent is not null
group by continent
order by maxdeath_num desc

select CovidDeaths$.continent,CovidDeaths$.location,CovidDeaths$.date,CovidDeaths$.population,[dbo].[Covidvacsination$].new_vaccinations,
sum(convert(int,Covidvacsination$.new_vaccinations)) over 
(partition by [dbo].[CovidDeaths$].location order by [dbo].[CovidDeaths$].location,[dbo].[CovidDeaths$].date) as rollingpeoplevacinated
from CovidDeaths$
join Covidvacsination$ on CovidDeaths$.location=Covidvacsination$.location and CovidDeaths$.date=Covidvacsination$.date
where CovidDeaths$.continent is not null
order by 2,3


--using a CTE to preform calculation on partition by
with vacvspop (continent,location,date,population,new_vaccinations,rollingpeoplevacinated)
as (
select CovidDeaths$.continent,CovidDeaths$.location,CovidDeaths$.date,CovidDeaths$.population,[dbo].[Covidvacsination$].new_vaccinations,
sum(convert(int,Covidvacsination$.new_vaccinations)) over 
(partition by [dbo].[CovidDeaths$].location order by [dbo].[CovidDeaths$].location,[dbo].[CovidDeaths$].date) as rollingpeoplevacinated
from CovidDeaths$
join Covidvacsination$ on CovidDeaths$.location=Covidvacsination$.location and CovidDeaths$.date=Covidvacsination$.date
where CovidDeaths$.continent is not null )
select*, (rollingpeoplevacinated/population)*100 as percentage
from vacvspop


create view percentagepupolaionvacc as
select CovidDeaths$.continent,CovidDeaths$.location,CovidDeaths$.date,CovidDeaths$.population,[dbo].[Covidvacsination$].new_vaccinations,
sum(convert(int,Covidvacsination$.new_vaccinations)) over 
(partition by [dbo].[CovidDeaths$].location order by [dbo].[CovidDeaths$].location,[dbo].[CovidDeaths$].date) as rollingpeoplevacinated
from CovidDeaths$
join Covidvacsination$ on CovidDeaths$.location=Covidvacsination$.location and CovidDeaths$.date=Covidvacsination$.date
where CovidDeaths$.continent is not null 

select*from percentagepupolaionvacc
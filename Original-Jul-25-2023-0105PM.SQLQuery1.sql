select *
from CovidDeaths
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths
from coviddeaths
order by 1,2

--checking the death rate in india
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from coviddeaths
where location like 'india'
order by 2

--checking the max death rate in india and when
select top 1 location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from coviddeaths
where location like 'india'
order by 5 desc

--checking the min death rate in india and when
select top 1 location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from coviddeaths
where location like 'india' and total_cases is not null and total_deaths is not null
order by 5

--total cases vs population (infection rate)
select location, date, total_cases, population, (total_cases/population)*100 as infection_rate
from coviddeaths
where location like 'india'
order by 2

--countries with highest infection rate compared to population
select location, population,  max((total_cases/population)*100) as infectionrate
from CovidDeaths
group by location, population
order by 3 desc

--countries with highest death rate per population
select location, max(cast(total_deaths as int)) as total_death_count
from coviddeaths
where continent is not null
group by location
order by 2 desc

--day with maximum number of deaths in each country
select cd.location,  max(cast(new_deaths as int)) as new_deaths, date
from CovidDeaths cd
join (select location, max(cast(new_deaths as int))  as max_deaths
from coviddeaths
group by location) as new_table
on new_table.location=cd.location and cd.new_deaths=new_table.max_deaths
where continent is not null
group by cd.location, date
order by 2 desc

select location, cast(new_deaths as int)
from CovidDeaths
where location='India'
order by 2 desc


--breaking down by continent with highest death count
select location, max(cast (total_deaths as int)) as total_death_per_continent
from coviddeaths
where continent is null
group by location
order by 2 desc



--global numbers
--total number of cases on each day across the world and death percentage each day across the world

/*select date, sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths, sum(cast (new_deaths as int))/ sum(new_cases)*100 as world_death_pct
from coviddeaths
where continent is not null 
group by date
order by sum(new_cases), date*/

select distinct date, sum(new_cases) over (order by date) as total_cases
from CovidDeaths
where continent is not null
order by 1






--total cases with death pct across the world
select sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths, sum(cast (new_deaths as int))/ sum(new_cases)*100 as world_death_pct
from coviddeaths
where continent is not null 
order by sum(new_cases)

--use of case statement
select location, date, new_cases, population, (new_cases/population)*100 as infection_rate,
case
when (new_cases/population)*100>0.05 then 'danger+'
else 'danger'
end
from coviddeaths
order by 1,2

--total population vs total cases
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_vac
from coviddeaths dea 
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--creating a cte
with popvsvac (continent,location,date,population,new_vaccinations,rolling_vac)
as (
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_vac
from coviddeaths dea 
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

)
select *, (rolling_vac/population)*100 as pct_rolling
from popvsvac






select distinct location, population,
rank () over(order by population desc) rnk,
dense_rank () over(order by population desc) drnk
from CovidDeaths
where continent is not null
order by 2 desc

select distinct location, cast(new_deaths as int), 
rank() over (partition by location order by cast(new_deaths as int)) rnk
from CovidDeaths
where continent is not null
order by 1,3


select location, date, 
avg(new_cases) over (order by date rows between 1 preceding and 5 following)
from coviddeaths
where continent is not null
order by 1

--average number of new cases over a rolling seven-day period for each location 
select distinct location,date, new_cases,
avg(new_cases) over (partition by location order by date rows between 6 preceding and 0 following)
from CovidDeaths
where continent is not null and new_cases is not null
order by 1,2


--rolling number of new cases in each location
select location, date, new_cases,
sum(new_cases) over (partition by location order by date rows between unbounded preceding and 0 following)
from CovidDeaths
where continent is not null and new_cases is not null
order by 1


--new cases in the world on a given date
select distinct date,
sum(new_cases) over (partition by date) new_cases_world
from CovidDeaths
where continent is not null and new_cases is not null
order by 1


--running sum of new cases throughout the world
select distinct date,
sum(new_cases) over (order by date) new_cases_world
from CovidDeaths
where continent is not null and new_cases is not null
order by 1


select distinct location,date, 
first_value (cast(new_deaths as int)) over (partition by location order by date)
from coviddeaths
where continent is not null and (cast(new_deaths as int)) is not null
order by 1


select location,date,  (cast(new_deaths as int)),
last_value (cast(new_deaths as int)) over (partition by location order by date)
from coviddeaths
where continent is not null and (cast(new_deaths as int)) is not null
order by 1
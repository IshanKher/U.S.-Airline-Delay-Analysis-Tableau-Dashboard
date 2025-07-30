----------------------- U.S. Airline Performance & Delay Analysis -----------------------

create schema US_Airline_performance;

create table airlines (
IATA_Codes varchar(10),
  Airline_Name varchar(100)
);

create table Airports (
IATA_Codes varchar(10),
Airort varchar(150),
City varchar(100),
State varchar(10),
Country varchar(100),
Latitude float,
Longitude float );

create table flights (
  year text,
  month text,
  day text,
  day_of_week text,
  airline text,
  flight_number text,
  tail_number text,
  origin_airport text,
  destination_airport text,
  scheduled_departure text,
  departure_time text,
  departure_delay text,
  taxi_out text,
  wheels_off text,
  scheduled_time text,
  elapsed_time text,
  air_time text,
  distance text,
  wheels_on text,
  taxi_in text,
  scheduled_arrival text,
  arrival_time text,
  arrival_delay text,
  diverted text,
  cancelled text,
  cancellation_reason text,
  air_system_delay text,
  security_delay text,
  airline_delay text,
  late_aircraft_delay text,
  weather_delay text
);


create table flights_sample as
select * from flights
limit 100000;

select count(*) as total_flights from flights_sample;

-------------- KPI --------------

-- Total Flights

select count(*) as total_flights 
from flights;

-- On-Time Performance (%)

select
	round(100.0 * sum(case when arrival_delay <= 15 then 1 else 0 end) / count(*),2) as on_time_percentage
from flights_sample
where cancelled = 0;

-- Average Arrival Delay

select
	round(avg(arrival_delay),2 ) as Average_Arrival_Delay
from flights_sample
where cancelled = 0;

-- Cancellation Rate

select
	round(100.0 * sum(cancelled) / count(*), 2) as cancellation_rate
from flights_sample;

-- Flights by Airline

select 
  airline,
  count(*) as total_flights,
  round(avg(arrival_delay), 2) as avg_arrival_delay,
  round(100.0 * sum(case when arrival_delay <= 15 then 1 else 0 end) / count(*), 2) as on_time_percentage,
  round(100.0 * sum(cancelled) / count(*), 2) as cancellation_rate
from flights_sample
group by airline
order by total_flights desc;

-- KPI Querying
-- 1. Delay Reason Breakdown

Select
	round(avg(arrival_delay), 2) as avg_arrival_delay,
    round(avg(departure_delay), 2) as avg_departure_delay,
    round(avg(air_system_delay), 2) as avg_air_system_delay,
    round(avg(security_delay), 2) as avg_security_delay,
	round(avg(airline_delay), 2) as avg_airline_delay,
    round(avg(late_aircraft_delay), 2) as avg_late_aircraft_delay,
	round(avg(weather_delay), 2) as avg_weather_delay
From flights
where cancelled = 0;

-- 2. Delay by Time of Day

select
	hour(scheduled_departure) as departure_hour,
    count(*) as total_flights,
	round(avg(arrival_delay), 2) as avg_arrival_delay
From flights
where cancelled = 0
group by hour(scheduled_departure)
order by departure_hour;

-- 3. Delay by Day of Week

select
	day_of_week,
    count(*) as total_flights,
    round(avg(arrival_delay), 2) as avg_arrival_delay
from flights_sample
where cancelled = 0
group by day_of_week
order by day_of_week;

-- 4. Delay by Month

select
	month,
    count(*) as total_flights,
    round(avg(arrival_delay), 2) as avg_arrival_delay
from flights_sample
where cancelled = 0
group by month
order by month;

-- Top 10 Busiest Routes

select
	origin_airport,
    destination_airport,
count(*) as total_flights
from flights_sample
group by origin_airport, destination_airport
order by total_flights desc
limit 10;

-- Top 10 Delayed Airports by avg arrival delay

select
	destination_airport,
    round(avg(arrival_delay),2) as Avg_arrival_delay,
	count(*) as Total_flights
from flights_sample
where cancelled = 0
group by destination_airport
having count(*) >100 -- filters noise from low-traffic airports
order by Avg_arrival_delay desc
limit 10;

-- Monthly Cancellation Trend

select
	month,
    count(*) as Total_flights,
	sum(cancelled) as cancelled_flights,
    round(100.0 * sum(cancelled) * count(*),2) as cancellation_rate
from flights_sample
group by month
order by month;

-- Diversion Summary

select
	count(*) as Total_flights,
    sum(diverted) as Total_diverted,
    round(100.0 * sum(diverted) / count(*), 2) as diversion_rate
from flights_sample;

-- Delay Statistics – Min, Max, Median (Arrival + Departure)
-- Arrival Delay Summary

select
	min(arrival_delay) as min_arrival_delay,
    max(arrival_delay) as max_arrival_delay,
	round(avg(arrival_delay),2) avg_arrival_delay
from flights_sample;

-- Departure Delay Summary

select
	min(departure_delay) as min_departure_delay,
    max(departure_delay) as max_departure_delay,
	round(avg(departure_delay),2) avg_departure_delay
from flights_sample
where cancelled = 0;


-- Scheduled vs Actual Duration

select
	round(avg(scheduled_time),2) as avg_scheduled_time,
	round(avg(air_time), 2) as avg_air_time, 
    round(avg(scheduled_time - air_time), 2) as avg_buffer_time
from flights
where cancelled = 0 and air_time is not null;

-- Weather Delay by Month

select
	month,
    round(avg(weather_delay), 2) as avg_weather_delay
from flights_sample
where cancelled = 0
group by month
order by month;

-- Top 10 Delayed Airlines

select
	airline,
    count(*) as total_flights,
    round(avg(arrival_delay),2) as Avg_arrival_delay
from flights_sample
where cancelled = 0
group by airline
having count(*) >100
order by Avg_arrival_delay
limit 10;

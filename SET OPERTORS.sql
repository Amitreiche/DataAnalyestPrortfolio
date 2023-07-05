-- Chapter 8 : SET OPERTORS
-- UNION , UNION ALL , INTERSECT , EXCEPT

create table A
(Aid int)

create table B
(Bid int)


insert into A
values (1), (2) , (3) , (4)


insert into B
values (3), (4) , (5) , (6)


select * from A
select * from b

-- UNION
-- Removes duplicates
-- The first query leads the name of the columns

select aid  as [new col] from A 
union
select Bid   from b


-- UNION ALL
-- Dont removes duplicates
select aid  as [new col] from A 
union all
select Bid  from b

-- Intersect
select aid  as [new col] from A 
Intersect
select Bid  from b


--EXCEPT
select aid  as [new col] from A 
EXCEPT
select Bid  from b


-- employees country , city
-- union
-- orders shipcountry , shipcity

select null as countery  , e.City from Employees e
union all
select o.ShipCountry , o.ShipCity from Orders o
union 
select e1.City , e1.LastName from Employees e1
order by Countery



 
select o.ShipCountry , o.ShipCity from Orders o
where o.ShipCountry in ('France' , 'Germany')
union
select e.Country, e.City from Employees e
where e.Country = 'USA'

select e.City from Employees as eexceptselect c.City from Customers as c
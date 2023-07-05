
--Project 2- SQL
--Amit Reichenstain
--Date 4/6/23


---1 
select p.ProductID, p.Name , p.Color, p.ListPrice, p.Size
from [Production].[Product] p
except
select s.productid, p.Name, p.Color, p.ListPrice, p.Size
from sales.salesorderdetail s 
join production.product p
on s.ProductID=p.ProductID

---2

With Cte_cus
as
(select  c.customerid, COALESCE(p.lastname,p.firstname,'Unknown') as 'Last Name',
COALESCE(p.firstname,'Unknown') as 'First Name' 
from sales.customer c 
left join person.person p 
on c.PersonID=p.BusinessEntityID
except
select c.customerid, COALESCE(p.lastname,'Unknown') as 'Last Name',
COALESCE(p.firstname,'Unknown') as 'First Name' 
from sales.customer c
left join person.person p 
on c.PersonID=p.BusinessEntityID
join sales.salesorderheader s 
on s.CustomerID=c.CustomerID)
select *
from Cte_cus
order by CustomerID



-----3
select distinct top 10 c.CustomerID, p.FirstName, p.LastName ,
count (oh.SalesOrderID) over (partition by c.CustomerID) as countoforders
from [Person].[Person] p
join [Sales].[Customer] c
on c.PersonID= p.BusinessEntityID
join [Sales].[SalesOrderHeader] oh
on oh.CustomerID= c.CustomerID
order by countoforders desc


----4
select p.FirstName , p.LastName, e.JobTitle ,e.HireDate,
count(e.JobTitle) over (partition by e.JobTitle)as countoftitle
from [HumanResources].[Employee]e
join [Person].[Person] p
on e.BusinessEntityID= p.BusinessEntityID

----5
select o.SalesOrderID, o.CustomerID ,o.LastName,o.FirstName,o.Lastorder,o.Previosorder
from
(select  oh.SalesOrderID ,oh.CustomerID,p.FirstName,p.LastName,
oh.OrderDate as Lastorder, 
lead(oh.OrderDate,1) over (partition by oh.CustomerID order by oh.OrderDate desc)as Previosorder,
rank () over (partition by oh.CustomerID order by oh.OrderDate desc) as rank
from [Sales].[SalesOrderHeader] oh
join  [Sales].[Customer] c
on oh.CustomerID= c.CustomerID
join [Person].[Person] p
on c.PersonID= p.BusinessEntityID) as o
where o.rank = 1
order by 3
----6
with cte_linetotal
as
(select distinct year(oh.OrderDate) as year , oh.SalesOrderID ,p.LastName, p.FirstName, oh.SubTotal as total,
row_number() over (partition by year(oh.OrderDate) order by oh.SubTotal desc) as highestotal
from [Sales].[SalesOrderHeader] oh
join [Sales].[SalesOrderDetail] od
on od.SalesOrderID= oh.SalesOrderID 
join [Sales].[Customer] c
on oh.CustomerID= c.CustomerID
join  [Person].[Person] p
on c.PersonID= p.BusinessEntityID)
select cte.year, cte.SalesOrderID, cte.LastName, cte.FirstName, cte.total
from cte_linetotal as cte
where cte.highestotal= 1
order by cte.year

----7
 
select * from
(select year (oh.OrderDate) as yy,month(oh.OrderDate) as mm,oh.SalesOrderID 
from [Sales].[SalesOrderHeader] as oh) o
pivot (count(SalesOrderID) for yy in ([2011],[2012],[2013],[2014])) as pvt
order by mm

---8
with cte1
as
(select cast(year(oh.OrderDate)as varchar (20))as year,month(oh.OrderDate)as month,
sum(od.LineTotal) as sum_price,
sum(sum(od.LineTotal))over (partition by year(oh.OrderDate) order by month(oh.OrderDate) rows between unbounded preceding and current row) as money
from [Sales].[SalesOrderHeader] as oh
join [Sales].[SalesOrderDetail] od
on od.SalesOrderID= oh.SalesOrderID
group by year(oh.OrderDate),month(oh.OrderDate)),
cte2
as
(select cast(year(oh.OrderDate)as varchar (20)) +'Grand Total:' as year,null as month,null as sum_price,sum(od.LineTotal)as grand_total
from [Sales].[SalesOrderHeader] as oh
join [Sales].[SalesOrderDetail] od
on od.SalesOrderID= oh.SalesOrderID
group by year(oh.OrderDate))
select * from cte1 
union
select * from cte2


----9
go 
with cte_1
as
(select p.BusinessEntityID as EmployeeID, concat(p.FirstName,' ',p.LastName ) as EmployeesFullname  , e.HireDate , 
DATEDIFF(mm,e.HireDate,getdate()) as Seniority 
from [HumanResources].[Employee] e
join [Person].[Person] p
on p.BusinessEntityID= e.BusinessEntityID),
Cte_2
as
(select d.name as DepartmentName, eh.businessentityid
from [HumanResources].[EmployeeDepartmentHistory] eh 
join [HumanResources].[Department] d
on d.DepartmentID=eh.DepartmentID
where eh.enddate is null)
select Cte_2.DepartmentName,cte_1.EmployeeID, cte_1.EmployeesFullname, cte_1.HireDate,cte_1.Seniority, 
Lead(cte_1.EmployeesFullname,1) over(partition by DepartmentName order by HireDate desc) as PreviousEmpName,
Lead(cte_1.HireDate,1) over(partition by DepartmentName order by HireDate desc) as PreviousEmpHDate,
datediff(dd,Lead(HireDate,1)over(partition by DepartmentName order by HireDate desc),HireDate) as DiffDays
from Cte_2 join Cte_1 on cte_1.EmployeeID=Cte_2.BusinessEntityID

---10

with Cte_emp
as
(select e.HireDate, d.DepartmentID ,
concat(e.BusinessEntityID, ' ',p.LastName,' ', p.FirstName) as Emp_Info
from [HumanResources].[EmployeeDepartmentHistory] d
join [HumanResources].[Employee] e
on d.BusinessEntityID= e.BusinessEntityID
join [Person].[Person] p
on p.BusinessEntityID=e.BusinessEntityID
where d.EndDate is null)

select Cte_emp.HireDate, Cte_emp.DepartmentID, 
STRING_AGG(Emp_Info,',') as Emp_Info
from Cte_emp
group by Cte_emp.HireDate, Cte_emp.DepartmentID
order by 1





select * from EmployeeData

select string_agg(department, ',') [Mode] from
(select *,dense_rank() over(order by [count All] desc) [DR] from
(select Department,count(*) [Count All] from EmployeeData
group by Department) x) y where DR = 1
select * from [dbo].[EmpSalary1]

select * from [dbo].[EmpSalary1]

select * from [dbo].[EmpSalary1]

select * from [dbo].[EmpSalary1]

--Union All
select * into #1 from(
select * from [dbo].[EmpSalary1]
union all
select * from [dbo].[EmpSalary2]
union all
select * from [dbo].[EmpSalary3]
union all
select * from [dbo].[EmpSalary4]
) x;

select * from #1
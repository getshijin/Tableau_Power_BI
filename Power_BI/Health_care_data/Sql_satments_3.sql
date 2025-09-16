

declare @i int = 1
declare @sql nvarchar(max)
select top 0 * into #2 from [dbo].[EmpSalary4]

while @i<=4
begin

set @sql ='insert into #2 select * from dbo.EmpSalary' + cast(@i as nvarchar(max))
exec sp_executesql @sql

set @i = @i+ 1
end

select * from #2
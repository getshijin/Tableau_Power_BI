----------------------------------------------------------------------------------------

select * into #3 from EmployeeData
delete from #3 where EmployeeID=10
select Salary,row_number() over (order by Salary) [rn] into #2 from #3

select * from #2


declare @l int
declare @m int, @n int

set @l = (select max(rn) from #2)
set @m = @l%2 --remainder
set @n = @l/2 --Integral Quotient

if @m = 0 --Even Number of records
begin
select avg(Salary) [Median Salary] from #2 where rn in (@n,@n+1)
end

if @m <> 0 --Even Number of records
begin
select avg(Salary) [Median Salary] from #2 where rn = @n+1
end
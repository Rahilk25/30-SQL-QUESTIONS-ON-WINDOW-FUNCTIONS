--Find the row number of each employee ordered by salary.

Select *, 
		row_number() over(order by salary desc) as rw_no
From employees;

--Rank employees based on their salaries.

Select *,
		rank() over (order by salary desc) as rnk
From employees


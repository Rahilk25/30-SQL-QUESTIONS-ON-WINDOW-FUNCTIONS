--Find the row number of each employee ordered by salary.

Select *, 
		row_number() over(order by salary desc) as rw_no
From employees;

--Rank employees based on their salaries.

Select *,
		rank() over (order by salary desc) as rnk
From employees

--Dense rank employees within each department based on salary.

Select *, 
		Dense_rank() over(partition by department order by salary desc) as rnk
From employees
Order by department

--Rank employees by hire date.
Select *, 
		rank() over(order by hire_date ) as rnk_hiredate
From employees

--Find the row number of each employee within their department based on hire date.

Select *,
		row_number() over(partition by department order by hire_date) as rnk_hiredate
From employees
Order by department


Advanced


--Show the employee name and salary of the highest-paid employee in each department.

Select emp_name, salary
From (
		Select *,
				rank() over(partition by department order by salary desc) as rnk
		From employees
) a
Where rnk = 1
Order by salary desc


	
--Calculate the rank difference between employees with the same salary across departments

	
With cte as (
	Select *,
			rank() over(partition by department order by salary desc) as rnk
	From employees
)


Select 
	t1.emp_name,
	t1.department,
	t1.salary,
	t1.rnk,
	t2.emp_name,
	t2.department,
	t2.salary,
	t2.rnk,
	abs(t1.rnk - t2.rnk) as rnk_diff
From cte t1
Join cte t2 
		On t1. salary = t2.salary 
		And t1. department <> t2.department


--Get the 2nd highest salary in each department, showing the employee name.

Select emp_name, department, salary
From
	(Select *,
			dense_rank() over(partition by department order by salary desc) as rnk
	From employees) a 
Where rnk = 2


--Find the average salary of the top 3 highest-paid employees in each department.

Select department, avg(salary) as avg_salary
From
	(Select *,
			row_number() over (partition by department order by salary desc) as rw
	From employees
    ) a
Where rw < 4
Group by department
Order by avg_salary desc


--Assign a dense rank to employees based on their hire date, resetting at each department change.

SELECT *, 
	dense_rank() over(partition by department order by salary desc) as denserank
From employees 









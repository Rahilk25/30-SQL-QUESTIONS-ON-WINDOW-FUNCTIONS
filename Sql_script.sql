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

--Calculate the difference in sales amount between consecutive sales.

Select *,
	abs(amount - lag(amount) over(order by sale_date)) as amt_diff
From sales1


--Find the sale amount for the next product sale.

Select *,
	 lead(amount) over(order by sale_date) as amt_diff
From sales1

--For each product, calculate the difference between the current and previous sale amount.

Select *,
	 lag(amount)  over(partition by product_name order by sale_date) as prev_amt,
	 amount - lag(amount)  over(partition by product_name order by sale_date) as diff
From sales1


--Show the next product sold for each store location.

Select *,
	 lead(product_name) over(partition by store_location order by sale_date) as nxt_product
From sales1



--Find the previous sale amount for each store location.

Select *,
	 lag(amount) over(partition by store_location order by sale_date) as prev_amount
From sales1



--Calculate the rolling difference between sales for each product.

Select *,
	 amount - lag(amount) over(partition by product_name order by sale_date) as prev_diff,
	 Lead(amount) over(partition by product_name order by sale_date) - amount as nxt_diff
From sales1



--Identify sales where the previous sale amount was higher than the current sale.

Select *
		
From
	(SELECT *,
		Lag(amount) over(order by sale_date) as prev_amount
	From sales1) a
Where prev_amount > amount


--Show total sales for each month, with the amount sold in the previous month.
With cte as 
	(Select 
		to_char(sale_date, 'Month') as month,
		sum(amount) as tot_sales,
		extract(month from sale_date) as mnt_num
	From sales1
	Group by month, extract(month from sale_date)
	Order by extract(month from sale_date))

Select 
	month,
	tot_sales,
	Lag(tot_sales) over(order by mnt_num) as prev
From cte

Or

With cte as (
Select distinct
	to_char(sale_date, 'Mon') mnt_name,
	extract(month from sale_date) as mnt,
	Sum(amount) over(partition by extract(month from sale_date)) as tot_amt

From sales1)

Select 
	mnt_name,
	tot_amt,
	lag(tot_amt) over(order by mnt) as prev_tot
From cte


--Determine the percentage increase or decrease in sales compared to the previous sale.

SELECT *,
		lag(amount) over(order by sale_date) as prev_sale,
		Round(((amount - lag(amount) over(order by sale_date)) / lag(amount) over(order by sale_date))* 100,2) || '%' As diff
FROM sales1

--List all sales where the amount is greater than the average sales amount for that product.

Select 
	sale_id,
	product_name,
	sale_date,
	amount,
	store_location
From

	(SELECT *,
			avg(amount) over() as avg_sale
	From sales1 ) a
Where amount > avg_sale





--Rank students based on their scores for each exam.

Select *,
	rank() over(partition by exam_date order by scores desc) as rnk
From student_scores 



--Determine the dense rank of students based on their scores.

Select *,
	dense_rank() over(order by scores desc) as dense_rnk
From student_scores


--Calculate the score difference between the current and previous exam for each student


Select *,
	Lag() over(partition by student_name order by exam_date) as prev_exam_score,
	score - Lag() over(partition by student_name order by exam_date) as diff
From student_scores


--List students who improved their score compared to the previous exam

Select student_name, score, prev_exam_score
From (
	Select *,
		Lag(score) over(partition by student_name order by exam_date) as prev_exam_score) a
Where score > prev_exam_score
Reset the rank for students after every 5 students based on their scores.
--Determine the highest score for each class.

With cte as (
Select *,
	row_number() over(partition by class order by score desc) as rw_no
From student_scores)

Select class,score
From cte
Where rw_no = 1


--Reset the rank for students after every 5 students based on their scores.




Select 
	student_id,
	student_name,
	exam_date,
	score,
	class,
	rank() over(partition by group order by score desc) as rnk
From
	(Select *,
		(row_number() over(order by score desc) -1) / 5 as group
	From student_scores) a

--Show the count of students who improved their score compared to the previous exam.

With cte as (
Select *,
	lag(score) over(partition by student_name order by exam_date) as prev_score
From student_scores)
	 
Select count(student_name) as student_count 
From cte 
where prev_score < score


--Find the percentage increase in scores for each student compared to their previous exam.

With cte as (
Select *,
	lag(score) over(partition by student_name order by exam_date) as prev_score
From student_scores)

select 
	student_id,
	student_name,
	exam_date,
	score,
	Round((score - prev_score)/prev_score * 100,2) || '%' as perc_diff
From cte 


--List all students with their scores and whether they improved from the last exam (yes/no).


Select student_name, 
	score,
	lag(score) over(partition by student_name order by exam_date) as prev_score,
	case
		When score > lag(score) over(partition by student_name order by exam_date) then 'Yes'
			Else 'No' 
		End as improved_status
From student_scores



--Rank students within their class, considering ties.


CREATE TABLE student_scores (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    exam_date DATE,
    score INT,
    class VARCHAR(50)
);


Select *,
	rank() over(partition by class order by score desc) as rnk
From student_scores










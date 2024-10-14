# 30-SQL-QUESTIONS-ON-WINDOW-FUNCTIONS

### 1. **Dataset 1: Employee Salaries**

**Schema**:
```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE
);

INSERT INTO employees (emp_id, emp_name, department, salary, hire_date)
VALUES
(1, 'Alice', 'HR', 55000, '2018-01-15'),
(2, 'Bob', 'IT', 75000, '2017-05-23'),
(3, 'Charlie', 'Finance', 82000, '2019-03-12'),
(4, 'Diana', 'IT', 60000, '2020-07-19'),
(5, 'Eve', 'HR', 52000, '2021-11-05'),
(6, 'Frank', 'Finance', 72000, '2020-08-10'),
(7, 'Grace', 'HR', 61000, '2016-12-20'),
(8, 'Hank', 'IT', 69000, '2019-01-11'),
(9, 'Ivy', 'Finance', 73000, '2018-09-30'),
(10, 'Jack', 'HR', 54000, '2017-10-15'),
(11, 'Kate', 'IT', 78000, '2016-06-01'),
(12, 'Leo', 'HR', 59000, '2019-02-21'),
(13, 'Mia', 'Finance', 76000, '2019-04-10'),
(14, 'Nick', 'IT', 65000, '2018-12-05'),
(15, 'Olivia', 'HR', 53000, '2020-09-29'),
(16, 'Paul', 'Finance', 70000, '2021-03-22'),
(17, 'Quincy', 'IT', 72000, '2020-01-07'),
(18, 'Rita', 'HR', 60000, '2020-05-15'),
(19, 'Steve', 'Finance', 78000, '2019-08-18'),
(20, 'Tom', 'IT', 81000, '2018-07-23'),
(21, 'Uma', 'HR', 58000, '2020-02-17'),
(22, 'Victor', 'Finance', 75000, '2021-05-10'),
(23, 'Wendy', 'IT', 70000, '2020-10-05'),
(24, 'Xander', 'HR', 62000, '2017-11-22'),
(25, 'Yara', 'Finance', 82000, '2021-06-30');
```

#### Basic to Medium:
1. Find the row number of each employee ordered by salary.

```sql
Select *, 
		row_number() over(order by salary desc) as rw_no
From employees;
```

2. Rank employees based on their salaries.
```sql
Select *,
		rank() over (order by salary desc) as rnk
From employees
```

3. Dense rank employees within each department based on salary.
```sql
Select *, 
		Dense_rank() over(partition by department order by salary desc) as rnk
From employees
Order by department
```
4. Rank employees by hire date.
```sql
Select *, 
		rank() over(order by hire_date ) as rnk_hiredate
From employees
```
5. Find the row number of each employee within their department based on hire date.
```sql
Select *,
		row_number() over(partition by department order by hire_date) as rnk_hiredate
From employees
Order by department
```
#### Advanced:
```sql
6. Show the employee name and salary of the highest-paid employee in each department.

Select emp_name, salary
From (
		Select *,
				rank() over(partition by department order by salary desc) as rnk
		From employees
) a
Where rnk = 1
Order by salary desc
```

	
7. Calculate the rank difference between employees with the same salary across departments

```sql	
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
```

8. Get the 2nd highest salary in each department, showing the employee name.
```sql
Select emp_name, department, salary
From
	(Select *,
			dense_rank() over(partition by department order by salary desc) as rnk
	From employees) a 
Where rnk = 2
```

9. Find the average salary of the top 3 highest-paid employees in each department.
```sql
Select department, avg(salary) as avg_salary
From
	(Select *,
			row_number() over (partition by department order by salary desc) as rw
	From employees
    ) a
Where rw < 4
Group by department
Order by avg_salary desc
```

10. Assign a dense rank to employees based on their hire date, resetting at each department change.
```sql
SELECT *, 
	dense_rank() over(partition by department order by salary desc) as denserank
From employees 
```
### 2. **Dataset 2: Sales Data**

**Schema**:
```sql
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    sale_date DATE,
    amount DECIMAL(10, 2),
    store_location VARCHAR(50)
);

INSERT INTO sales (sale_id, product_name, sale_date, amount, store_location)
VALUES
(1, 'Laptop', '2023-01-15', 1500.00, 'New York'),
(2, 'Headphones', '2023-02-03', 200.00, 'Chicago'),
(3, 'Laptop', '2023-03-10', 1600.00, 'San Francisco'),
(4, 'Phone', '2023-02-21', 800.00, 'New York'),
(5, 'Tablet', '2023-05-15', 600.00, 'Chicago'),
(6, 'Laptop', '2023-04-12', 1450.00, 'Chicago'),
(7, 'Phone', '2023-01-20', 850.00, 'San Francisco'),
(8, 'Headphones', '2023-03-18', 220.00, 'New York'),
(9, 'Tablet', '2023-04-25', 620.00, 'San Francisco'),
(10, 'Laptop', '2023-06-10', 1550.00, 'New York'),
(11, 'Phone', '2023-07-02', 790.00, 'Chicago'),
(12, 'Tablet', '2023-07-20', 640.00, 'New York'),
(13, 'Headphones', '2023-05-30', 210.00, 'San Francisco'),
(14, 'Laptop', '2023-08-15', 1620.00, 'Chicago'),
(15, 'Phone', '2023-09-01', 800.00, 'San Francisco'),
(16, 'Tablet', '2023-08-23', 650.00, 'New York'),
(17, 'Headphones', '2023-10-05', 230.00, 'Chicago'),
(18, 'Laptop', '2023-11-12', 1580.00, 'New York'),
(19, 'Phone', '2023-12-10', 815.00, 'Chicago'),
(20, 'Tablet', '2023-12-28', 680.00, 'San Francisco'),
(21, 'Laptop', '2023-11-22', 1650.00, 'San Francisco'),
(22, 'Headphones', '2023-11-30', 240.00, 'New York'),
(23, 'Phone', '2023-12-15', 820.00, 'New York'),
(24, 'Tablet', '2023-12-05', 670.00, 'Chicago'),
(25, 'Laptop', '2023-12-28', 1700.00, 'Chicago');
```

#### Basic to Medium:

11. Calculate the difference in sales amount between consecutive sales.
```sql
Select *,
	abs(amount - lag(amount) over(order by sale_date)) as amt_diff
From sales1
```

12. Find the sale amount for the next product sale.
```sql
Select *,
	 lead(amount) over(order by sale_date) as amt_diff
From sales1
```
13. For each product, calculate the difference between the current and previous sale amount.
```sql
Select *,
	 lag(amount)  over(partition by product_name order by sale_date) as prev_amt,
	 amount - lag(amount)  over(partition by product_name order by sale_date) as diff
From sales1
```

14. Show the next product sold for each store location.
```sql
Select *,
	 lead(product_name) over(partition by store_location order by sale_date) as nxt_product
From sales1
```


15. Find the previous sale amount for each store location.
```sql
Select *,
	 lag(amount) over(partition by store_location order by sale_date) as prev_amount
From sales1
```

#### Advanced:


16. Calculate the rolling difference between sales for each product.
```sql
Select *,
	 amount - lag(amount) over(partition by product_name order by sale_date) as prev_diff,
	 Lead(amount) over(partition by product_name order by sale_date) - amount as nxt_diff
From sales1
```


17. Identify sales where the previous sale amount was higher than the current sale.
```sql
Select *
		
From
	(SELECT *,
		Lag(amount) over(order by sale_date) as prev_amount
	From sales1) a
Where prev_amount > amount
```

18. Show total sales for each month, with the amount sold in the previous month.
```sql With cte as 
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
```
Or
```sql
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
```

19. Determine the percentage increase or decrease in sales compared to the previous sale.
```sql
SELECT *,
		lag(amount) over(order by sale_date) as prev_sale,
		Round(((amount - lag(amount) over(order by sale_date)) / lag(amount) over(order by sale_date))* 100,2) || '%' As diff
FROM sales1
```
20. List all sales where the amount is greater than the average sales amount for that product.
```sql
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
```
### 3. **Dataset 3: Student Scores**

**Schema**:
```sql
CREATE TABLE student_scores (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    exam_date DATE,
    score INT,
    class VARCHAR(50)
);

INSERT INTO student_scores (student_id, student_name, exam_date, score, class)
VALUES
(1, 'Alice', '2023-01-15', 85, 'A'),
(2, 'Bob', '2023-01-15', 90, 'A'),
(3, 'Charlie', '2023-01-15', 78, 'A'),
(4, 'Diana', '2023-02-01', 88, 'B'),
(5, 'Eve', '2023-02-01', 95, 'B'),
(6, 'Frank', '2023-02-01', 84, 'B'),
(7, 'Grace', '2023-03-10', 92, 'A'),
(8, 'Hank', '2023-03-10', 87, 'A'),
(9, 'Ivy', '2023-03-10', 82, 'A'),
(10, 'Jack', '2023-04-15', 76, 'B'),
(11, 'Kate', '2023-04-15', 89, 'B'),
(12, 'Leo', '2023-04-15', 91, 'B'),
(13, 'Mia', '2023-05-12', 80, 'A'),
(14, 'Nick', '2023-05-12', 93, 'A'),
(15, 'Olivia', '2023-05-12', 87, 'A'),
(16, 'Paul', '2023-06-05', 86, 'B'),
(17, 'Quincy', '2023-06-05', 88, 'B'),
(18, 'Rita', '2023-06-05', 90, 'B'),
(19, 'Steve', '2023-07-07', 95, 'A'),
(20, 'Tom', '2023-07-07', 89, 'A'),
(21, 'Uma', '2023-07-07', 84, 'A'),
(22, 'Victor', '2023-08-10', 78, 'B'),
(23, 'Wendy', '2023-08-10', 90, 'B'),
(24, 'Xander', '2023-08-10', 85, 'B'),
(25, 'Yara', '2023-09-12', 92, 'A');
```

#### Basic to Medium:

21. Rank students based on their scores for each exam.
```sql
Select *,
	rank() over(partition by exam_date order by scores desc) as rnk
From student_scores 
```


22. Determine the dense rank of students based on their scores.
```sql
Select *,
	dense_rank() over(order by scores desc) as dense_rnk
From student_scores
```

23. Calculate the score difference between the current and previous exam for each student

```sql
Select *,
	Lag() over(partition by student_name order by exam_date) as prev_exam_score,
	score - Lag() over(partition by student_name order by exam_date) as diff
From student_scores
```

24. List students who improved their score compared to the previous exam
```sql
Select student_name, score, prev_exam_score
From (
	Select *,
		Lag(score) over(partition by student_name order by exam_date) as prev_exam_score) a
Where score > prev_exam_score
Reset the rank for students after every 5 students based on their scores.
```
25. Determine the highest score for each class.
```sql
With cte as (
Select *,
	row_number() over(partition by class order by score desc) as rw_no
From student_scores)

Select class,score
From cte
Where rw_no = 1
```
#### Advanced:

26. Reset the rank for students after every 5 students based on their scores.



```sql
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
```
27. Show the count of students who improved their score compared to the previous exam.
```sql
With cte as (
Select *,
	lag(score) over(partition by student_name order by exam_date) as prev_score
From student_scores)
	 
Select count(student_name) as student_count 
From cte 
where prev_score < score
```

28. Find the percentage increase in scores for each student compared to their previous exam.
```sql
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
```

29. List all students with their scores and whether they improved from the last exam (yes/no).

```sql
Select student_name, 
	score,
	lag(score) over(partition by student_name order by exam_date) as prev_score,
	case
		When score > lag(score) over(partition by student_name order by exam_date) then 'Yes'
			Else 'No' 
		End as improved_status
From student_scores
```


30. Rank students within their class, considering ties.

```sql
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
```





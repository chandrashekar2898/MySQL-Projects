create database employee_management;
use employee_management;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

select * from employee;
select * from jobdepartment;
select * from leaves;
select * from qualification;
select * from salarybonus;
select * from payroll;

-- QUESTIONS
-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
select count(*)as total_employees from employee;


-- Which departments have the highest number of employees?
select j.jobdept,count(emp_id)as total_employees from employee e
join jobdepartment as j
on e.job_id=j.job_id
group by j.jobdept order by
total_employees desc;


-- What is the average salary per department?
select
    a.jobdept,
    avg(e.amount) as avg_salary
from jobdepartment as a
join salarybonus as e
on a.job_id = e.job_id
group by  a.jobdept;
DESC salarybonus;


--  who are the top 5 highest-paid employees?
select e.firstname,a.annual,e.job_id
 from employee as e 
 join salarybonus as a
 on e.job_id=a.job_id
 order by a.annual desc limit 5; 


-- What is the total salary expenditure across the company?
select sum(total_amount)  total_expenditure from payroll;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
select jobdept,count(name)as total from jobdepartment
 group by jobdept;


-- What is the average salary range per department?
select min(salaryrange) from jobdepartment;


-- Which job roles offer the highest salary?
select
    a.name,
    e.amount as highest_salary
from jobdepartment as a
join salarybonus as e
on a.job_id = e.job_id
order by e.amount desc
limit 1;


-- Which departments have the highest total salary allocation?
select
    a.jobdept,
    sum(e.amount) as highest_salary
from jobdepartment as a
join salarybonus as e
on a.job_id = e.job_id
group by  a.jobdept
order by highest_salary desc;


-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?
select count(distinct e.emp_id) AS employees_with_qualification
from employee e
join qualification q
    on e.emp_id = q.emp_id;
    
    
-- Which positions require the most qualifications?
select position , count(*) as qualification_count from qualification
group by position
order by qualification_count desc;


-- Which employees have the highest number of qualifications?
select * from employee;
select concat(e.firstname," ",e.lastname)as employee_name,
count(qualid)as qualification_count
from employee as e
join qualification as a
on e.emp_id=a.emp_id
group by employee_name
order by qualification_count desc;


-- 4. LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?*/
SELECT YEAR(date) AS leave_year,
       COUNT(DISTINCT emp_id) AS employees_on_leave
FROM leaves
GROUP BY leave_year
ORDER BY employees_on_leave DESC;


-- What is the average number of leave days taken by its employees per department?
SELECT
    j.jobdept,
    COUNT(l.leave_id) * 1.0 / COUNT(DISTINCT e.emp_id) AS avg_leaves_per_employee
FROM employee e
JOIN jobdepartment j
ON e.job_id = j.job_id
LEFT JOIN leaves l
ON e.emp_id = l.emp_id
GROUP BY j.jobdept;


-- Which employees have taken the most leaves?

SELECT CONCAT(e.firstname,' ',e.lastname) AS employee_name,
       COUNT(a.leave_id) AS total_leaves
FROM employee e
JOIN leaves a
ON e.emp_id=a.emp_id
GROUP BY employee_name
ORDER BY total_leaves DESC;


-- What is the total number of leave days taken company-wide?
select count(*)as leaves_taken from leaves;


-- How do leave days correlate with payroll amounts?
SELECT
    leave_id,
    AVG(total_amount) AS avg_payroll
FROM payroll
GROUP BY leave_id
ORDER BY leave_id;


-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
select  sum(annual) / 12 as total_monthly_payroll
from salarybonus;


-- What is the average bonus given per department?
select e.jobdept,avg(a.bonus)as avg_bonus from jobdepartment as e
join salarybonus as a
on e.job_id=a.job_id
group by e.jobdept;


-- Which department receives the highest total bonuses?
select e.jobdept,sum(a.bonus)as highest_total from salarybonus as a
join jobdepartment as e
on e.job_id=a.job_id group by e.jobdept
order by highest_total desc limit 5;


-- What is the average value of total_amount after considering leave deductions?
SELECT AVG(total_amount) AS avg_payroll
FROM payroll;
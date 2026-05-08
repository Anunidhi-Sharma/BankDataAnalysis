CREATE DATABASE bank_finance;
use bank_finance;
# create table bank finance 1
CREATE TABLE bank_finance1(
id INT,
loan_amnt DECIMAL,
int_rate DECIMAL(5,4),
grade VARCHAR(5),
sub_grade VARCHAR(5), 
home_ownership VARCHAR(50),
verification_status VARCHAR(50),
issue_d DATE,
loan_status VARCHAR(50),
addr_state VARCHAR(5)
);

drop table bank_finance1;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bank_finance1.csv'
INTO TABLE bank_finance1
FIELDS TERMINATED BY ','
IGNORE 1 ROWS; 

select * from bank_finance1; 

#create table 2 bank_finance 2

CREATE TABLE bank_finance2(
id INT,
revol_bal DECIMAL,
total_pymnt FLOAT,
total_rec_prncp DECIMAL,
total_rec_int DECIMAL,
last_pymnt_d DATE,
last_pymnt_amnt DECIMAL
) ;
# drop table bank_finance2;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bank_finance2.csv'
INTO TABLE bank_finance2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@col1, @col2, @col3, @col4, @col5, @last_pymnt_d, @col7)
SET
id = @col1,
revol_bal = @col2,
total_pymnt = @col3,
total_rec_prncp = @col4,
total_rec_int = @col5,
last_pymnt_amnt = @col7,
last_pymnt_d = NULLIF(@last_pymnt_d, '')
;

/*(
@col1, @col2, @col3, @col4, @col5,
@col6, @col7, @col8, @col9, @col10,
@col11, @col12, @col13, @col14, @col15,
@col16, @col17, @col18, @col19, @col20,
@col21, @col22, @col23, @col24, @col25

)
SET
id = @col1,
total_pymnt = @col15,
total_rcvd_prncp = @col7,
total_rec_int = @col18,
revol_bal = @col9,
last_pymnt_d = NULLIF(@col22,''),
last_pymnt_amnt = @col23;
*/
select * from bank_finance2;

SHOW VARIABLES LIKE 'secure_file_priv';

# create Master Table
Use bank_finance;
CREATE TABLE master_table AS
SELECT 
f1.id ,
f1.loan_amnt ,
f1.int_rate ,
f1.grade ,
f1.sub_grade , 
f1.home_ownership ,
f1.verification_status ,
f1.issue_d ,
f1.loan_status ,
f1.addr_state,

f2.total_pymnt ,
f2.total_rcvd_prncp ,
f2.total_rec_int ,
f2.revol_bal ,
f2.last_pymnt_d ,
f2.last_pymnt_amnt
from bank_finance1 f1 join bank_finance2 f2
on f1.id=f2.id;

drop table master_table;
select * from master_table;

# KPI Creation (Core Analysis)
# KPI -1 -Total Payment
select sum(total_pymnt) as total_payment_received
From master_table;

# KPI -2 -Total Loan
select sum(loan_amnt) as total_loan
From master_table;

# KPI -2 -Total Loan
select sum(total_pymnt) as total_payment_received
From master_table;

# KPI -3 -Total Interest
select sum(total_rcvd_prncp) as total_interest_received
From master_table;

# KPI -4 - Recovery Percent
select round(sum(total_pymnt)*10.0/sum(loan_amnt),2)  as recovery_percent
From master_table;

# KPI -5 - Default Rate
select round(sum(CASE when loan_status = 'Charged Off' THEN 1 END)*10.0/COUNT(id),2)  as total_payment_received
From master_table;

# Pivot Type Queries
# Year wise loan Amount

use bank_finance;
select year(issue_d) AS YEAR,
sum(loan_amnt) As total_loan
from master_table
group by year(issue_d)
order by year;

# Grade and Sub-grade vs Revolving Balance

Use bank_finance;
select grade,sub_grade,sum(revol_bal) as total_revolving_balance
from master_table
group by grade,sub_grade
order by grade,sub_grade;

# Verified vs Non Verified payment

Use bank_finance;
select verification_status,sum(total_pymnt) As Total_Payment
from master_table
group by verification_status
order by verification_status desc;

# State and Month Wise Loan Status

select addr_state,month(issue_d),loan_status
from master_table
group by addr_state,month(issue_d),loan_status
order by addr_state;
 
# Home Ownership vs Last Payment
select home_ownership,sum(total_pymnt) As total_payment
from master_table
group by home_ownership;


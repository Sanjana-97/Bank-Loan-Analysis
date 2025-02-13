create database Bank_loan_project;
use Bank_loan_project;

select * from bank_data;

---Total Loan applications
select count(id) as Total_loan_applications from bank_data;

--- Total Funded amount
select sum(loan_amount)/1000000 as "Total_Funded_Amount in Millions" from bank_data;

--- Total Amount received
select sum(total_payment)/1000000 as "Total_Amount_Received in Millions" from bank_data;

select distinct purpose from bank_data;

--- Average Interest rate
select purpose, round(avg(int_rate),2)*100 as "Avg_int_rate" from bank_data
group by purpose
order by Avg_int_rate desc;

--- Average DTI(Debt-to-Income Ratio) grouped by month
select year(issue_date) as "Year", month(issue_date) as "Month", round(avg(dti),2)*100 as "Avg_DTI" from bank_data 
where year(issue_date)= 2021
group by year(issue_date),month(issue_date)
order by month;

-- Distinct Loan Statuses
select distinct loan_status from bank_data;

--- Good loan vs Bad loan
-- Good loan applications (in %)
select count(case when loan_Status in ('Fully Paid','Current') then id end) * 100 / count(id) as "Good_loan_applications(%)"
from bank_data;

-- Good loan applications
select count(case when loan_Status in ('Fully Paid','Current') then id end)  as "Good_loan_applications", count(id) as "Total_applications"
from bank_data;

-- Total amt received in good loan applications
select sum(total_payment) / 1000000 as "Total_amt_received( in millions )" from bank_data
where loan_status in ('Fully Paid', 'Current');

-- Bad loan applications (in %)
select count(case when loan_Status = 'Charged Off' then id end) * 100 / count(id) as "Bad_loan_applications(%)"
from bank_data;

-- Bad loan applications
select count(case when loan_Status = 'Charged Off' then id end)  as "Bad_loan_applications", count(id) as "Total_applications"
from bank_data;

-- Total amt received in Bad loan applications
select sum(total_payment) / 1000000 as "Total_amt_received( in millions )" from bank_data
where loan_status  = 'Charged Off';

--- Month over month total amt received
with Monthly_Totals as (
select year(issue_date) as "Year", month(issue_date) as "Month", sum(total_payment) as "Payment_received"
from bank_data
where year(issue_date) = 2021
group by year(issue_date), month(issue_date)
),
monthovermonth as (
select T1.Year, T1.Month, 
       T1.Payment_received as 'Current_month_paymemt',T2.Payment_received as 'Previous_month_payment',
       T1.Payment_received - T2.Payment_received as 'Month_over_month_Amt'
from
Monthly_Totals T1
left join
Monthly_Totals T2 on T1.Year= T2.Year and T1.month = T2.month + 1
)
select Year, Month, Month_over_month_Amt from monthovermonth
order by month;

--- Month over month average interest rate 
with Monthly_Interest as (
select year(issue_date) as Year, month(issue_date) as Month, 
round(avg(int_rate)*100,2) as Avg_int_rate
from bank_data
where year(issue_date) = 2021
group by year(issue_date), month(issue_date)
),
monthovermonth as (
select T1.Year, T1.Month, 
       T1.Avg_int_rate as Current_Avg_int_rate,
       T2.Avg_int_rate as Previous_Avg_int_rate,
       round((T1.Avg_int_rate - T2.Avg_int_rate),2) as Month_over_month_Avg_int_rate
from Monthly_Interest T1
left join Monthly_Interest T2 
on T1.Year = T2.Year 
and T1.Month = T2.Month + 1
)
select Year, Month, Current_Avg_int_rate, Previous_Avg_int_rate, Month_over_month_Avg_int_rate 
from monthovermonth
order by Month;
/*Question 1
We want to understand more about the movies that families are watching. The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.*/

select f.title as film_title,
ca.name as category_name,
count(r.rental_id) as rental_count

from   category ca
join   film_category fc
on     ca.category_id = fc.category_id
join   film f
on     f.film_id = fc.film_id
join inventory i
on f.film_id = i.film_id
join rental r
on i.inventory_id=r.inventory_id

where ca.name in ('Animation')
group by film_title,category_name
order by category_name,film_title;

/*Question 2
Now we need to know how the length of rental duration of these family-friendly movies compares to the duration that all movies are rented for. Can you provide a table with the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories? Make sure to also indicate the category that these family-friendly movies fall into.*/

select f.title as title,
ca.name as name,
f.rental_duration as rental_duration,

ntile(4)over(order by f.rental_duration) as standard_quartile

from   category ca
join   film_category fc
on     ca.category_id = fc.category_id
join   film f
on    f.film_id = fc.film_id

where ca.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family' ,'Music')
order by standard_quartile,rental_duration;

/*Question 3
Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category for each corresponding rental duration category. The resulting table should have three columns*/

with t1 as (select ca.name as name,
ntile(4)over(order by f.rental_duration) as standard_quartile,
f.title as title
from   category ca
join   film_category fc
on     ca.category_id = fc.category_id
join   film f
on     f.film_id = fc.film_id
where ca.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family' ,'Music')
)

select name,standard_quartile,
count(title)
from t1
group by name,standard_quartile
order by name,standard_quartile;

/*Question 4:
We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for. Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month.*/

select 
date_part ('month',r.rental_date) as rental_month,
date_part ('year',r.rental_date) as rental_year,
s.store_id as store_id,
count (*) as count_rentals

from store s
join staff st
on s.store_id=st.store_id
join rental r
on st.staff_id=r.staff_id

group by rental_month,rental_year,s.store_id
order by count_rentals desc ;

/*Question 5
We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and what was the amount of the monthly payments. Can you write a query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers?*/

with t1 as (
select
concat (c.first_name,' ', c.last_name) as fullname,
sum (p.amount) as amount
from payment p
join customer c
on p.customer_id=c.customer_id
group by fullname
order by amount desc
limit 10
),

t2 as (
select 
date_trunc ('month',p.payment_date) as pay_mon,
concat (c.first_name,' ', c.last_name) as fullname,
count (p.payment_id) as pay_countpermonth,
sum (p.amount) as amount
from payment p
join customer c
on p.customer_id=c.customer_id
group by pay_mon,fullname
)

select t2.pay_mon, t1.fullname, t2.pay_countpermonth, t2.amount
from t1
left join t2
on t1.fullname = t2.fullname
order by fullname, pay_mon；

/*Question 6
Finally, for each of these top 10 paying customers, I would like to find out the difference across their monthly payments during 2007. Please go ahead and write a query to compare the payment amounts in each successive month. Repeat this for each of these 10 paying customers. Also, it will be tremendously helpful if you can identify the customer name who paid the most difference in terms of payments.*/

with t1 as (
select
concat (c.first_name,' ', c.last_name) as fullname,
sum (p.amount) as amount
from payment p
join customer c
on p.customer_id = c.customer_id
group by fullname
order by amount desc
limit 10),

t2 as (
select 
date_trunc ('month', p.payment_date) as pay_mon,
concat (c.first_name,' ', c.last_name) as fullname,
count (p.payment_id) as pay_countpermonth,
sum (p.amount) as amount
from payment p
join customer c
on p.customer_id = c.customer_id
group by pay_mon, fullname
)
select t2.pay_mon, t1. fullname, t2.pay_countpermonth, t2.amount,
t2.amount- lag(t2.amount) over(partition by t2.fullname order by t2.pay_mon) as amount_month_diff
from t1
left join t2
on t1.fullname = t2.fullname
order by fullname, pay_mon;
USE MAVENMOVIES;

SELECT count(*)
FROM RENTAL;

SELECT count(*)
FROM INVENTORY;

SELECT count(*)
FROM ACTOR;

select count(*)
from film;

select count(*)
from customer;

-- PROVIDE MONTHLY REVENUE PER YEAR FOR INVESTORS

select x.month_name, x.year, sum(amount) as total
from(select *,extract(year from payment_date) as year,date_format(payment_date,"%b") as month_name
from payment) as x
group by x.month_name,x.year;


-- PROVIDE A LIST OF TOP 10 CUSTOMER BASED ON REVENUE TO PUSH OFFERES TO THEM 
select * from payment;
select * from customer;

select *
from customer
where customer_id in (
select x.customer_id
from(select customer_id,sum(amount) as revenue
from payment
group by customer_id
order by revenue desc
limit 10) as x);


-- DATA ANALYSIS PROJECT FOR RENTAL MOVIES BUSINESS
-- THE STEPS INVOLVED ARE EDA, UNDERSTANDING THR SCHEMA AND ANSWERING THE AD-HOC QUESTIONS
-- BUSINESS QUESTIONS LIKE EXPANDING MOVIES COLLECTION AND FETCHING EMAIL IDS FOR MARKETING ARE INCLUDED
-- HELPING COMPANY KEEP A TRACK OF INVENTORY AND HELP MANAGE IT.


-- You need to provide customer firstname, lastname and email id to the marketing team --

select first_name,last_name,email
from customer;

-- How many movies are with rental rate of $0.99? --

select count(*) as rental_reate_
from film 
where rental_rate=0.99;


-- We want to see rental rate and how many movies are in each rental category --

select rental_rate,count(*) 
from film
group by rental_rate;


-- Which rating has the most films? --

select rating,count(*) as no_of_movies
from film
group by rating
order by no_of_movies desc
limit 1;


-- Which rating is most prevalant in each store? --

select i.store_id,f.rating,count(inventory_id) as copies
from film as f left join inventory as i
on f.film_id=i.film_id
group by i.store_id,f.rating
order by store_id,copies desc;


-- List of films by Film Name, Category, Language --

select f.title,c.name,l.name
from film as f left join film_category as fc
on f.film_id=fc.film_id
left join category as c on fc.category_id=c.category_id
left join language as l on f.language_id=l.language_id;

-- How many times each movie has been rented out?

select F.TITLE ,count(RENTAL_ID)as NUMBER_OF_RENTALS 
FROM RENTAL as R LEFT JOIN INVENTORY AS INV 
on R.INVENTORY_ID= INV.INVENTORY_ID LEFT JOIN FILM AS F 
ON INV.FILM_ID = F.FILM_ID
GROUP BY F.TITLE
ORDER BY NUMBER_OF_RENTALS DESC;



-- REVENUE PER FILM (TOP 10 GROSSERS)

SELECT RENTAL_ID_TRANSACTIONS.TITLE,SUM(P.AMOUNT) AS GROSS_REVENUE
FROM 	(SELECT R.RENTAL_ID,F.FILM_ID,F.TITLE
		FROM RENTAL AS R LEFT JOIN INVENTORY AS INV
			ON R.INVENTORY_ID = INV.INVENTORY_ID
					LEFT JOIN FILM AS F
			ON INV.FILM_ID = F.FILM_ID) AS RENTAL_ID_TRANSACTIONS
            LEFT JOIN PAYMENT AS P
            ON RENTAL_ID_TRANSACTIONS.RENTAL_ID = P.RENTAL_ID
GROUP BY RENTAL_ID_TRANSACTIONS.TITLE
ORDER BY GROSS_REVENUE DESC
LIMIT 10;

-- Most Spending Customer so that we can send him/her rewards or debate points


SELECT P.CUSTOMER_ID,SUM(AMOUNT) AS SPENDING, C.FIRST_NAME,C.LAST_NAME
FROM PAYMENT AS P LEFT JOIN CUSTOMER AS C
		ON P.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY P.CUSTOMER_ID
ORDER BY SPENDING DESC
LIMIT 1;
   

-- Which Store has historically brought the most revenue?

select ST.STORE_ID,sum(P.AMOUNT) as REVENUE_PER_STORE 
from PAYMENT as P
LEFT join STAFF as ST on P.STAFF_ID = ST.STAFF_ID 
GROUP BY ST.STORE_ID;

-- How many rentals we have for each month

SELECT MONTHNAME(RENTAL_DATE) AS MONTH_NAME,EXTRACT(YEAR FROM RENTAL_DATE) AS YEAR_NUMBR, COUNT(rental.rental_id) AS NUMBER_RENTALS
FROM RENTAL
GROUP BY EXTRACT(YEAR FROM RENTAL_DATE),MONTHNAME(RENTAL_DATE)
ORDER BY NUMBER_RENTALS DESC;
-- Reward users who have rented at least 30 times (with details of customers)

select CUSTOMER_ID,count(RENTAL_ID) as rcount
FROM RENTAL
group by CUSTOMER_ID
having rcount>=30;

SELECT LOYAL_CUSTOMERS.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,C.EMAIL,AD.PHONE
FROM (SELECT CUSTOMER_ID,COUNT(RENTAL_ID) AS NUMBER_OF_RENTALS
FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING NUMBER_OF_RENTALS >=30
ORDER BY CUSTOMER_ID) AS LOYAL_CUSTOMERS LEFT JOIN CUSTOMER AS C
		ON LOYAL_CUSTOMERS.CUSTOMER_ID = C.CUSTOMER_ID
		LEFT JOIN ADDRESS AS AD
		ON C.ADDRESS_ID = AD.ADDRESS_ID;



-- Could you pull all payments from our first 100 customers (based on customer ID)
select customer_id,payment_id,amount,rental_id
from payment
where customer_id<101;

-- Now I’d love to see just payments over $5 for those same customers, since January 1, 2006

select customer_ID,payment_id,amount,rental_id,payment_date
from payment 
where  amount> 4.99 and payment_date > 2006-01-01;

SELECT CUSTOMER_ID,RENTAL_ID,AMOUNT,PAYMENT_DATE
FROM PAYMENT
WHERE AMOUNT > 5 OR CUSTOMER_ID = 42 OR CUSTOMER_ID = 53 OR CUSTOMER_ID = 60 OR CUSTOMER_ID = 75;

SELECT CUSTOMER_ID,RENTAL_ID,AMOUNT,PAYMENT_DATE
FROM PAYMENT
WHERE AMOUNT > 5 AND CUSTOMER_ID IN (42,53,60,75);

-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?

select title,special_features from film
where special_features like "behind the scenes";

-- unique movie ratings and number of movies
select rating,count(film_id) as numberofmovies
from film
group by rating;

-- Could you please pull a count of titles sliced by rental duration?

select rental_duration,count(film_id) as numberoffilms
from film
group by rental_duration;

select rating,rental_duration,count(film_id) as numberoffilms
from film
group by rating,rental_duration;

-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION

SELECT RATING,
	COUNT(FILM_ID)  AS COUNT_OF_FILMS,
    MIN(LENGTH) AS SHORTEST_FILM,
    MAX(LENGTH) AS LONGEST_FILM,
    AVG(LENGTH) AS AVERAGE_FILM_LENGTH,
    AVG(RENTAL_DURATION) AS AVERAGE_RENTAL_DURATION
FROM FILM
GROUP BY RATING
ORDER BY AVERAGE_FILM_LENGTH;

-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate,
-- grouped by replacement cost?


SELECT REPLACEMENT_COST,
	COUNT(FILM_ID) AS NUMBER_OF_FILMS,
    MIN(RENTAL_RATE) AS CHEAPEST_RENTAL,
    MAX(RENTAL_RATE) AS EXPENSIVE_RENTAL,
    AVG(RENTAL_RATE) AS AVERAGE_RENTAL
FROM FILM
GROUP BY REPLACEMENT_COST
ORDER BY REPLACEMENT_COST;

-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”

SELECT CUSTOMER_ID,COUNT(*) AS TOTAL_RENTALS
FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING TOTAL_RENTALS < 15;

-- “I’d like to see if our longest films also tend to be our most expensive rentals.
-- Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”

SELECT TITLE,LENGTH,RENTAL_RATE
FROM FILM
ORDER BY LENGTH DESC
LIMIT 20;

-- CATEGORIZE MOVIES AS PER LENGTH

SELECT TITLE,LENGTH,
	CASE
		WHEN LENGTH < 60 THEN 'UNDER 1 HR'
        WHEN LENGTH BETWEEN 60 AND 90 THEN '1 TO 1.5 HRS'
        WHEN LENGTH > 90 THEN 'OVER 1.5 HRS'
        ELSE 'ERROR'
	END AS LENGTH_BUCKET
FROM FILM;



-- CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC

SELECT DISTINCT TITLE,
	CASE
		WHEN RENTAL_DURATION <= 4 THEN 'RENTAL TOO SHORT'
        WHEN RENTAL_RATE >= 3.99 THEN 'TOO EXPENSIVE'
        WHEN RATING IN ('NC-17','R') THEN 'TOO ADULT'
        WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'TOO SHORT OR TOO LONG'
        WHEN DESCRIPTION LIKE '%Shark%' THEN 'NO_NO_HAS_SHARKS'
        ELSE 'GREAT_RECOMMENDATION_FOR_CHILDREN'
	END AS FIT_FOR_RECOMMENDATTION
FROM FILM;


-- “I’d like to know which store each customer goes to, and whether or
-- not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”
 
 select first_name,last_name ,
	case 
	when store_id=1 and active=1 then 'store 1 active'
    when store_id=1 and active=0 then 'store 1 inactive'
    when store_id=2 and active=1 then 'store 2 active'
    when store_id=2 and active=0 then 'store 2 inactive'
    else 'error'
    end as storeandstatus
    from customer;
    

-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”

SELECT DISTINCT INVENTORY.INVENTORY_ID,
				INVENTORY.STORE_ID,
                FILM.TITLE,
                FILM.DESCRIPTION 
FROM FILM INNER JOIN INVENTORY ON FILM.FILM_ID = INVENTORY.FILM_ID;

-- Actor first_name, last_name and number of movies

SELECT * FROM FILM_ACTOR;
SELECT * FROM ACTOR;

SELECT 
	ACTOR.ACTOR_ID,
    ACTOR.FIRST_NAME,
    ACTOR.LAST_NAME,
    COUNT(FILM_ACTOR.FILM_ID) AS NUMBER_OF_FILMS
FROM ACTOR
	LEFT JOIN FILM_ACTOR
		ON ACTOR.ACTOR_ID= FILM_ACTOR.ACTOR_ID
GROUP BY
	ACTOR.ACTOR_ID;
    
    
    -- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”

SELECT FILM.TITLE,
	COUNT(FILM_ACTOR.ACTOR_ID) AS NUMBER_OF_ACTORS
FROM FILM 
	LEFT JOIN FILM_ACTOR
		ON FILM.FILM_ID = FILM_ACTOR.FILM_ID
GROUP BY 
	FILM.TITLE;
    
-- “Customers often ask which films their favorite actors appear in. It would be great to have a list of
-- all actors, with each title that they appear in. Could you please pull that for me?”
    
SELECT ACTOR.FIRST_NAME,
		ACTOR.LAST_NAME,
        FILM.TITLE
FROM ACTOR INNER JOIN FILM_ACTOR
	ON ACTOR.ACTOR_ID = FILM_ACTOR.ACTOR_ID
			INNER JOIN FILM
	ON FILM_ACTOR.FILM_ID = FILM.FILM_ID
ORDER BY
ACTOR.LAST_NAME,
ACTOR.FIRST_NAME;

-- “The Manager from Store 2 is working on expanding our film collection there.
-- Could you pull a list of distinct titles and their descriptions, currently available in inventory at store 2?”

SELECT DISTINCT FILM.TITLE,
	FILM.DESCRIPTION
FROM FILM
	INNER JOIN INVENTORY
		ON FILM.FILM_ID = INVENTORY.FILM_ID
        AND INVENTORY.STORE_ID = 2;

-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”

SELECT * FROM STAFF;
SELECT * FROM ADVISOR;

(SELECT FIRST_NAME,
		LAST_NAME,
        'ADVISORS' AS DESIGNATION
FROM ADVISOR

UNION

SELECT FIRST_NAME,
		LAST_NAME,
        'STAFF MEMBER' AS DESIGNATION
FROM STAFF);

    
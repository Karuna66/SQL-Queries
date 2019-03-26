USE Sakila;


-- Display first & last name
SELECT first_name as 'First Name', last_name as 'Last Name' FROM actor;

-- concantenated and converted name to upper case ( they were already upper case)
SELECT UPPER(CONCAT(first_name,"  ",last_name)) as "Actor Name" From actor;

-- Displayed the actor with firstname joe
SELECT actor_id,first_name,last_name FROM actor
WHERE first_name ='Joe';

-- Displayed the name with GEN in last name
SELECT first_name,last_name FROM actor
WHERE last_name LIKE '%GEN%';

-- Displayed the name with li in lastname and order by the last and first
SELECT first_name,last_name FROM actor 
WHERE last_name LIKE '%li%'
ORDER BY Last_name,first_name;

-- Diplayed the countries in Afghanistan', 'Bangladesh','China
SELECT country_id,country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh','China');

-- ADDing Description column
ALTER TABLE actor
ADD COLUMN description BLOB;

-- Deleting description column
ALTER TABLE actor
DROP COLUMN description;

-- last name & count of it
SELECT last_name as "Last Name",COUNT(*) AS 'Count of last name' FROM actor
GROUP BY last_name;

-- Diplay the last names & count only if 2 or more have the same last name
SELECT last_name as "Last Name",COUNT(*) AS Last_name_count FROM actor
GROUP BY last_name
HAVING last_name_count >=2;

-- Change the Groucho to harpo
UPDATE actor
SET first_name = "HARPO"
WHERE first_name ="GROUCHO" AND last_name = "WILLIAMS";

-- verifying the update
SELECT * FROM actor
WHERE first_name = 'HARPO';

-- Schema of the address table one way is SHOW CREATE TABLE sakila.address; I preferred
DESC sakila.address;

-- JOIN address and staff table and display the names and address
SELECT s.first_name AS 'First Name', s.last_name AS 'Last Name', a.address as 'Address' 
FROM staff as s
JOIN address as a
ON s.address_id = a.address_id;

-- JOIN payment and staff to get total for August
SELECT CONCAT(s.first_name,s.last_name) AS "Staff Name",SUM(p.amount) AS "Total for August" FROM payment as p
JOIN staff AS s
ON p.staff_id=s.staff_id
WHERE payment_date LIKE '2005-05-%'
GROUP BY p.staff_id;

-- Display each film and the number of actors
SELECT f.title as "Film Title",count(*) AS "Total Actors" FROM film_actor AS fa
JOIN film as f
ON fa.film_id = f.film_id
GROUP BY fa.film_id;

-- how many copies of the film Hunchback Impossible exist
SELECT count(*) as "Copies of Hunchback Impossible" FROM inventory
WHERE film_id = (SELECT film_id FROM film WHERE title = "Hunchback Impossible");

-- Join Payment and customer to list total paid by each
SELECT cu.first_name as "First Name",cu.last_name as "Last Name",SUM(p.amount) AS "Paid Amount"  FROM payment as p
JOIN customer as cu
ON p.customer_id = cu.customer_id
GROUP BY p.customer_id
ORDER BY cu.last_name;

-- films starting with the letters `K` and `Q` have also soared in popularity in English
SELECT title AS Title FROM film 
WHERE (title LIKE 'K%' Or title LIKE 'Q%') And language_id=(SELECT language_id FROM language WHERE name = 'English');

-- display all actors who appear in the film `Alone Trip`
SELECT CONCAT(first_name," ",last_name) AS "Actors in movie ALONE TRIP" FROM actor WHERE actor_id IN (
SELECT actor_id FROM film_actor WHERE film_id = (
SELECT film_id FROM film WHERE title = 'ALONE TRIP') GROUP BY film_id);

--  names and email addresses of all Canadian customers
SELECT cu.first_name AS "First Name", cu.last_name AS "Last Name",cu.email AS "Email" FROM address AS a 
JOIN customer AS cu ON a.address_id = cu.address_id
JOIN city as c ON  a.city_id = c.city_id
JOIN country as co ON c.country_id = co.country_id
WHERE co.country = 'CANADA';

-- Identify all movies categorized as _family_ films.
SELECT title as 'Categorized as Family Films' FROM film WHERE film_id IN (
SELECT film_id FROM film_category WHERE category_id = (
SELECT category_id FROM category WHERE name = 'Family'
));

-- Display the most frequently rented movies in descending order.
SELECT f.title AS "Film Title",COUNT(i.film_id) AS "Count of Rental" FROM inventory AS i
JOIN rental AS r
ON i.inventory_id = r.inventory_id
JOIN film AS f
ON i.film_id = f.film_id
GROUP BY i.film_id
ORDER BY COUNT(i.film_id) DESC;

-- Confirm display how much business, in dollars, each store brought in 
SELECT s.store_id  AS "Store ",CONCAT("$",FORMAT(SUM(p.amount),2)) AS "Amount bought in" FROM staff AS s
JOIN payment AS p ON s.staff_id = p.staff_id
JOIN store AS st ON s.store_id = st.store_id
GROUP BY s.store_id;

-- display for each store its store ID, city, and country
SELECT st.store_id,c.city,co.country FROM address AS a
JOIN store AS st ON a.address_id = st.address_id
JOIN city AS c ON a.city_id = c.city_id
JOIN country AS co ON c.country_id = co.country_id;

/*  top five genres in gross revenuefilm_categoryfilm_categorycategoryinventorypaymentrental(multily items sold by price) in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
SELECT c.name as Genre ,CONCAT("$",FORMAT(SUM(p.amount),2)) AS Total_Sale_Amount FROM payment as p
JOIN rental AS r ON p.rental_id = r.rental_id
JOIN inventory AS i ON r.inventory_id = i.inventory_id
JOIN film_category AS fc ON i.film_id = fc.film_id
JOIN category AS c ON fc.category_id = c.category_id
GROUP BY Genre
ORDER BY Total_sale_Amount DESC;

-- you would like to have an easy way of viewing the Top five genres by gross revenue and display
CREATE VIEW Top_five_genres AS
SELECT c.name as Genre ,CONCAT("$",FORMAT(SUM(p.amount),2)) AS Total_Sale_Amount FROM payment as p
JOIN rental AS r ON p.rental_id = r.rental_id
JOIN inventory AS i ON r.inventory_id = i.inventory_id
JOIN film_category AS fc ON i.film_id = fc.film_id
JOIN category AS c ON fc.category_id = c.category_id
GROUP BY Genre
ORDER BY Total_sale_Amount DESC;
SELECT * FROM Top_five_genres LIMIT 5;

-- DELETE view created above
DROP VIEW Top_five_genres;








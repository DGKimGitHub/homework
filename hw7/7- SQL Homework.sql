USE sakila;

-- * 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT concat(first_name,' ',last_name) AS 'Actor Name' FROM actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, 
-- "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name='JOE';

-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT first_name, last_name FROM actor
WHERE last_name LIKE '%GEN%';

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, 
-- as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor ADD description;
ALTER TABLE actor MODIFY description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP middle_name;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT DISTINCT last_name, COUNT(last_name) AS 'count' 
FROM actor 
GROUP BY last_name;

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) as 'count'
FROM actor
GROUP BY last_name HAVING COUNT(last_name) > 1;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
SELECT actor_id
FROM actor
WHERE first_name='GROUCHO' AND last_name = 'WILLIAMS';
-- Write a query to fix the record.
UPDATE actor SET first_name='HARPO' 
WHERE actor_id = 172;

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_name=IF(first_name='HARPO', 'GROUCHO','MUCHO GROUCHO')
WHERE actor_id=172;
SELECT first_name from actor where actor_id=172;
-- check again...

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT S.first_name, S.last_name, A.address
FROM staff S JOIN address A
ON S.address_id=A.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT S.first_name, S.last_name, SUM(P.amount)
FROM staff S JOIN payment P
ON S.staff_id=P.staff_id
WHERE MONTH(P.payment_date)=8
GROUP BY S.staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT F.title, COUNT(FA.actor_id)
FROM film F INNER JOIN film_actor FA
ON F.film_id=FA.film_id
GROUP BY F.film_id;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(inventory_id)
FROM inventory
WHERE film_id IN 
(
 SELECT film_id
 FROM film
 WHERE title='Hunchback Impossible'
);

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT C.first_name, C.last_name, SUM(P.amount)
FROM customer C JOIN payment P
ON C.customer_id=P.customer_id
GROUP BY P.customer_id
ORDER BY C.last_name;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE TITLE LIKE 'K%' OR title LIKE 'Q%' AND original_language_id IN
(
 SELECT language_id
 FROM language
 WHERE name='ENGLISH'
);

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
 SELECT actor_id
 FROM film_actor
 WHERE film_id IN
 (
  SELECT film_id
  FROM film
  WHERE title='Alone Trip'
 )
);

-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT C.first_name, C.last_name, C.email
FROM customer C JOIN (
	 address A JOIN (
	 city CI JOIN country CO 
        ON CI.country_id=CO.country_id) 
        ON A.city_id=CI.city_id) 
        ON C.address_id=A.address_id
WHERE CO.country='CANADA';

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.
SELECT title
FROM film
WHERE film_id IN
(
 SELECT film_id
 FROM film_category
 WHERE category_id IN
 (
  SELECT category_id
  FROM category
  WHERE name='FAMILY'
 )
);

-- * 7e. Display the most frequently rented movies in descending order.
SELECT F.title, COUNT(R.rental_ID) AS 'times_rented'
FROM film F RIGHT JOIN (inventory I JOIN rental R ON I.inventory_id=R.inventory_id) ON F.film_id=I.film_id
GROUP BY F.film_id
ORDER BY COUNT(R.rental_ID) DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT STO.store_id, SUM(P.amount)
FROM store STO JOIN payment P ON STO.manager_staff_id=P.staff_id
GROUP BY STO.store_id;

-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT STO.store_id, CI.city, CO.country
FROM store STO JOIN (address A JOIN (city CI JOIN country CO ON CI.country_id=CO.country_id) ON A.city_id=CI.city_id) ON STO.address_id=A.address_id;

-- * 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT CAT.name, SUM(P.amount)
FROM category CAT JOIN (film_category FC JOIN (inventory I JOIN (rental R JOIN payment P ON R.rental_id=P.rental_id) ON I.inventory_id=R.inventory_id) ON FC.film_id=I.film_ID) ON CAT.category_id=FC.category_id
GROUP BY CAT.name
ORDER BY SUM(P.amount) DESC
LIMIT 5;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five AS
SELECT CAT.name, SUM(P.amount)
FROM category CAT JOIN (film_category FC JOIN (inventory I JOIN (rental R JOIN payment P ON R.rental_id=P.rental_id) ON I.inventory_id=R.inventory_id) ON FC.film_id=I.film_ID) ON CAT.category_id=FC.category_id
GROUP BY CAT.name
ORDER BY SUM(P.amount) DESC
LIMIT 5;

-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five;
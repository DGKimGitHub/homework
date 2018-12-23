USE sakila;

-- 1a
SELECT first_name, last_name FROM actor;

-- 1b
SELECT concat(first_name,' ',last_name) AS 'Actor Name' FROM actor;

-- 2a
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name='JOE';

-- 2b
SELECT first_name, last_name FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c
SELECT first_name, last_name FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a
ALTER TABLE actor ADD middle_name TEXT AFTER first_name;

-- 3b
ALTER TABLE actor MODIFY middle_name BLOB;

-- 3c
ALTER TABLE actor DROP middle_name;

-- 4a
SELECT DISTINCT last_name, COUNT(last_name) AS 'count' 
FROM actor 
GROUP BY last_name;

-- 4b
SELECT last_name, COUNT(last_name) as 'count'
FROM actor
GROUP BY last_name HAVING COUNT(last_name) > 1;

-- 4c
SELECT actor_id
FROM actor
WHERE first_name='GROUCHO' AND last_name = 'WILLIAMS';
-- Had some difficulty getting this to run using the above as a subquery.  Wouldn't let me use
-- FROM in the subquery where the same table is being updated
 
UPDATE actor SET first_name='HARPO' 
WHERE actor_id = 172;

-- 4d
UPDATE actor SET first_name=IF(first_name='HARPO', 'GROUCHO','MUCHO GROUCHO')
WHERE actor_id=172;

SELECT first_name from actor where actor_id=172;

-- 5a
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

-- 6a
SELECT S.first_name, S.last_name, A.address
FROM staff S JOIN address A
ON S.address_id=A.address_id;

-- 6b
SELECT S.first_name, S.last_name, SUM(P.amount)
FROM staff S JOIN payment P
ON S.staff_id=P.staff_id
WHERE MONTH(P.payment_date)=8
GROUP BY S.staff_id;

-- 6c
SELECT F.title, COUNT(FA.actor_id)
FROM film F INNER JOIN film_actor FA
ON F.film_id=FA.film_id
GROUP BY F.film_id;

-- 6d
SELECT COUNT(inventory_id)
FROM inventory
WHERE film_id IN 
(
 SELECT film_id
 FROM film
 WHERE title='Hunchback Impossible'
);

-- 6e
SELECT C.first_name, C.last_name, SUM(P.amount)
FROM customer C JOIN payment P
ON C.customer_id=P.customer_id
GROUP BY P.customer_id
ORDER BY C.last_name;

-- 7a
SELECT title
FROM film
WHERE TITLE LIKE 'K%' OR title LIKE 'Q%' AND original_language_id IN
(
 SELECT language_id
 FROM language
 WHERE name='ENGLISH'
);

-- 7b
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

-- 7c
SELECT C.first_name, C.last_name, C.email
FROM customer C JOIN (
	 address A JOIN (
	 city CI JOIN country CO 
        ON CI.country_id=CO.country_id) 
        ON A.city_id=CI.city_id) 
        ON C.address_id=A.address_id
WHERE CO.country='CANADA';

-- 7d
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

-- 7e
SELECT F.title, COUNT(R.rental_ID) AS 'times_rented'
FROM film F RIGHT JOIN (inventory I JOIN rental R ON I.inventory_id=R.inventory_id) ON F.film_id=I.film_id
GROUP BY F.film_id
ORDER BY COUNT(R.rental_ID) DESC;

-- 7f
SELECT STO.store_id, SUM(P.amount)
FROM store STO JOIN payment P ON STO.manager_staff_id=P.staff_id
GROUP BY STO.store_id;

-- 7g
SELECT STO.store_id, CI.city, CO.country
FROM store STO JOIN (address A JOIN (city CI JOIN country CO ON CI.country_id=CO.country_id) ON A.city_id=CI.city_id) ON STO.address_id=A.address_id;

-- 7h
SELECT CAT.name, SUM(P.amount)
FROM category CAT JOIN (film_category FC JOIN (inventory I JOIN (rental R JOIN payment P ON R.rental_id=P.rental_id) ON I.inventory_id=R.inventory_id) ON FC.film_id=I.film_ID) ON CAT.category_id=FC.category_id
GROUP BY CAT.name
ORDER BY SUM(P.amount) DESC
LIMIT 5;

-- 8a
CREATE VIEW top_five AS
SELECT CAT.name, SUM(P.amount)
FROM category CAT JOIN (film_category FC JOIN (inventory I JOIN (rental R JOIN payment P ON R.rental_id=P.rental_id) ON I.inventory_id=R.inventory_id) ON FC.film_id=I.film_ID) ON CAT.category_id=FC.category_id
GROUP BY CAT.name
ORDER BY SUM(P.amount) DESC
LIMIT 5;

-- 8b
SELECT * FROM top_five;

-- 8c
DROP VIEW top_five;
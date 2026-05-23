-- iTunes Music Analysis

# 1)Who is the senior most employee based on job title?
SELECT 
    employee_id,
    first_name,
    last_name,
    title
FROM 
    employee
ORDER BY 
    CASE 
        WHEN title = 'Senior General Manager' THEN 1
        WHEN title = 'General Manager' THEN 2
        WHEN title = 'Sales Manager' THEN 3
        WHEN title = 'IT Manager' THEN 4
        WHEN title = 'IT Staff' THEN 5
        WHEN title = 'Sales Support Agent' THEN 6
        ELSE 99
    END
LIMIT 1;


#2) Which countries have the most Invoices?
SELECT 
    billing_country,
    COUNT(*) AS total_invoices
FROM 
    invoice
GROUP BY 
    billing_country
ORDER BY 
    total_invoices DESC;
    
    
#3) What are top 3 values of total invoice?
SELECT DISTINCT 
    total
FROM 
    invoice
ORDER BY 
    total DESC
LIMIT 3;


#4) Which city has the best customers? 
SELECT 
    billing_city,
    ROUND(SUM(total), 2) AS total_sales
FROM 
    invoice
GROUP BY 
    billing_city
ORDER BY 
    total_sales DESC
LIMIT 1;


# 5)Who is the best customer? 
SELECT 
    c.customer_id,
    c.first_name , c.last_name ,
    ROUND(SUM(i.total), 2) AS total_spent
FROM 
    customer c
JOIN 
    invoice i ON c.customer_id = i.customer_id
GROUP BY 
    c.customer_id, c.first_name , c.last_name
ORDER BY 
    total_spent DESC
LIMIT 1;


# 6) Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A 
SELECT DISTINCT
    c.email,
    c.first_name,
    c.last_name,
    g.name AS genre
FROM
    customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE
    g.name = 'Rock'
ORDER BY
    c.email ASC;


#7)Top 10 Rock Artists by Track Count
SELECT
    ar.name AS artist_name,
    COUNT(*) AS rock_track_count
FROM
    track t
JOIN genre g ON t.genre_id = g.genre_id
JOIN album_1 al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
WHERE
    g.name = 'Rock'
GROUP BY
    ar.artist_id, ar.name
ORDER BY
    rock_track_count DESC
LIMIT 10;


#8) Tracks longer than the average song
SELECT
    name,
    milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY
    milliseconds DESC;


#9) Total amount spent by each customer on each artist
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ar.artist_id,
    ar.name AS artist_name,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_spent
FROM
    customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album_1 al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    ar.artist_id,
    artist_name
ORDER BY
    total_spent DESC;


#10)  Most popular music genre per country
WITH genre_sales AS (
    SELECT
        c.country,
        g.name AS genre,
        COUNT(*) AS purchase_count
    FROM
        customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY
        c.country, g.genre_id, g.name
),
ranked_genres AS (
    SELECT
        country,
        genre,
        purchase_count,
        RANK() OVER (PARTITION BY country ORDER BY purchase_count DESC) AS rnk
    FROM genre_sales
)
SELECT
    country,
    genre,
    purchase_count
FROM
    ranked_genres
WHERE
    rnk = 1
ORDER BY
    country, genre;


#11)  Top customer by spending in each country
WITH customer_spending AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.country,
        SUM(i.total) AS total_spent
    FROM
        customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY
        c.customer_id, customer_name, c.country
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY country ORDER BY total_spent DESC) AS rnk
    FROM customer_spending
)
SELECT country, customer_name, total_spent
FROM ranked
WHERE rnk = 1;


#12) Most popular artists
SELECT
    ar.name AS artist_name,
    COUNT(*) AS track_purchases
FROM
    invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN album_1 al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY
    ar.artist_id,artist_name
ORDER BY
    track_purchases DESC
LIMIT 10;


#13)Most popular song
SELECT
    t.name AS song_name,
    COUNT(*) AS times_sold
FROM
    invoice_line il
JOIN track t ON il.track_id = t.track_id
GROUP BY
    t.track_id,song_name
ORDER BY
    times_sold DESC
LIMIT 1;



#14)Average prices of different types of music
SELECT
    mt.name AS media_type,
    ROUND(AVG(il.unit_price), 2) AS avg_price
FROM
    invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN media_type mt ON t.media_type_id = mt.media_type_id
GROUP BY
    mt.name
ORDER BY
    avg_price DESC;
    


#15) Most popular countries for music purchases
SELECT
    billing_country AS country,
    COUNT(*) AS total_purchases
FROM
    invoice
GROUP BY
    billing_country
ORDER BY
    total_purchases DESC;




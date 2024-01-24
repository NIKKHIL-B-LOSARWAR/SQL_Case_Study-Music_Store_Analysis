/* HERE WE HAVE SOLVED PROBLEMS BY WRITING THE SQL QUERY*/


--  #########################################################################################
-- 			QUESTION SET-1 :

-- 			Q.1 Who is the senior most employee based on job title?

-- hint : each employee have given the level

select * from employee;

select  first_name, last_name, employee_id
from employee
order by levels 
limit 1;

-- 			Q. 2 Which countries have the most Invoices?

-- hint : we have billing_country colm, consistes country namae.

select * from invoice;

select billing_country, count(billing_country) as no_of_bills
from invoice
group by billing_country
order by no_of_bills desc
limit 1;



-- 			Q.3  What are top 3 values of total invoice?

select * from invoice;


select *  
from invoice
order by total desc
limit 3;


/*			Q.4  Which city has the best customers? We would like to throw a promotional Music 
			Festival in the city we made the most money. Write a query that returns one city that 
			has the highest sum of invoice totals. Return both the city name & sum of all invoice 
			totals ?
			
*/

select billing_city, sum(total) as total_sale
from invoice
group by billing_city
order by total_sale desc
limit 1;



/*			Q.5 Who is the best customer? The customer who has spent the most money will be 
			declared the best customer. Write a query that returns the person who has spent the 
			most money

*/

select * from invoice;

select * from customer;


select customer_id, first_name, last_name
from customer
where customer_id = (
	select customer_id
	from invoice 
	group by customer_id
	order by sum(total) desc
	limit 1
);


--  #########################################################################################
-- 			QUESTION SET-2 :


/*
			Q.1 Write query to return the email, first name, last name, & Genre of all Rock Music 
			listeners. Return your list ordered alphabetically by email starting with A ?

*/

-- hint : Keep joining until desired first and last  tables get joined.

select distinct first_name, last_name, email 
from customer join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where
track_id in (
				select distinct track_id from track join genre on track.genre_id = genre.genre_id
				where genre.name like 'Rock'
			)
order by customer.email;



/*
			Q.2  Let's invite the artists who have written the most rock music in our dataset. Write a 
			query that returns the Artist name and total track count of the top 10 rock bands

*/

-- hint : Join all involved table 

select artist.artist_id, artist.name, count(artist.artist_id) as no_songs
from track join album on track.album_id = album.album_id
join artist on artist.artist_id = album.artist_id
join genre on track.genre_id = genre.genre_id
group by artist.artist_id
order by no_songs
limit 10;
	

/*
			Q.3   Return all the track names that have a song length longer than the average song length. 
			Return the Name and Milliseconds for each track. Order by the song length with the 
			longest songs listed first
	
*/


select Name, milliseconds
from track 
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;




--  #########################################################################################
-- 			QUESTION SET-3 :

/*
	 		Q.1 Find total sale collected by each artist due to total sale done of its songs.
			Return artist name and total sale due to its songs, in descening order of total sale amount.
*/


select distinct artist.name as artist_name , 
sum(invoice_line.unit_price * invoice_line.quantity) total_sell
from invoice_line join track on invoice_line.track_id = track.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
group by 1
order by  2 desc;



/*
	 		Q.2 Find how much amount spent by each customer on the artists who gave highest
			sale by their song ?
			Write a query to return customer name, artist name and total spent.
*/


WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;  --  learn !



/*
			Q.3 Write a query that determines the customer that has spent the most on music for each 
			country. Write a query that returns the country along with the top customer and how
			much they spent. For countries where the top amount spent is shared, provide all 
			customers who spent this amount
			
			
*/

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1



-- Done :)
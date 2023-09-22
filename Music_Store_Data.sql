--Q. Who is the senior most employeebased on job title ?

Select * From employee
order by levels desc

--Q. Which countries have the most Invoices?

Select 
COUNT(invoice_id),
billing_country
From invoice
group by billing_country
order by COUNT(invoice_id) desc
	
--Q. What are top 3 values of total invoice

Select top 3
*
From invoice
Order by total desc
	
--Q. Which city the best customers? We  would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of
   invoice total. Return both the city name & sum of all invoice totals

Select  
SUM(total) as Invoice_Total,
billing_city
From invoice
group by billing_city
Order by SUM(total) desc

--Q. Who is the best customer? The  customer who has spent the most money will be declared the best customer. Write a query that return the person who has spent the most money.

Select  top 1
first_name
,last_name
,sum(total) as  Total_Invoice
From customer c
join invoice I on I.customer_id = c.customer_id
group by first_name,last_name
order by sum(total) desc


--Q. Write query to return the email,first name,last name & Genre of all Rock Music listeners. Return your list ordered aplhabetically by email starting with A

Select distinct
email
,first_name
,last_name
From customer C
join invoice  I on I.customer_id = c.customer_id
join invoice_line IL on Il.invoice_id = I.invoice_id
join track T on t.track_id = IL.track_id
join genre G on G.genre_id = T.genre_id
where g.name = 'Rock'
order by email

--Q. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands

Select  top 10
Count(t.track_id)
,ar.name
From  track T
join genre G on g.genre_id = t.genre_id
join album Al on Al.album_id = T.album_id
join artist AR on Ar.artist_id =Al.artist_id
where g.name = 'Rock'
group by ar.name
order by Count(t.track_id) desc

--Q. Return all the track names that have a song length longer than the average song length. Return the name and milliseconds for each track. Order by the song length with the longest songs listed first.

Select  
name,
milliseconds
From track 
where milliseconds > (Select 
					AVG(milliseconds) as avg_track_length
					From track)
Order by milliseconds desc

--Q. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

With Best_selling_artist as (
Select Top 1
Ar.artist_id as ArtistId,ar.name as ArtistName,
sum(il.unit_price * il.quantity) as Total_Sales
From invoice_line IL
join track T on T.track_id = Il.track_id
join album Al on al.album_id = T.album_id
join artist Ar on Ar.artist_id = Al.artist_id
Group by Ar.artist_id,ar.name 
order by sum(il.unit_price * il.quantity) desc
)
Select 
C.customer_id,c.first_name,c.last_name,bs.ArtistName,
sum(il.unit_price*il.quantity) as Amount_Spent
From invoice I
join customer C on c.customer_id = I.customer_id
join invoice_line IL on il.invoice_id = I.invoice_id
join track T on T.track_id = Il.track_id
join album Al on Al.album_id =T.album_id
join Best_selling_artist BS on bs.ArtistId = Al.artist_id
group by C.customer_id,c.first_name,c.last_name,bs.ArtistName
order by sum(il.unit_price*il.quantity) desc

--Q. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns
--   each country along with the top Genre. For countries where the maximum number of purchases is shared return all genres.

With Popular_Music_Genre As (
Select
COUNT(il.invoice_line_id) as Purchases,c.country,g.name,g.genre_id,
ROW_NUMBER() over(partition by C.Country Order By COUNT(il.invoice_line_id)Desc ) As RowNo
From invoice I 
join customer C On C.customer_id = I.customer_id
join invoice_line IL On i.invoice_id =Il.invoice_id
join track T on T.track_id =Il.track_id
join genre G On g.genre_id = T.genre_id
Group By c.country,g.name,g.genre_id
)
Select * From Popular_Music_Genre where RowNo <= 1

--Q. Write a query that determines the Customer That Has Spent Most on Music For each Country. Write a query that return the Country along with the top customer and how much they spent. For 
--   Countries where the top spent is shered, provide all customers who spent this amount

With Sepnting_For_Country as(
Select
c.customer_id,first_name,last_name,billing_country,Sum(I.total) as Total_spent,
ROW_NUMBER() Over(partition by billing_country order by Sum(I.total)Desc) as RowNo
From invoice I 
join customer C On C.customer_id = I.customer_id
Group by c.customer_id,first_name, last_name,billing_country
)
Select * From Sepnting_For_Country where RowNo <= 1

--				OR
	
With 
Customer_Max_Spending As (
	Select C.customer_id,c.first_name,c.last_name,billing_country,Sum(Total) as Total_Spending
	From invoice I
	Join customer C on C.customer_id = I.customer_id
	Group by C.customer_id,c.first_name,c.last_name,billing_country
	),
Country_Max_Spending as (
	Select
	billing_country,Max(Total_Spending) as Max_Spending
	From Customer_Max_Spending
	Group By billing_country
	)
Select customer_id,first_name,last_name,Total_Spending,CS.billing_country 
From Customer_Max_Spending CS
join Country_Max_Spending CMS on CS.billing_country= CMS.billing_country
where CS.Total_Spending = CMS.Max_Spending
order by CS.billing_country

create database assessmentfinal

use assessmentfinal

CREATE TABLE artists
(
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks
(
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales
(
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists
    (artist_id, name, country, birth_year)
VALUES
    (1, 'Vincent van Gogh', 'Netherlands', 1853),
    (2, 'Pablo Picasso', 'Spain', 1881),
    (3, 'Leonardo da Vinci', 'Italy', 1452),
    (4, 'Claude Monet', 'France', 1840),
    (5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks
    (artwork_id, title, artist_id, genre, price)
VALUES
    (1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
    (2, 'Guernica', 2, 'Cubism', 2000000.00),
    (3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
    (4, 'Water Lilies', 4, 'Impressionism', 500000.00),
    (5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales
    (sale_id, artwork_id, sale_date, quantity, total_amount)
VALUES
    (1, 1, '2024-01-15', 1, 1000000.00),
    (2, 2, '2024-02-10', 1, 2000000.00),
    (3, 3, '2024-03-05', 1, 3000000.00),
    (4, 4, '2024-04-20', 2, 1000000.00);



-- Section 1: 1 mark each
-- 1.1  Write a query to display the artist names in uppercase.

select upper(name) as artist_name
from artists

-- 1.2  Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.


select top 2
    artwork_id , sum(quantity) as total_quantity  , sum(total_amount) as total_amount1
from sales
group by artwork_id
order by total_amount1 desc

-- 1.3 Write a query to find the total amount of sales for the artwork 'Mona Lisa'.


select sum(total_amount)
from sales
where sales.artwork_id = (select artwork_id
from artworks
where title = 'Mona Lisa')
;

-- 1.4 Write a query to extract the year from the sale date of 'Guernica'.

select YEAR(sale_date)
from sales
    join artworks on artworks.artwork_id = sales.artwork_id
where artworks.title = 'Guernica'
;

-- Section 2: 2 marks each
-- 2.1 Write a query to find the artworks that have the highest sale total for each genre.

select title , genre , sum(total_amount ) as total_sales
from artworks
    join sales on artworks.artwork_id = sales.artwork_id
group by genre , title


-- 2.2 Write a query to rank artists by their total sales amount and display the top 3 artists.

select artists.name , rank() over( order by total_amount desc ) as rk
from sales
    join artworks on artworks.artwork_id = sales.artwork_id
    join artists on artists.artist_id = artworks.artist_id


-- 2.3  Write a query to display artists who have artworks in multiple genres.

select *
from artworks
    join artists on artists.artist_id = artworks.artist_id


-- 2.4 Write a query to find the average price of artworks for each artist.


select artist_id , avg(price) as average_price
from artworks
group by artist_id


--2.5  Write a query to create a non-clustered index on the sales table to improve query performance
--  for queries filtering by artwork_id.

create NONCLUSTERED index myindex 
on sales (artwork_id desc )


-- 2.6 Write a query to find the artists who have sold more artworks than the 
-- average number of artworks sold per artist.



-- 2.7 Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.

    select artist_id
    from artworks
    where genre = 'Cubism'
intersect
    select artist_id
    from artworks
    where genre = 'Surrealism'
;

-- 2.8 Write a query to display artists whose birth year is earlier than the average birth 
-- year of artists from their country.

select artist_id
from artists
group by artist_id
having avg(birth_year) < (select avg(birth_year)
from artists)

-- 2.9 Write a query to find the artworks that have been sold in both January and February 2024.


    select artwork_id
    from sales
    where month(sale_date) = 1
intersect
    select artwork_id
    from sales
    where month(sale_date) = 2
;


-- 3.0  Write a query to calculate the price of 'Starry Night' plus 10% tax.


select (price + (price*0.1)) as total_price_with_tax
from artworks
where title = 'Starry Night'
;


-- 3.1  Write a query to display the artists whose average artwork price is higher 
-- than every artwork price in the 'Renaissance' genre.


select artist_id
from artworks
where avg(price) > (select avg(price) , genre
from artworks
group by genre
having genre = 'Renaissance')
;


-- Section 3: 3 Marks Questions
-- 3.1 Write a query to find artworks that have a higher price than the average price of 
-- artworks by the same artist.

SELECT a.title, a.price
FROM artworks a
WHERE a.price > (
  SELECT AVG(a2.price)
FROM artworks a2
WHERE a2.artist_id = a.artist_id
);



-- 3.2  Write a query to find the average price of artworks for each artist and only include 
-- artists whose average artwork price is higher than the overall average artwork price.

WITH
    artist_avg_price
    AS
    (
        SELECT a.name, AVG(ar.price) AS avg_price
        FROM artists a
            JOIN artworks ar ON a.artist_id = ar.artist_id
        GROUP BY a.name
    )
SELECT name, avg_price
FROM artist_avg_price
WHERE avg_price > (
  SELECT AVG(price)
FROM artworks
);


-- 3.3 Write a query to create a view that shows artists who have created artworks in multiple genres.

select *
from artists
select *
from artworks
select *
from sales 
go
create VIEW vWartistmultiplegenres
as
    select *
    from artworks
    where count(distinct artist_id ) > 1 
go

select *
from vWartistmultiplegenres 

-- Section 4: 4 Marks Questions

-- 4.1 Write a query to convert the artists and their artworks into JSON format.

-- Export Data as JSON

go
SELECT
    a.name AS [name],
    a.country AS [country],
    a.birth_year AS [birth_year],
    (
        SELECT
        b.title AS [book]
    FROM artworks b
    WHERE b.artist_id = a.artist_id
    FOR JSON PATH
    ) AS [artworks]
FROM artists a
FOR JSON PATH, ROOT('artists');
go

-- 4.2 Write a query to export the artists and their artworks into XML format.


go
    SELECT
        a.name AS [@name],
        a.country AS [@country],
        a.birth_year AS [@birth_year],
        (
        SELECT
            b.title AS [book]
        FROM artworks b
        WHERE b.artist_id= a.artist_id
        FOR XML PATH(''), TYPE
    ) AS books
    FROM artists  a
    FOR XML PATH('artworks'), ROOT('artists');
go

        -- Section 5: 5 Marks Questions

        -- 5.1 Create a trigger to log changes to the artworks table into an artworks_log table, 
        -- capturing the artwork_id, title, and a change description.

        create table artworks_log
        (
            log_id INT IDENTITY(1,1) PRIMARY KEY,
            artwork_id INT NOT NULL,
            title nvarchar(200) ,
            insert_date DATETIME NOT NULL
        );

go

        create trigger LogSalesDelete
on  artworks 
after insert 
as
BEGIN
            insert into artworks_log
                ( artwork_id, title , insert_date)
            SELECT inserted.artwork_id , inserted.title, GETDATE()
            FROM inserted
        END 

insert into artworks
        values
            (6 , 'Myone' , 5 , 'newone' , 200)

select *
        from artworks_log



-- 5.2 Create a scalar function to calculate the average sales amount for artworks in a 
-- given genre and write a query to use this function for 'Impressionism'.

go

        create function impresssion (@genre nvarchar(200))
returns decimal(10, 2)
as 
begin
            declare @total_amount decimal(10,2)
            ;
            select @total_amount = avg(total_amount)
            from sales
                join artworks on artworks.artwork_id = sales.artwork_id
            where genre = @genre
            ;
            return @total_amount
        end 
go

        select dbo.impression('Cubism')
        from sales ; 

-- 5.3 Create a stored procedure to add a new sale and update the total sales for the artwork. 
-- Ensure the quantity is positive, and use transactions to maintain data integrity.

-- 5.4  Create a multi-statement table-valued function (MTVF) to return the total quantity sold for 
-- each genre and use it in a query to display the results.


go

        create function  GetTotalQuantitySoldByGenre()
returns  @genre_quantities TABLE (
            genre VARCHAR(50),
            total_quantity INT
)
AS
BEGIN
            INSERT INTO @genre_quantities
            SELECT s.genre, SUM(b.quantity) AS total_quantity
            FROM sales b
                JOIN artworks s ON b.artwork_id = s.artwork_id
            GROUP BY s.genre;
            RETURN;
        END
go


select * from dbo.GetTotalQuantitySoldByGenre()

-- 5.4 Write a query to create an NTILE distribution of artists based on their total sales, divided 
-- into 4 tiles.

SELECT
    a.artist_name,
    SUM(s.total_sales) AS total_sales,
    NTILE(4) OVER (
        ORDER BY SUM(s.total_sales) DESC
    ) AS sales_tile
FROM
    artists a
    JOIN sales s ON a.artist_id = s.artist_id
GROUP BY
    a.artist_name
ORDER BY
    total_sales DESC;





-- ### Normalization (5 Marks)

-- 26. **Question:**
--  Given the denormalized table `ecommerce_data` with sample data:

| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.

### ER Diagram (5 Marks)

27. Using the normalized tables from Question 26, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.


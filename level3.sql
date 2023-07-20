use sakila;

-- cùng một customer và cùng một ngày thì xác định là một giao dịch.
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- 1.Viết truy vấn SQL để trả về thời lượng thuê trung bình cho từng tổ hợp diễn viên và danh mục trong cơ sở dữ liệu,
--  ngoại trừ các diễn viên chưa xuất hiện trong bất kỳ phim nào trong danh mục
select concat(a.first_name,' ',a.last_name) as actor_name, c.name as category_name,
		avg(timestampdiff(hour, r.rental_date, r.return_date)) as avg_rental_duration
from actor a join film_actor fa on a.actor_id = fa.actor_id
			join film_category fc on fa.film_id = fc.film_id
            join category c on fc.category_id = c.category_id
            join inventory i on fc.film_id = i.film_id
            join rental r on i.inventory_id = r.inventory_id
group by actor_name, category_name
having count(distinct fc.film_id) > 0;

-- ---------------------------------------------------------------------------------------------------------------------------------------
-- 2.Viết truy vấn SQL để trả về tên của tất cả các diễn viên đã xuất hiện trong một bộ phim có xếp hạng 'R' 
-- và thời lượng hơn 2 giờ, nhưng chưa bao giờ xuất hiện trong một bộ phim có xếp hạng 'G'.
select a.actor_id, concat(a.first_name,' ', a.last_name) as actor_name
from actor a join film_actor fa on a.actor_id = fa.actor_id
			join film f on f.film_id = fa.film_id
where f.rating = 'R' and a.actor_id not in (
											select a.actor_id
											from actor a join film_actor fa on a.actor_id = fa.actor_id
														 join film f on fa.film_id = f.film_id
											where f.rating = 'G'
											group by a.actor_id)
group by actor_id;
-- ----------------------------------------------------------------------------------------------------------------------------------------
-- ????????????????????????????????????????????????????????????????????
-- 3.Viết truy vấn SQL để trả về tên của tất cả khách hàng đã thuê hơn 10 bộ phim trong một giao dịch,
-- cùng với số lượng phim họ đã thuê và tổng phí thuê.
select c.customer_id,
		concat(c.first_name,' ',c.last_name) as customer_name,
        count(distinct r.inventory_id) as inventor_count,
        sum(p.amount) as total_rental_fee
from customer c join rental r on c.customer_id = r.customer_id
				join payment p on r.rental_id = p.rental_id
GROUP BY c.customer_id, date(r.rental_date)
having count(r.inventory_id) > 5;

SELECT customer_id, DATE(rental_date) AS transaction_date, COUNT(rental_id) AS number_of_rentals
FROM rental
GROUP BY customer_id, DATE(rental_date)
HAVING COUNT(rental_id) = 10;

SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(DISTINCT r.rental_id) AS number_of_transactions,
       COUNT(r.inventory_id) AS number_of_rentals,
       SUM(p.amount) AS total_rental_fee
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id, customer_name
HAVING COUNT(DISTINCT r.rental_id) > 10 AND COUNT(r.inventory_id) > 10;

-- ----------------------------------------------------------------------------------------------------------------------------------------
-- ????????????????????????????
-- 4.Viết một truy vấn SQL để trả về tên của tất cả các khách hàng đã thuê mọi bộ phim trong một danh mục,
-- cùng với tổng số phim đã thuê và tổng phí thuê
select category_id , count(film_id) from film_category group by category_id;
select c.customer_id, concat(c.first_name,' ',c.last_name) as customer_name,
		count( distinct i.inventory_id) as rented_film,
        sum(p.amount) as total_amount,
        fc.films
from customer c join rental r on c.customer_id = r.customer_id
				join inventory i on r.inventory_id = i.inventory_id
                join payment p on r.rental_id = p.rental_id
                join (select category_id , count(film_id) as films from film_category group by category_id) fc on rented_film = fc.films
group by customer_id;

SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(DISTINCT r.inventory_id) AS total_rentals,
       SUM(p.amount) AS total_payment
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN payment p ON r.rental_id = p.rental_id
WHERE fc.category_id = (SELECT category_id FROM category WHERE name = 'Action')
GROUP BY c.customer_id, customer_name
HAVING COUNT(DISTINCT r.inventory_id) = (SELECT COUNT(*) FROM film_category WHERE category_id = (SELECT category_id FROM category WHERE name = 'Action'));

-- ------------------------------------------------------------------------------------------------------------------------------------------
-- 5.Viết truy vấn SQL để trả về tiêu đề của tất cả các phim trong cơ sở dữ liệu đã được cùng một khách hàng thuê nhiều lần trong một ngày,
--  cùng với tên của những khách hàng đã thuê phim và số lần họ được thuê.
select date(rental_date) from rental;
select f.film_id, f.title ,
		concat(c.first_name,' ',c.last_name) as customer_name,
        count(*) as rental_count
from film f join inventory i on f.film_id = i.film_id
			join rental r on i.inventory_id = r.inventory_id
            join customer c on r.customer_id = c.customer_id
where date(r.rental_date)  = '2005-05-25'
group by f.film_id, c.customer_id
having count(*)>1;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6.Viết truy vấn SQL để trả về tên của tất cả các diễn viên đã xuất hiện trong ít nhất một bộ phim 
-- cùng với mọi diễn viên khác trong cơ sở dữ liệu, cùng với số lượng phim họ đã xuất hiện cùng nhau.
select concat(a1.first_name,' ',a1.last_name) as actor1_name,
	   concat(a2.first_name,' ',a2.last_name) as actor2_name,
       count(distinct fa1.film_id) as number_films
from actor a1 join film_actor fa1 on a1.actor_id = fa1.actor_id
			  join film_actor fa2 on fa1.film_id = fa2.film_id and fa1.actor_id <> fa2.actor_id
              join actor a2 on fa2.actor_id = a2.actor_id
group by actor1_name, actor2_name;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 7.Viết truy vấn SQL để trả về tên của tất cả khách hàng đã thuê ít nhất một phim từ mỗi danh mục trong cơ sở dữ liệu,
-- cùng với số lượng phim đã thuê từ mỗi danh mục.
select c.customer_id, concat(c.first_name,' ',c.last_name) as customer_name,
		count(distinct i.film_id) as number_films
from customer c join rental r on c.customer_id = r.customer_id
				join inventory i on r.inventory_id = i.inventory_id
                join film_category fc on i.film_id = fc.film_id
group by c.customer_id
having count(distinct fc.category_id) = (select count(*) from category);

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 8. Viết truy vấn SQL để trả về tiêu đề của tất cả các phim trong cơ sở dữ liệu đã được thuê hơn 100 lần,
--  nhưng chưa bao giờ được thuê bởi bất kỳ khách hàng nào đã thuê phim có xếp hạng 'G'.
select f.film_id, f.title , count( rental_id) as number_rentals
from film f join inventory i on f.film_id = i.film_id 
			join rental r on i.inventory_id = r.inventory_id
where r.customer_id not in (
							-- id các khách hàng đã thuê phim có xếp hạng G
							select distinct customer_id 
							from rental r join inventory i on r.inventory_id = i.inventory_id
										  join film f on i.film_id = f.film_id
							where rating = 'G')
group by f.film_id
having number_rentals > 100;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 9.Viết truy vấn SQL để trả về tên của tất cả các khách hàng đã thuê phim từ danh mục mà họ chưa bao giờ thuê trước đây 
-- và cũng chưa bao giờ thuê phim dài hơn 3 giờ.
select c.customer_id, concat(c.first_name,' ',c.last_name) as customer_name
from customer c join rental r on c.customer_id = r.customer_id 
				join inventory i on r.inventory_id = i.inventory_id
                join film_category fc on i.film_id = fc.film_id
where NOT EXISTS (
				select 1 from rental r2 join inventory i2 on r2.inventory_id = i2.inventory_id
										join film_category fc2 on i2.film_id = fc2.film_id
				where r2.customer_id = c.customer_id and fc2.category_id = fc.category_id and r2.rental_date < r.rental_date
                )
and c.customer_id in  (
				-- khách hàng thuê phim dài hơn 3 giờ
				select c.customer_id
				from customer c join rental r on c.customer_id = r.customer_id
								join inventory i on r.inventory_id = i.inventory_id
								join film f on i.film_id = f.film_id
				where f.length <= 180
				group by c.customer_id
				order by c.customer_id)
group by c.customer_id;

SELECT DISTINCT c.first_name, c.last_name
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category cat ON fc.category_id = cat.category_id
AND NOT EXISTS (
    SELECT 1
    FROM rental r2
    JOIN inventory i2 ON r2.inventory_id = i2.inventory_id
    JOIN film_category fc2 ON i2.film_id = fc2.film_id
    WHERE r2.customer_id = c.customer_id
    AND fc2.category_id = cat.category_id
    AND r2.rental_date < r.rental_date
);

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 10.Viết truy vấn SQL để trả về tên của tất cả các diễn viên đã xuất hiện trong một bộ phim có xếp hạng 'PG-13' và thời lượng hơn 2 giờ,
-- đồng thời cũng đã xuất hiện trong một bộ phim có xếp hạng 'R' và thời lượng dưới 90 phút
select a.actor_id, concat(a.first_name,' ',a.last_name) as actor_name
from actor a join film_actor fa on a.actor_id = fa.actor_id
			join film f on fa.film_id = f.film_id
where f.rating = 'PG-13' AND f.length > 120
						AND a.actor_id in ( select a.actor_id 
											from actor a join film_actor fa on a.actor_id = fa.actor_id
														join film f on fa.film_id = f.film_id
											where rating = 'R' and f.length <90
											)
group by a.actor_id;


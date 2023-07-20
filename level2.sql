use sakila;

-- 1.Viết truy vấn SQL để trả về 10 khách hàng hàng đầu đã tạo ra nhiều doanh thu nhất cho cửa hàng,
--  bao gồm tên của họ và tổng doanh thu được tạo ra.
select * from customer;
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, SUM(p.amount) AS total_revenue
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_revenue DESC
LIMIT 10;
-- -----------------------------------------------------------------
/*
With customer_total_revenue as(
	SELECT  c.store_id, c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, SUM(p.amount) AS total_revenue
	FROM customer c
		JOIN payment p ON c.customer_id = p.customer_id
	GROUP BY c.customer_id, customer_name
)
select customer_id, customer_name,
		NTILE(10) OVER(PARTITION BY store_id ORDER BY total_revenue desc limit 10)
 from customer_total_revenue;
*/
(
  SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		SUM(p.amount) AS total_revenue, c.store_id
  FROM customer c
  JOIN payment p ON c.customer_id = p.customer_id
  WHERE c.store_id = 1
  GROUP BY c.customer_id, customer_name, c.store_id
  ORDER BY total_revenue DESC
  LIMIT 10
)
UNION
(
  SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		SUM(p.amount) AS total_revenue, c.store_id
  FROM customer c
  JOIN payment p ON c.customer_id = p.customer_id
  WHERE c.store_id = 2
  GROUP BY c.customer_id, customer_name, c.store_id
  ORDER BY total_revenue DESC
  LIMIT 10
);
-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.Viết truy vấn SQL để trả về tên và thông tin liên hệ của tất cả khách hàng 
-- đã thuê phim ở tất cả các danh mục trong cơ sở dữ liệu.
select * from customer;
select * from rental;
select * from inventory;
-- nếu không tồn tại bất kỳ danh mục nào mà khách hàng chưa thuê phim, thì khách hàng sẽ được chọn và trả về
SELECT c.customer_id, concat(first_name,', ',last_name) as customer_name, c.email
FROM customer c
WHERE NOT exists(
	-- trả về các category không ở trông truy vấn con
	select * from category 
    where category_id NOT IN (
		-- trả về các category mà khách hàng đã thuê từ bảng rental
		SELECT distinct fa.category_id
        FROM rental r JOIN inventory i on r.inventory_id = i.inventory_id
						JOIN film_category fa on i.film_id = fa.film_id
                        where r.customer_id = c.customer_id -- đảm bảo rằng chỉ có dữ liệu liên quan đến khách hàng cụ thể được lấy
    )
);
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3.Viết truy vấn SQL để trả về tiêu đề của tất cả các phim trong cơ sở dữ liệu
-- đã được thuê ít nhất một lần nhưng không bao giờ trả lại.
select * from rental where return_date is null;
select title 
from film 
where film_id IN (
					Select i.film_id 
					from rental r join inventory i on r.inventory_id = i.inventory_id
                    where return_date is null
					);
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.Viết truy vấn SQL để trả về tên của tất cả các diễn viên đã xuất hiện trong ít nhất một bộ phim trong mỗi danh mục trong cơ sở dữ liệu
-- tức là các diễn viên tham gia đầy đủ 16 danh mục
select count(*) from category;
select a.actor_id, concat(a.first_name,' ', a.last_name) as actor_name
from actor a join (	select fa.actor_id, count(distinct fc.category_id) as category_count
					from film_actor fa join film_category fc on fa.film_id = fc.film_id
					group by fa.actor_id) b on a.actor_id = b.actor_id
where b.category_count = (select count(distinct category_id) from category); 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ????????????????????????????
-- 5.Viết một truy vấn SQL để trả về tên của tất cả các khách hàng 
-- đã thuê cùng một bộ phim nhiều lần trong một giao dịch, cùng với số lần họ đã thuê bộ phim đó.
-- tức là tìm khách hàng đã thuê cùng một bộ phim nhiều hơn 1 lần trong một giao dịch duy nhất 
select * from inventory join rental using(inventory_id);
-- trả vể danh sách khách hàng đã thuê nhiều hơn một bộ phim trong một lần duy nhất
SELECT c.customer_id, c.first_name, c.last_name, COUNT(*) as rental_count
FROM customer c
	JOIN rental r1 ON c.customer_id = r1.customer_id
	JOIN rental r2 ON r1.customer_id = r2.customer_id AND r1.rental_id <> r2.rental_id AND r1.rental_date = r2.rental_date
	JOIN inventory i ON r1.inventory_id = i.inventory_id
GROUP BY c.customer_id
HAVING rental_count > 1;
-- trả về khách hàng đã thuê cùng một bộ phim nhiều hơn 1 lần trong một giao dịch duy nhất
SELECT c.customer_id,
		concat(c.first_name,' ', c.last_name) as customer_name,
        count(*) as rental_count
FROM customer c
	JOIN rental r1 on c.customer_id = r1.customer_id
    JOIN rental r2 on r1.rental_id = r2.rental_id and r1.inventory_id <> r2.inventory_id
    JOIN inventory i1 ON r1.inventory_id = i1.inventory_id
    JOIN inventory i2 ON r2.inventory_id = i2.inventory_id
WHERE i1.film_id = i2.film_id
GROUP BY c.customer_id
HAVING rental_count > 1;

SELECT c.customer_id,
		concat(c.first_name,' ', c.last_name) as customer_name,
        count(*) as rental_count
FROM customer c
	JOIN rental r1 on c.customer_id = r1.customer_id
    JOIN rental r2 on r1.rental_date = r2.rental_date and r1.inventory_id <> r2.inventory_id
    JOIN inventory i1 ON r1.inventory_id = i1.inventory_id
    JOIN inventory i2 ON r2.inventory_id = i2.inventory_id
WHERE i1.film_id = i2.film_id
GROUP BY c.customer_id
HAVING rental_count > 1;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6.Viết truy vấn SQL để trả về tổng doanh thu do mỗi diễn viên tạo ra trong cơ sở dữ liệu, dựa trên phí thuê phim mà họ đã xuất hiện.
select a.actor_id, concat(a.fist_name,' ', a.last_name) as actor_fullname, sum(p.amount) as actor_amount
from actor a join film_actor fa on a.actor_id = fa.actor_id
			join inventory i on fa.film_id = i.film_id
            join rental r on i.inventory_id = r.inventory_id
            join payment p on r.rental_id = p.rental_id
group by a.actor_id;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 7.Viết một truy vấn SQL để trả về tên của tất cả các diễn viên đã xuất hiện trong ít nhất một bộ phim có xếp hạng 'R',
-- nhưng chưa bao giờ xuất hiện trong một bộ phim có xếp hạng 'G'.
select * from film;
select a.actor_id, concat(a.first_name,' ',a.last_name) as actor_name, f.rating as film_rating
from actor a join film_actor fa on a.actor_id = fa.actor_id
			 join film f on fa.film_id = f.film_id
where f.rating = 'R' and a.actor_id not in (select fa.actor_id 
											from film f join film_actor fa on f.film_id = fa.film_id
											where f.rating = 'G'
											group by actor_id)
group by a.actor_id;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 8.Viết truy vấn SQL để trả về tiêu đề của tất cả các phim trong cơ sở dữ liệu đã được thuê bởi hơn 50 khách hàng,
-- nhưng chưa bao giờ được thuê bởi cùng một khách hàng nhiều lần.
select f.film_id, f.title, count(distinct r.customer_id) as customer_rentals
from film f join inventory i on f.film_id = i.film_id
			join rental r on i.inventory_id = r.inventory_id
group by f.film_id
having customer_rentals > 50;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 9.Viết truy vấn SQL để trả về tên của tất cả các khách hàng đã thuê phim từ danh mục mà họ chưa từng thuê trước đó.
select c.customer_id, concat(c.first_name,' ', c.last_name) as customer_name
from customer c join rental r on c.customer_id = r.customer_id
				join inventory i on r.inventory_id = i.inventory_id
                join film_category fc on i.film_id = fc.film_id
                left join ( select r.customer_id, fa.category_id 
							from rental r join inventory i on r.inventory_id = i.inventory_id
							join film_category fa on i.film_id = fa.film_id
							group by customer_id, fa.category_id) as ra
                            on c.customer_id = ra.customer_id and fc.category_id = ra.category_id
where ra.customer_id is null;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 10.Viết truy vấn SQL để trả về tiêu đề của tất cả các phim trong cơ sở dữ liệu đã được thuê bởi mọi khách hàng
--  đã từng thuê phim từ danh mục 'Action'.
select film_id , title 
from film f
where not exists (
					select * from customer
					where customer_id not in (
												select customer_id 
												from rental r join inventory i on r.inventory_id = i.inventory_id
															join film_category fc on i.film_id = fc.film_id
															join category c on fc.category_id = c.category_id
															where c.name = 'Action' and f.film_id = fc.film_id
															group by customer_id)
				  );
-- --------------------------------
SELECT film.title
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN rental ON film.film_id = rental.inventory_id
WHERE film_category.category_id = (
    SELECT category_id
    FROM category
    WHERE name = 'Action'
)
GROUP BY film.film_id, film.title
HAVING COUNT(DISTINCT rental.customer_id) = (
    SELECT COUNT(DISTINCT customer_id)
    FROM rental
);

		






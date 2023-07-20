use sakila;
desc actor;
-- 1.Viết một truy vấn SQL để trả về họ và tên của tất cả các diễn viên trong cơ sở dữ liệu
SELECT concat(first_name,' ',last_name) as full_name
FROM actor;

-- 2.Viết một truy vấn SQL để trả về tiêu đề của tất cả các bộ phim trong cơ sở dữ liệu,
-- cùng với giá thuê và chi phí thay thế của chúng.
desc film;
SELECT title, rental_rate, replacement_cost
FROM film;

-- 3.Viết truy vấn SQL để trả về 5 bộ phim được thuê nhiều nhất trong cơ sở dữ liệu,
-- cùng với số lần chúng được thuê.
SELECT f.title, count(rental_id) as rentals 
FROM film f JOIN inventory i on f.film_id = i.film_id
			JOIN rental r on i.inventory_id = r.inventory_id
GROUP BY title
ORDER BY rentals DESC
LIMIT 5;

-- 4.Viết truy vấn SQL để trả về thời lượng thuê trung bình cho từng danh mục phim trong cơ sở dữ liệu.
SELECT * FROM rental;
SELECT c.category_id, c.name as name_category,
		AVG(TIMESTAMPDIFF(hour, r.rental_date, r.return_date)) AS average_rental_duration
FROM category c LEFT JOIN film_category fc ON c.category_id = fc.category_id
				LEFT JOIN film f ON fc.film_id = f.film_id
                LEFT JOIN inventory i ON f.film_id = i.film_id
                LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY c.category_id;

-- 5.Viết truy vấn SQL để trả về tên và địa chỉ của tất cả khách hàng đã thuê phim trong tháng 1 năm 2022.
SELECT* FROM address;
select * from rental where year(rental_date) = 2005 AND month(rental_date) = 7 order by customer_id;
SELECT
		c.customer_id as customer_id,
		concat(c.first_name,' ',c.last_name) as customer_fullname,
		concat(a.address,', ',a.district,', ',ci.city) as address
FROM rental r   JOIN customer c ON c.customer_id = r.customer_id
				JOIN address a ON c.address_id = a.address_id
				JOIN city ci ON a.city_id = ci.city_id
WHERE year(r.rental_date) = 2005 AND month(r.rental_date) = 7
Group by customer_id, customer_fullname;

-- -------------------------------------
SELECT c.customer_id,
		concat(c.first_name,' ',c.last_name) as customer_fullname,
		concat(a.address,', ',a.district,', ',ci.city) as address
FROM customer c 
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN rental r ON c.customer_id = r.customer_id AND 
                    year(r.rental_date) = 2022 AND month(r.rental_date) = 1
ORDER BY c.customer_id;
-- 6.Viết truy vấn SQL để trả về doanh thu do mỗi cửa hàng tạo ra trong cơ sở dữ liệu cho năm 2021.
select * from payment;
select * from staff;
select * from store;
select st.store_id,
		concat(a.address,', ',a.district,', ',c.city) as store_address,
        sum(p.amount) as amount_2005
from payment p join staff sf on p.staff_id = sf.staff_id
				join store st on  sf.store_id = st.store_id
                join address a on st.address_id = a.address_id
                join city c on a.city_id = c.city_id
where year(payment_date) = 2005
group by st.store_id;

-- 7.Viết truy vấn SQL để trả về tên của tất cả các diễn viên đã xuất hiện trong hơn 20 bộ phim trong cơ sở dữ liệu.
select * from film_actor;
select a.actor_id,
		concat(a.first_name,' ',a.last_name) as actor_name,
        count(film_id) as films
from actor a join film_actor fa on a.actor_id = fa.actor_id
Group by a.actor_id
Having films > 20;

-- 8.Viết truy vấn SQL để trả về tiêu đề của tất cả các phim trong cơ sở dữ liệu có xếp hạng 'PG-13' và thời lượng hơn 120 phút.
select title, length, rating
from film where rating = 'PG-13'and length > 120;




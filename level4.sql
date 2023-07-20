use sakila;

-- ------------------------------------------------------------------------------------------------------------------------------------------
-- 1.Viết truy vấn SQL để cập nhật giá thuê của tất cả các phim trong cơ sở dữ liệu đã được thuê hơn 100 lần,
-- đặt giá thuê mới cao hơn 10% so với giá hiện tại.
update film
set rental_rate = rental_rate * 110 /100
where film_id in (
					select f.film_id 
                    from film f join inventory i on f.film_id = i.film_id
								join rental r on i.inventory_id = r.inventory_id
					group by f.film_id
                    having count(distinct r.rental_id) > 100
					); -- MySQL không cho phép thực hiện câu lệnh UPDATE trên một bange mà đã sử dụng trong câu lệnh con để lấy dữ liệu

UPDATE film AS f
JOIN (
    SELECT f.film_id 
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY f.film_id
    HAVING COUNT(DISTINCT r.rental_id) > 100
) AS subquery ON f.film_id = subquery.film_id
SET f.rental_rate = f.rental_rate * 110 / 100;

-- ------------
CREATE TEMPORARY TABLE temp_films AS
SELECT f.film_id
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
HAVING COUNT(DISTINCT r.rental_id) > 100;

UPDATE film
SET rental_rate = rental_rate * 1.1
WHERE film_id IN (SELECT film_id FROM temp_films)
		AND film_id = film_id;

DROP TEMPORARY TABLE temp_films;
-- ----------- sử dụng bảng tạm thời thay vì truy vấn con
                    
-- ---------------------------------------------------------------------------------------------------------------------------------
-- 2.Viết truy vấn SQL để cập nhật thời lượng thuê của tất cả các phim trong cơ sở dữ liệu đã được thuê hơn 5 lần,
-- đặt thời lượng mới dài hơn 5% so với thời lượng hiện tại.
update film f join (
					select f.film_id
                    from film f join inventory i on f.film_id = i.film_id 
								join rental r on i.inventory_id = r.inventory_id
					group by f.film_id
					having count(r.rental_id) > 5) sub on f.film_id = sub.film_id
set f.length = f.length * 1.05;
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- 3.Viết truy vấn SQL để cập nhật giá thuê của tất cả các phim trong danh mục 'Action' được phát hành trước năm 2005,
-- đặt giá mới cao hơn 20% so với giá hiện tại.
update film f join(
					select f.film_id 
					from film f join film_category fc on f.film_id =  fc.film_id
								join category c on fc.category_id = c.category_id
					where c.name = 'Action' and f.release_year < 2005) sub on f.film_id = sub.film_id
set f.rental_rate = f.rental_rate * 1.2;
-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 4.Viết truy vấn SQL để cập nhật địa chỉ email của tất cả khách hàng đã thuê phim từ danh mục 'Horror' vào tháng 10 năm 2022,
-- đặt địa chỉ email mới là sự kết hợp giữa địa chỉ email hiện tại của họ và chuỗi 'Horror' .

update customer c join (
						-- id khách hàng thuê phim từ danh mục Horror vào tháng 10 năm 2022
						select c.customer_id
						from customer c join rental r on c.customer_id = r.customer_id
										join inventory i on r.inventory_id = i.inventory_id
										join film_category fc on i.film_id = fc.film_id
										join category ca on fc.category_id = ca.category_id
						where ca.name = 'Horror' and month(r.rental_date) = 10 and year(r.rental_date) = 2022 ) as sub
                        on c.customer_id = sub.customer_id
set c.email = concat(c.email, ' ', 'Horror');
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 5.Viết truy vấn SQL để cập nhật giá thuê của tất cả các phim trong cơ sở dữ liệu đã được hơn 10 khách hàng thuê,
-- đặt giá mới cao hơn 5% so với giá hiện tại, nhưng không cao hơn $4,00.
update film f join (
						-- id film được hơn 10 khách hàng thuê
						select f.film_id
						from film f join inventory i on f.film_id = i.film_id 
									join rental r on i.inventory_id = r.inventory_id
						group by f.film_id
						having count(distinct r.customer_id) > 10 ) sub
                        on f.film_id = sub.film_id
set f.rental_rate = case
						when f.rental_rate * 1.05 <= 4.00 then f.rental_rate * 1.05
                        else 4.00
					end;

-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- 6.Viết truy vấn SQL để cập nhật giá thuê của tất cả các phim trong cơ sở dữ liệu có xếp hạng 'PG-13'
-- và thời lượng hơn 2 giờ, đặt giá mới là $3,5.
update film f join(
					select film_id from film where rating = 'PG-13' and length > 120
                    ) sub on f.film_id = sub.film_id
set rental_rate = 3.50;
-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- 7.Viết truy vấn SQL để cập nhật thời lượng cho thuê của tất cả các phim trong danh mục 'Sci-Fi' 
-- được phát hành vào năm 2010, đặt thời lượng mới bằng với thời lượng của phim tính bằng phút.
UPDATE film f join (
					select f.film_id
                    from film f join film_category fc on f.film_id = fc.film_id
								join category c on fc.category_id = c.category_id
					where c.name = 'Sci-Fi' and f.release_year = 2010 ) sub
                    on f.film_id = sub.film_id
SET rental_duration = length;

-- -------------------------------------------------------------------------------------------------------------------------------------------------
-- 8.Viết truy vấn SQL để cập nhật địa chỉ của tất cả các khách hàng sống trong cùng thành phố với một khách hàng khác có cùng họ,
-- đặt địa chỉ mới là phần nối của địa chỉ hiện tại của họ và chuỗi 'samecity'.
update customer c1 join customer c2 on c1.last_name =c2.last_name and c1.customer_id <> c2.customer_id
				   join address ad1 on c1.address_id = ad1.address_id
                   join address ad2 on c2.address_id = ad2.address_id
set ad1.address = concat(ad1.address, 'samecity')
where ad1.city_id = ad2.city_id;

-- ?
UPDATE customer c
JOIN address ad  ON ad.address_id = c.address_id
JOIN city ci ON ci.city_id = ad.city_id
JOIN country co ON co.country_id = ci.country_id
SET ad.address = CONCAT(ad.address, 'samecity')
WHERE c.last_name = c.last_name and ci.city = ci.city;
 -- ?
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- 9.Viết truy vấn SQL để cập nhật giá thuê của tất cả các phim trong danh mục 'Comedy' được phát hành vào năm 2007 trở đi,
-- đặt giá mới thấp hơn 15% so với giá hiện tại
update film f join (
					select f.film_id 
                    from film f join film_category fc on f.film_id = fc.film_id
								join category c on fc.category_id = c.category_id
					where c.name = 'Comedy' and f.release_year >= 2007
					) sub on f.film_id = sub.film_id
set rental_rate = rental_rate * 0.85;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- 10.Viết truy vấn SQL để cập nhật giá thuê của tất cả các phim trong cơ sở dữ liệu có xếp hạng 'G' và thời lượng dưới 1 giờ,
-- đặt giá mới là $1,50.
update film f join (
					select film_id from film where rating = 'G' and length < 60
					) sub on f.film_id = sub.film_id
set rental_rate = 1.50;

-- ?????????-------------------------------------------------------------------------------------------------------------------------------------------------------
-- 11.Viết truy vấn SQL để cập nhật mức lương của tất cả nhân viên trong cơ sở dữ liệu
-- dựa trên chức danh công việc và số năm kinh nghiệm của họ,
-- đặt mức lương mới bằng với mức lương hiện tại nhân với hệ số phụ thuộc vào chức danh công việc và số năm kinh nghiệm của họ


-- ??????????------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 12.Viết truy vấn SQL để cập nhật số lượng của tất cả các sản phẩm trong cơ sở dữ liệu dựa trên số lượng hiện tại của chúng 
-- và số lượng đơn đặt hàng đã được đặt cho sản phẩm đó, đặt số lượng mới bằng số lượng hiện tại trừ đi số lượng đơn đặt hàng đã đặt được đặt cho sản phẩm đó.




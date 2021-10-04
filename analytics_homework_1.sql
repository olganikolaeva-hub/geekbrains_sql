/* Урок 1. Аналитика в бизнес-задачах */
-- 1. Проанализировать, какой период данных выгружен
SELECT min(order_date),
       max(order_date)
FROM orders;

-- 2. Посчитать кол-во строк, кол-во заказов и кол-во уникальных пользователей, кот совершали заказы.
SELECT count(*) as cnt_strings,
       count(distinct id_order) as cnt_orders,
       count(distinct id_user) as cnt_users
FROM orders;

-- 3. По годам и месяцам посчитать средний чек, среднее кол-во заказов на пользователя, сделать вывод ,
--    как изменялись это показатели Год от года.
SELECT  DATE_FORMAT(order_date, '%Y-%m') as month_year,
		ROUND(AVG(price)) as avg_price,
        COUNT(id_order)/COUNT(DISTINCT id_user) as orders_per_user
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m');

-- 4. Найти кол-во пользователей, которые покупали в одном году и перестали покупать в следующем
SELECT COUNT(DISTINCT orders.id_user)
FROM orders
LEFT JOIN (SELECT DISTINCT id_user, DATE_FORMAT(order_date, '%Y') as order_year FROM orders WHERE DATE_FORMAT(order_date, '%Y') = '2017') as orders_2017
on orders_2017.id_user = orders.id_user
WHERE DATE_FORMAT(orders.order_date, '%Y') = '2016' and
      orders_2017.id_user is null;

-- 5. Найти ID самого активного по кол-ву покупок пользователя
SELECT id_user,
       COUNT(id_order)
FROM orders
GROUP BY id_user
ORDER BY COUNT(id_order) desc
LIMIT 1;

-- 6. Найти коэффициенты сезонности по месяцам
CREATE TABLE order_per_year as
SELECT DATE_FORMAT(order_date, '%Y') as order_year,
        DATE_FORMAT(order_date, '%Y-%m') as month_year,
        count(id_order) as orders_per_year
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y'),
DATE_FORMAT(order_date, '%Y-%m');
commit;

SELECT  DATE_FORMAT(order_date, '%Y-%m') as month_year,
        DATE_FORMAT(order_date, '%Y') as order_year,
        count(id_order)/order_per_year.mean_orders
FROM orders
INNER JOIN (SELECT order_year, AVG(orders_per_year) as mean_orders FROM order_per_year GROUP BY order_year) as order_per_year ON order_per_year.order_year = DATE_FORMAT(orders.order_date, '%Y')
 GROUP BY  DATE_FORMAT(order_date, '%Y-%m'),
        DATE_FORMAT(order_date, '%Y');         
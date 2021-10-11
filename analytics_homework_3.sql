/* Урок 3. Типовые методы анализа данных */
-- 1.  Группа часто покупающих (3 и более покупок) и которые последний раз покупали не так давно. Считаем сколько
--  денег оформленного заказа приходится на 1 день. Умножаем на 30.
CREATE TABLE freq_users as
SELECT distinct id_user, count(id_order), max(order_date)
FROM orders
GROUP BY id_user
HAVING count(id_order) > 3 and
max(DATE_FORMAT(order_date, '%Y-%m-%d')) >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY
ORDER BY count(id_order) desc;
COMMIT;

SELECT AVG(t.price_for_day_for_freq)*30
FROM 
(SELECT distinct order_date, sum(price) as price_for_day_for_freq
FROM freq_users 
INNER JOIN orders on orders.id_user = freq_users.id_user
GROUP BY order_date) t;

-- 2.  Группа часто покупающих, но которые не покупали уже значительное время. Так же можем сделать вывод, из
-- такой группы за след месяц сколько купят и на какую сумму. (постараться продумать логику)

CREATE TABLE freq_users_stop_buying as
SELECT distinct id_user, count(id_order), max(order_date)
FROM orders
GROUP BY id_user
HAVING count(id_order) > 3 and
max(DATE_FORMAT(order_date, '%Y-%m-%d')) < DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY
ORDER BY count(id_order) desc;
COMMIT;

-- 3.  Отдельно разобрать пользователей с 1 и 2 покупками за все время, прогнозируем их.
CREATE TABLE rarely_users as
SELECT distinct id_user, count(id_order), max(order_date)
FROM orders
GROUP BY id_user
HAVING count(id_order) <= 2
ORDER BY count(id_order) desc;
COMMIT;





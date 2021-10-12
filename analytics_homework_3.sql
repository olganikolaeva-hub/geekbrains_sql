/* Урок 3. Типовые методы анализа данных */
-- Делаем прогноз ТО на 05.2017. В качестве метода прогноза - считаем сколько денег тратят группы часто покупающих и редко покупающих юзеров в день.


-- Прогноз для юзеров, которые останутся в активной базе и будут продолжать совершать покупки 
-- на 05.2017 составляет '77 316 567'

-- 1.1 создадим таблицу юзеров, которые за 4 месяца в период [max(order_date)-240, max(order_date)-120] 
-- оформили 3 и больше заказов.
CREATE TABLE freq_users_base as
SELECT distinct id_user, count(id_order)
FROM orders
WHERE DATE_FORMAT(order_date, '%Y-%m-%d') >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120*2 DAY and 
      DATE_FORMAT(order_date, '%Y-%m-%d') <= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY 
GROUP BY id_user
HAVING count(id_order) >= 3;
commit;

-- 1.2 таких юзеров в базе 21 977 
SELECT count(*) FROM freq_users_base;

-- 1.3 посчитаем, сколько из них продолжили покупать в последующие 120 дней за период [max(order_date)-120, max(order_date)]
CREATE TABLE freq_users as
SELECT distinct orders.id_user, count(orders.id_order) as cnt, max(orders.order_date)
FROM orders
INNER JOIN freq_users_base on freq_users_base.id_user = orders.id_user
GROUP BY orders.id_user
HAVING 1 = 1 and
max(DATE_FORMAT(order_date, '%Y-%m-%d')) >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY
ORDER BY count(id_order) desc;
COMMIT;

-- 1.4 получается, что с вероятностью 0.68 часто покупающий будет продолжать покупать и дальше
SELECT count(f.id_user)/count(b.id_user), avg(cnt)
FROM freq_users_base b
LEFT JOIN freq_users f on f.id_user = b.id_user;

-- 1.5 посчитаем, сколько в среднем в месяц оформляют такие юзеры в деньгах
SELECT AVG(t.price_for_day_for_freq)*30
FROM 
(SELECT distinct order_date, sum(price) as price_for_day_for_freq
FROM freq_users 
INNER JOIN orders on orders.id_user = freq_users.id_user
GROUP BY order_date) t;

-- 2.  Группа часто покупающих, но которые не покупали уже значительное время. Так же можем сделать вывод, из
-- такой группы за след месяц сколько купят и на какую сумму. (постараться продумать логику)

-- 2.1 создадим таблицу юзеров, которые за 4 месяца в период [max(order_date)-240, max(order_date)-120] 
-- оформили 3 и больше заказов, но при этом не совершили ни одной покупки за период [max(order_date)-120, max(order_date)]
CREATE TABLE freq_users_stop_buying as 
SELECT distinct orders.id_user, count(orders.id_order), max(orders.order_date)
FROM orders
INNER JOIN freq_users_base on freq_users_base.id_user = orders.id_user
GROUP BY orders.id_user
HAVING 1 = 1 and
max(DATE_FORMAT(order_date, '%Y-%m-%d')) <= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY and 
max(DATE_FORMAT(order_date, '%Y-%m-%d')) >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120*2 DAY
ORDER BY count(id_order) desc;
COMMIT;

-- 2.2 с вероятностью 0.33 часто покупающий перестанет покупать
select count(f.id_user)/count(b.id_user)
from freq_users_base b
left join freq_users_stop_buying f on f.id_user = b.id_user;

-- 2.3 сделаем прогноз для часто оформляющих на 05.2017: 68% часто оформляющих останется в активной базе
-- пользователей, в среднем они сделают покупок на '54 570 000' в месяц.
SELECT AVG(tt.price_for_day_for_freq)*0.75*30
FROM 
(SELECT orders.order_date, sum(price) as price_for_day_for_freq
FROM orders 
INNER JOIN 
(SELECT id_user, count(id_order)
FROM orders
WHERE DATE_FORMAT(order_date, '%Y-%m-%d') >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY
GROUP BY id_user
HAVING count(id_order) >= 3) t on t.id_user = orders.id_user
WHERE DATE_FORMAT(order_date, '%Y-%m-%d') >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY
GROUP BY orders.order_date) tt ;

-- 3.  Отдельно разобрать пользователей с 1 и 2 покупками за все время, прогнозируем их:
-- 3.1. повторяем аналитику для редко покупающие пользователей
CREATE TABLE rarely_users_base as
SELECT distinct id_user, count(id_order)
FROM orders
WHERE DATE_FORMAT(order_date, '%Y-%m-%d') >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120*2 DAY and 
      DATE_FORMAT(order_date, '%Y-%m-%d') <= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY 
GROUP BY id_user
HAVING count(id_order) < 3;
commit;

-- 3.2 таких юзеров 154 832 в базе
SELECT count(*) FROM rarely_users_base;

-- 3.3 посчитаем, сколько из них продолжили покупать в последующие 120 дней за период [max(order_date)-120, max(order_date)]
CREATE TABLE rarely_users as
SELECT distinct orders.id_user, count(orders.id_order) as cnt, max(orders.order_date)
FROM orders
INNER JOIN rarely_users_base on rarely_users_base.id_user = orders.id_user
GROUP BY orders.id_user
HAVING 1 = 1 and
max(DATE_FORMAT(order_date, '%Y-%m-%d')) >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY
ORDER BY count(id_order) desc;
COMMIT;

-- 1.4 с вероятностью 0.16 редко покупающий будет продолжать покупать и дальше
SELECT count(f.id_user)/count(b.id_user), avg(cnt)
FROM rarely_users_base b
LEFT JOIN rarely_users f on f.id_user = b.id_user;

-- 1.5 сделаем прогноз для редко оформляющих на 05.2017: 16% редко оформляющих останется в активной базе
-- пользователей, в среднем они сделают покупок на '22 746 567'  в месяц.
SELECT AVG(tt.price_for_day_for_freq)*0.16*30
FROM 
(SELECT orders.order_date, sum(price) as price_for_day_for_freq
FROM orders 
INNER JOIN 
(SELECT id_user, count(id_order)
FROM orders
WHERE DATE_FORMAT(order_date, '%Y-%m-%d') >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY
GROUP BY id_user
HAVING count(id_order) < 3) t on t.id_user = orders.id_user
WHERE DATE_FORMAT(order_date, '%Y-%m-%d') >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY
GROUP BY orders.order_date) tt ;

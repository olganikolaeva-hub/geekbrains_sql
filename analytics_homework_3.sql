/* Урок 3. Типовые методы анализа данных */
-- 1.  Группа часто покупающих (3 и более покупок) и которые последний раз покупали не так давно. Считаем сколько
--  денег оформленного заказа приходится на 1 день. Умножаем на 30.

-- 1.1 создадим базовую таблицу юзеров, которые за 120 дней оформили больше 3х заказов.
-- Отсчет ведем от максимальной даты выборки - '2017-03-13'.
CREATE TABLE freq_users_base as
SELECT distinct id_user, count(id_order)
FROM orders
WHERE DATE_FORMAT(order_date, '%Y-%m-%d') >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120*2 DAY and 
      DATE_FORMAT(order_date, '%Y-%m-%d') <= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY 
GROUP BY id_user
HAVING count(id_order) > 3;
commit;

-- 1.2 таких получилось 13239
SELECT count(*) FROM freq_users_base;

-- 1.3 создадим таблицу юзеров, которые делали покупки за последние 240 дней, причем последняя покупка
-- была совершена ими не больше 120 дней назад. Отсчет ведем от максимальной даты выборки - '2017-03-13'.

CREATE TABLE freq_users as
SELECT distinct orders.id_user, count(orders.id_order), max(orders.order_date)
FROM orders
INNER JOIN freq_users_base on freq_users_base.id_user = orders.id_user
GROUP BY orders.id_user
HAVING 1 = 1 and
max(DATE_FORMAT(order_date, '%Y-%m-%d')) >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY
ORDER BY count(id_order) desc;
COMMIT;

-- 1.4 с вероятностью 0.58 часто покупающий будет продолжать покупать и дальше
select count(f.id_user)/count(b.id_user)
from freq_users_base b
left join freq_users f on f.id_user = b.id_user;

-- 1.5 посчитаем, сколько в среднем в месяц оформляют такие юзеры
SELECT AVG(t.price_for_day_for_freq)*30
FROM 
(SELECT distinct order_date, sum(price) as price_for_day_for_freq
FROM freq_users 
INNER JOIN orders on orders.id_user = freq_users.id_user
GROUP BY order_date) t;

-- 2.  Группа часто покупающих, но которые не покупали уже значительное время. Так же можем сделать вывод, из
-- такой группы за след месяц сколько купят и на какую сумму. (постараться продумать логику)

-- 2.1 создадим таблицу юзеров, которые сделали > 3 покупок за последние 240 дней, причем последняя покупка
-- была совершена ими больше 120 дней назад. Отсчет ведем от максимальной даты выборки - '2017-03-13'.

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

-- 2.2 с вероятностью 0.42 часто покупающий перестанет покупать
select count(f.id_user)/count(b.id_user)
from freq_users_base b
left join freq_users_stop_buying f on f.id_user = b.id_user;

-- 2.3 сделаем прогноз для часто оформляющих на 05.2017
SELECT AVG(tt.price_for_day_for_freq)*0.58*30
FROM 
(SELECT orders.order_date, sum(price) as price_for_day_for_freq
FROM orders 
INNER JOIN 
(SELECT id_user, count(id_order)
FROM orders
WHERE DATE_FORMAT(order_date, '%Y-%m-%d') >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY
GROUP BY id_user
HAVING count(id_order) > 3) t on t.id_user = orders.id_user
WHERE DATE_FORMAT(order_date, '%Y-%m-%d') >= DATE_FORMAT('2017-03-13', '%Y-%m-%d') - INTERVAL 120 DAY
GROUP BY orders.order_date) tt ;

-- 3.  Отдельно разобрать пользователей с 1 и 2 покупками за все время, прогнозируем их.
CREATE TABLE rarely_users as
SELECT distinct id_user, count(id_order), max(order_date)
FROM orders
GROUP BY id_user
HAVING count(id_order) <= 2
ORDER BY count(id_order) desc;
COMMIT;


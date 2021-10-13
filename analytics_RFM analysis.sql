/* Урок 4. Типовая аналитика маркетинговой активности */
--  RFM-анализ на основе данных по продажам за 2 года

-- 1. Определяем критерии для каждой буквы R, F, M (т.е. к примеру, R – 3 для клиентов, которые покупали <= 30
-- дней от последней даты в базе, R – 2 для клиентов, которые покупали > 30 и менее 60 дней от последней даты в
-- базе и т.д.):

-- FRECENCY: 1 - 75% юзеров совершили 1 покупку
--           2 - 10% 2 покупки
--           3 - 7% 3-4 покупок
--           4 - 5% 5-9 покупок
--           5 - 3% 10 и больше покупок

-- MONEY:    1 - 28% от всех денег - это покупки на сумму не больше 2000 рублей
--           2 - 25% [2000, 4000)
--           3 - 12% [4000, 6000)
--           4 - 12% [6000, 10000)
--           5 - 11% [10000, 20000)
--           6 - 7%  [20000, 60000)
--           6 - < 1% больше 60000

CREATE TABLE user_rfm as (
SELECT t.id_user,
       case when DATEDIFF('2017-03-13', t.max_order_date) <= 30 then '3'
            when (DATEDIFF('2017-03-13', t.max_order_date) > 30 and DATEDIFF('2017-03-13', t.max_order_date) <= 60) then '2'
	   else '1' end as recency,
       case when cnt_orders = 1 then '1'
            when cnt_orders = 2 then '2'
            when cnt_orders in (3,4) then '3'
            when cnt_orders in (5, 6, 7, 8, 9) then '4'
		    else '5' end as frecency,
	  case when money < 2000 then '1'
            when (money >= 2000 and money < 4000) then '2'
            when (money >= 4000 and money < 6000) then '3'
            when (money >= 6000 and money < 10000) then '4'
            when (money >= 10000 and money < 20000) then '5'
            when (money >= 20000 and money < 60000) then '6'
		    else '7' end as money
FROM
(SELECT id_user,
       max(order_date) as max_order_date,
       count(*) as cnt_orders,
       sum(price)  as money
FROM orders
GROUP BY id_user) t);
COMMIT;

-- 2. Для каждого пользователя получаем набор из 3 цифр (от 111 до 333, где 333 – самые классные пользователи)
--   Вводим группировку, к примеру, 333 и 233 – это Vip, 1XX – это Lost, остальные Regular

CREATE TABLE user_group as 
SELECT r.id_user,
       r.recency,
       r.frecency,
       r.money,
       case when (recency in (2,3) and frecency in (3,4,5) and money in (3,4,5)) then 'Vip'
            when (recency in (2,3) and frecency in (3,4,5) and money = '6') then 'Super Vip'
            when (recency in (2,3) and frecency in (3,4,5) and money = '7') then 'Very Super Vip'
            when recency = '1' then 'Lost'
            else 'Regular' end as user_group
FROM user_rfm r;
COMMIT;

-- 3. Для каждой группы из п. 3 находим кол-во пользователей, кот. попали в них и % товарооборота, которое
-- они сделали на эти 2 года. Проверяем, что общее кол-во пользователей бьется с суммой кол-во пользователей
-- по группам

SELECT user_group.user_group,
       count(distinct orders.id_user)/533466 as users_percent,
       sum(orders.price)/2275105322 as price_percent
FROM user_group
INNER JOIN orders on orders.id_user = user_group.id_user
GROUP BY user_group.user_group
ORDER BY sum(orders.price) desc;

SELECT count(distinct id_user), sum(price) FROM orders;
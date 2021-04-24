#----------------------------------------------------------------------------------------------------
#Тема “Сложные запросы”------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------

#1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders
#   в интернет магазине.

SELECT name
FROM users
WHERE id in (SELECT DISTINCT user_id FROM orders);

#2. Выведите список товаров products и разделов catalogs, который соответствует товару.

SELECT p.name, p.description, c.name
FROM products p 
INNER JOIN catalogs c ON p.catalog_id = c.id;

#3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов
#   cities (label, name). Поля from, to и label содержат английские названия городов,
#   поле name — русское. Выведите список рейсов flights с русскими названиями городов.

SELECT f.id, 
       c_from.name_ from_,
       c_to.name_  to_
FROM flights f
INNER JOIN cities c_from on f.from_ = c_from.label_
INNER JOIN cities c_to on f.to_ = c_to.label_
ORDER BY f.id;


 
#----------------------------------------------------------------------------------------------------
#Тема «Операторы, фильтрация, сортировка и ограничение»----------------------------------------------
#----------------------------------------------------------------------------------------------------

#1. Пусть в таблице users поля created_at и updated_at оказались незаполненными.
#Заполните их текущими датой и временем.

UPDATE users
SET created_at = current_timestamp, updated_at  = current_timestamp
WHERE id is not null;
 
#2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом
#VARCHAR и в них долгое время помещались значения в формате 20.10.2017 8:10. Необходимо преобразовать
#поля к типу DATETIME, сохранив введённые ранее значения.

ALTER TABLE users
ADD COLUMN created_at_new datetime,
ADD COLUMN updated_at_new datetime;
 
UPDATE users
SET created_at_new = STR_TO_DATE(created_at, '%d.%e.%Y %h:%i'), updated_at_new = STR_TO_DATE(updated_at, '%d.%e.%Y %h:%i');
 
ALTER TABLE users DROP created_at;
ALTER TABLE users DROP updated_at;
ALTER TABLE users CHANGE COLUMN created_at_new created_at datetime;
ALTER TABLE users CHANGE COLUMN updated_at_new updated_at datetime;
commit;
 
# 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные
# цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать
# записи таким образом, чтобы они выводились в порядке увеличения значения value. Однако нулевые
# запасы должны выводиться в конце, после всех записей.

(SELECT value
 FROM storehouses_products
 WHERE value > 0
 ORDER BY value)
  UNION
 (SELECT value
  FROM storehouses_products
  WHERE value = 0);
  
# 4. (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае.
# Месяцы заданы в виде списка английских названий (may, august)
  
SELECT *
FROM users
HAVING monthname(birthday_at) in ('may','august');
  
#----------------------------------------------------------------------------------------------------
#Тема «Агрегация данных»-----------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------

# 1. Подсчитайте средний возраст пользователей в таблице users.

SELECT avg(timestampdiff(year, birthday_at, now())) avg_age
FROM users;

# 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
# Следует учесть, что необходимы дни недели текущего года, а не года рождения.

ALTER TABLE users ADD COLUMN birthday_day_2021 varchar(10);

UPDATE users
SET birthday_day_2021 = concat('2021', '-', substr(birthday_at, 6, length(birthday_at)))
WHERE id is not null;

SELECT weekday(STR_TO_DATE(birthday_day_2021, '%Y-%m-%d')) week_of_the_daty,
       count(distinct birthday_day_2021)
FROM users
GROUP BY weekday(STR_TO_DATE(birthday_day_2021, '%Y-%m-%d'));

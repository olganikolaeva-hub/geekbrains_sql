#----------------------------------------------------------------------------------------------------
#Тема “Транзакции, переменные, представления”-------------------------------------------------------
#----------------------------------------------------------------------------------------------------

-- 1. В базе данных shop и sample присутствуют одни и те же таблицы учебной базы данных. Переместите запись id = 1
-- из таблицы shop.users в таблицу sample.users. Используйте транзакции.
-- Переместим из базы shop в базу sample строку из таблицы users с id = 1, используя транзакции
START TRANSACTION;
SELECT @name := name from shop.users where id = 1;
SELECT @birthday_at := birthday_at from shop.users where id = 1;
INSERT INTO sample.users (name, birthday_at) VALUES (@name, @birthday_at);
DELETE FROM shop.users WHERE id = 1;

-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее
-- название каталога name из таблицы catalogs.
CREATE VIEW name_catalog_products as
SELECT products.name as product_name, catalogs.name as catalog_name
FROM products
INNER JOIN catalogs on catalogs.id = products.catalog_id;

-- 3. Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи за август
-- 2018 года '2018-08-01', '2018-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный список дат
-- за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.

-- Cоздаем таблицу test для хранения разряженых календарных записей
CREATE TABLE test (id INT NOT NULL AUTO_INCREMENT primary key, created_at DATE);
INSERT INTO test (created_at) values (DATE('2018-08-01'));
INSERT INTO test (created_at) values (DATE('2018-08-04'));
INSERT INTO test (created_at) values (DATE('2018-08-16'));
INSERT INTO test (created_at) values (DATE('2018-08-17'));
COMMIT;

-- создаем и наполняем таблицу august_month датами для хранения полного списка дат за август с помощью процедуры august()
 DROP TABLE IF EXISTS august_month;
 CREATE TABLE august_month (id INT NOT NULL AUTO_INCREMENT primary key, august_day DATE);

DELIMITER //
CREATE PROCEDURE august(IN startdate DATE, IN enddate DATE)
BEGIN 
  SET @startdate = startdate;
  SET @enddate = enddate;
  WHILE @startdate <= @enddate DO
    INSERT INTO august_month (august_day) values (@startdate);
    SET @startdate = DATE_ADD(@startdate, interval 1 day);
  END WHILE;
END //

-- вызываем созданную процедуру для наполнения таблицы august
call august(DATE('2018-08-01'), DATE('2018-08-31'));

-- результирующий запрос
SELECT august_month.august_day , case when test.created_at is not null then '1' else '0' end as 'check'
FROM august_month
LEFT JOIN test on test.created_at = august_month.august_day;

-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет устаревшие
-- записи из таблицы, оставляя только 5 самых свежих записей.

-- Cоздаем таблицу table_created_at для хранения календарных записей
CREATE TABLE table_created_at (id INT NOT NULL AUTO_INCREMENT primary key, created_at DATE);
INSERT INTO table_created_at (created_at) values (DATE('2018-08-01'));
INSERT INTO table_created_at (created_at) values (DATE('2018-08-04'));
INSERT INTO table_created_at (created_at) values (DATE('2018-08-16'));
INSERT INTO table_created_at (created_at) values (DATE('2018-08-17'));
INSERT INTO table_created_at (created_at) values (DATE('2021-05-05'));
INSERT INTO table_created_at (created_at) values (DATE('2021-05-04'));
INSERT INTO table_created_at (created_at) values (DATE('2021-05-03'));
INSERT INTO table_created_at (created_at) values (DATE('2021-05-02'));
INSERT INTO table_created_at (created_at) values (DATE('2021-05-01'));
COMMIT;

-- создаем промежуточную таблицу temp для 5-ти свежих записей
CREATE TABLE TEMP as SELECT id FROM table_created_at ORDER BY created_at DESC LIMIT 5;

-- создаем промежуточную таблицу temp_old для старых записей
CREATE TABLE TEMP_OLD AS SELECT id FROM table_created_at WHERE id not in (SELECT id FROM TEMP);

-- удаляем старые записи
DELETE FROM table_created_at WHERE id in (SELECT id FROM TEMP_OLD);

#----------------------------------------------------------------------------------------------------
#Тема “Хранимые процедуры и функции, триггеры"-------------------------------------------------------
#----------------------------------------------------------------------------------------------------

-- 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. С 6:00 до 12:00 
-- функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый
-- вечер", с 00:00 до 6:00 — "Доброй ночи"
delimiter //
CREATE FUNCTION hello ()
RETURNS TEXT deterministic
BEGIN
 CASE
  WHEN CURTIME() BETWEEN '06:00:00' AND '12:00:00' THEN RETURN 'Доброе утро';
  WHEN CURTIME() BETWEEN '12:00:00' AND '18:00:00' THEN RETURN 'Доброе день';
  WHEN CURTIME() BETWEEN '18:00:00' AND '00:00:00' THEN RETURN 'Доброе вечер';
  ELSE RETURN 'Доброй ночи';
 END CASE;
END //

SELECT hello ();

-- 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие обоих полей
-- или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно
-- из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.

-- создаем и заполняем таблицу products
DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  desсription TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';

INSERT INTO products
  (name, desсription, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);

-- создаем триггер
delimiter //
CREATE TRIGGER check_null_values BEFORE INSERT on products
FOR EACH ROW BEGIN
DECLARE new_name TEXT DEFAULT NULL;
DECLARE new_desсription TEXT DEFAULT NULL;
SET new_name = NEW.name;
SET new_desсription = NEW.desсription;
 IF (ISNULL(new_name) and ISNULL(new_desсription)) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled';
 END IF;
END //

-- проверка 
delimiter ;
INSERT INTO products
  (name, desсription, price, catalog_id)
VALUES
  (NULL, NULL, 7890.00, 1);


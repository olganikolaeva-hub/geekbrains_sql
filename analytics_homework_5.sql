/* Урок 5. Системы web-аналитики */

-- Даны 2 таблицы:
-- Таблица клиентов clients, в которой находятся данные по карточному лимиту каждого клиента
-- clients
-- id_client (primary key) number,
-- limit_sum number

-- transactions
-- id_transaction (primary key) number,
-- id_client (foreign key) number,
-- transaction_date number,
-- transaction_time number,
-- transaction_sum number

-- Написать текст SQL-запроса, выводящего количество транзакций, сумму транзакций, среднюю сумму транзакции и дату и время первой транзакции для каждого клиента
-- Найти id пользователей, кот использовали более 70% карточного лимита

-- 1. Создаем необходимые таблицы ----------------------------------------------------------------------------- 
 
CREATE TABLE clients
(id_client INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор клиента", 
 limit_sum FLOAT COMMENT "Лимит клиента");
 
 INSERT INTO clients values (1, 10000);
 INSERT INTO clients values (2, 20000);
 INSERT INTO clients values (3, 30000);
 
  CREATE TABLE transactions
 (id_transaction INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор транзакции",
  id_client INT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатора клиента",
  transaction_date DATETIME COMMENT "Дата транзакции",   
  transaction_time TIME COMMENT "Время транзакции",  
  transaction_sum FLOAT COMMENT "Сумма транзакции");
  
  INSERT INTO transactions values (1, 1, '2021-01-01', '20:00:00', 500);
  INSERT INTO transactions values (2, 1, '2021-01-01', '21:00:00', 550);
  INSERT INTO transactions values (3, 1, '2021-01-02', '22:00:00', 600);
  INSERT INTO transactions values (4, 2, '2021-01-03', '20:00:00', 1500);
  INSERT INTO transactions values (5, 2, '2021-01-04', '21:00:00', 1550);
  INSERT INTO transactions values (6, 2, '2021-01-05', '22:00:00', 1600);
  INSERT INTO transactions values (7, 3, '2021-01-06', '23:00:00', 1500);
  INSERT INTO transactions values (8, 3, '2021-01-07', '21:10:00', 1550);
  INSERT INTO transactions values (9, 3, '2021-01-08', '22:15:00', 1900);
  INSERT INTO transactions values (10, 3, '2021-01-06', '22:01:00', 1500);
  INSERT INTO transactions values (11, 3, '2021-01-06', '22:02:00', 22000);
  COMMIT;
  
-- 2. Запросы ----------------------------------------------------------------------------- 
-- Количество транзакций, сумму транзакций, среднюю сумму транзакции и дату и время первой транзакции для
-- каждого клиента

SELECT id_client,
       count(id_transaction),
       AVG(transaction_sum),
       MIN(transaction_date) as min_date,
       TIME(SUBSTR(min(transaction_date + transaction_time), 9, 14)) as min_time
FROM transactions
GROUP BY id_client;

-- Найти id пользователей, которые использовали более 70% карточного лимита
SELECT t.id_client, t.limit_share FROM 
(SELECT clients.id_client,
       sum(transaction_sum)/clients.limit_sum as limit_share
FROM clients
INNER JOIN transactions on transactions.id_client = clients.id_client
GROUP BY clients.id_client) as t
WHERE t.limit_share >= 0.7;

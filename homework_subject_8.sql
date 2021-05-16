#------------------------------------------------------------------------------------------------------------------------
#Тема 8 "Сложные запросы"
#------------------------------------------------------------------------------------------------------------------------

-- !!! переписать запросы, заданные к ДЗ урока 6, с использованием JOIN!!!

-- 1 . Пусть задан некоторый пользователь. 
-- Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.

-- Здесь и далее используем БД vk, созданную в рамках домашней работы под номером 3. Дамп БД с тестовыми данными приложен
-- к текущей ДЗ.
-- Пусть задан пользователь под номером 52. Выбираем всех друзей из таблицы friendship, инициатором дружбы с которыми,
-- выступал указанный пользователь. 
SELECT friend_id FROM friendship WHERE user_id = 52;

-- Считаем количество сообщений от этих друзей и записываем в таблицу max_messages (при этом не важно, кто был инициатором
-- разговора: пользователь 52 либо его друг). Сортируем таблицу max_messages в порядке убывания количества сообщений
-- и выбираем первую строку с помощью ключевого слова LIMIT.

CREATE TABLE max_messages as
SELECT count(id) as cnt, from_user_id, to_user_id
FROM messages
INNER JOIN (SELECT friend_id FROM friendship WHERE user_id = 52) to_user_id
on to_user_id.friend_id = messages.to_user_id
WHERE from_user_id = 52
GROUP BY from_user_id, to_user_id
UNION
SELECT count(id) as cnt, from_user_id, to_user_id
FROM messages
INNER JOIN (SELECT friend_id FROM friendship WHERE user_id = 52) from_user_id
on from_user_id.friend_id = messages.from_user_id
WHERE to_user_id = 52
GROUP BY from_user_id, to_user_id;
COMMIT;


SELECT cnt as 'количество сообщений', from_user_id, to_user_id
FROM max_messages
ORDER BY cnt DESC
LIMIT 1;

-- 2. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

SELECT sum(cnt_likes)
FROM
(SELECT count(likes.id) as 'cnt_likes', to_user, data_of_birth
FROM likes
INNER JOIN users ON users.id = likes.to_user 
GROUP BY to_user, data_of_birth
ORDER BY data_of_birth DESC
LIMIT 10) sum_of_likes;

-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?
SELECT count(likes.id) as 'количество поставленных лайков', gender
FROM profiles
INNER JOIN likes on likes.from_user = profiles.user_id
GROUP BY gender
ORDER BY count(likes.id) DESC
LIMIT 1;

-- 4. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
-- Создаем таблицу low_like_activity, связывая users с таблицей лайков с помощью оператора LEFT JOIN. Так мы сможем увидеть
-- пользователей, кто не поставил ни одного лайка.

SELECT low_like_activity.cnt_likes + low_message_activity.cnt_messages,
       low_like_activity.id
FROM (SELECT count(likes.id) as cnt_likes, users.id
FROM users
LEFT JOIN likes on likes.from_user = users.id
GROUP BY users.id
ORDER BY count(likes.id)) as low_like_activity

LEFT JOIN (SELECT count(messages.id) as cnt_messages, users.id
FROM users
LEFT JOIN messages on messages.from_user_id = users.id
GROUP BY users.id
ORDER BY count(messages.id)) as low_message_activity 

ON low_message_activity.id = low_like_activity.id
ORDER BY low_like_activity.cnt_likes + low_message_activity.cnt_messages
LIMIT 10;

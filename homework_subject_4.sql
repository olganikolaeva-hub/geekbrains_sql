# Тестовая реализация сервиса-образца для курсовой работы: https://www.praktika.school/
CREATE DATABASE IF NOT EXISTS praktika_school;
USE praktika_school;

-- 1. Таблица для хранения сущности "Пользователь" (user) -----------------------------------------------------------------

CREATE TABLE users (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор пользователя",
first_name VARCHAR(100) NOT NULL COMMENT "Имя пользователя",
last_name VARCHAR(100) NOT NULL COMMENT "Фамилия пользователя",
email VARCHAR(100) NOT NULL UNIQUE COMMENT "Почта",
phone VARCHAR(100) NOT NULL UNIQUE COMMENT "Телефон",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

-- Ограничение на формат значений, хранящихся в атрибуте "Телефон"
ALTER TABLE users ADD CONSTRAINT `phone_check` CHECK (REGEXP_LIKE(phone, '[0-9]{10}'));

-- 2. Таблица для хранения сущности "Факультет" (faculty)--------------------------------------------------------------------
CREATE TABLE faculties (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор факультета",
faculty_name VARCHAR(100) NOT NULL COMMENT "Название факультета",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

-- 3. Таблица для связи сущностей "Пользователь" - "Факультет" (user_faculty)---------------------------------------------------
CREATE TABLE user_faculty (
user_id INT UNSIGNED NOT NULL COMMENT "Идентификатор пользователя",
faculty_id INT UNSIGNED NOT NULL COMMENT "Идентификатор факультета",
start_of_study DATETIME COMMENT "Дата начала обучения",
end_of_study DATETIME COMMENT "Дата окончания обучения",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
primary key (user_id, faculty_id)
);

-- Создание внешних ключей для таблицы user_faculty-----------------------------------------------------------------------
ALTER TABLE user_faculty ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE user_faculty ADD CONSTRAINT fk_faculty_id FOREIGN KEY (faculty_id) REFERENCES faculties (id);

-- 4. Таблица для хранения сущности "Предмет" (subject)----------------------------------------------------------------------
CREATE TABLE subjects (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор предмета",
faculty_id  INT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатор факультета",
subject_name VARCHAR(100) NOT NULL COMMENT "Название предмета",
subject_author VARCHAR(100) NOT NULL COMMENT "ФИО преподавателя",
subject_about VARCHAR(500) NOT NULL COMMENT "Описание предмета",
rating INT UNSIGNED NOT NULL COMMENT "Рейтинг предмета",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

-- Создание внешнего ключа для таблицы subjects (таким образом предмет связывается с факультетом) ------------------------
ALTER TABLE subjects ADD CONSTRAINT fk_subject_faculty FOREIGN KEY (faculty_id) REFERENCES faculties (id);

-- 5. Таблица для хранения сущности "Урок предмета" (topic)-------------------------------------------------------------------

CREATE TABLE topics (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор урока предмета",
subject_id INT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатор урока",
topic_name VARCHAR(100) NOT NULL COMMENT "Название урока",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

-- Создание внешнего ключа для таблицы subjects (таким образом урок связывается с предметом)-------------------------------
ALTER TABLE topics ADD CONSTRAINT fk_subject_topic FOREIGN KEY (subject_id) REFERENCES subjects (id);

-- 6. Таблица для хранения сущности "Оценка" (grade)------------------------------------------------------------------------
CREATE TABLE grades (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор оценки",
description VARCHAR(100),
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

-- 7. Таблица для связи сущностей "Оценка" - "Пользователь" - "Предмет"---------------------------------------------------
CREATE TABLE user_grade (
user_id INT UNSIGNED NOT NULL COMMENT "Идентификатор пользователя",
subject_id INT UNSIGNED NOT NULL COMMENT "Идентификатор предмета",
grade_id INT UNSIGNED NOT NULL COMMENT "Оценка за предмет",
start_of_study DATETIME COMMENT "Дата начала обучения",
end_of_study DATETIME COMMENT "Дата окончания обучения",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
primary key (user_id,subject_id,grade_id)
);

-- Создание внешнего ключа для таблицы user_grade  (таким образом оценка связывается с предметом и пользователем)---------------------------
ALTER TABLE user_grade ADD CONSTRAINT fk_user_grade_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE user_grade ADD CONSTRAINT fk_subject_grade_id FOREIGN KEY (subject_id) REFERENCES subjects (id);
ALTER TABLE user_grade ADD CONSTRAINT fk_grade_id FOREIGN KEY (grade_id) REFERENCES grades (id);

-- 8. Таблица для хранения сущности "Тип подписки"------------------------------------------------------------------------
CREATE TABLE subscriptions (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор подписки",
subscription_name VARCHAR(100) NOT NULL COMMENT "Название подписки: Тестовая подписка на 10 дней, Годовая подписка, Подписка навсегда",
subscription_description VARCHAR(100) NOT NULL COMMENT "Описание подписки",
price FLOAT COMMENT "Сумма за подписку",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

-- 9. Таблица для связи сущностей "Пользователь" - "Подписка"-------------------------------------------------------------------
CREATE TABLE user_subscription (
user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатор пользователя", 
subscription_id INT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатор подписки",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
primary key (user_id, subscription_id)
);

-- Создание внешнего ключа для таблицы user_subscription  (таким образом подписка связывается с пользователем)---------------------------
ALTER TABLE user_subscription ADD CONSTRAINT fk_user_subscription FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE user_subscription ADD CONSTRAINT fk_subscription FOREIGN KEY (subscription_id) REFERENCES subscriptions (id);

-- Заполнение тестовыми данными

INSERT INTO `faculties` (`id`, `faculty_name`, `created_at`, `updated_at`) VALUES (1, 'Маркетинг', '1982-01-31 22:16:04', '1981-03-14 18:15:31');
INSERT INTO `faculties` (`id`, `faculty_name`, `created_at`, `updated_at`) VALUES (2, 'Программирование', '2014-07-10 01:25:58', '2017-06-24 06:44:54');
INSERT INTO `faculties` (`id`, `faculty_name`, `created_at`, `updated_at`) VALUES (3, 'Дизайн', '2010-07-25 23:35:47', '2016-04-08 18:43:55');
INSERT INTO `faculties` (`id`, `faculty_name`, `created_at`, `updated_at`) VALUES (4, 'Контент', '2017-07-18 16:44:06', '1978-07-30 09:32:10');
INSERT INTO `faculties` (`id`, `faculty_name`, `created_at`, `updated_at`) VALUES (5, 'Бизнес', '2015-12-11 23:43:46', '2013-06-05 18:31:07');
INSERT INTO `faculties` (`id`, `faculty_name`, `created_at`, `updated_at`) VALUES (6, 'SMM', '2018-01-19 15:56:31', '1982-05-19 08:41:05');

INSERT INTO `grades` (`id`, `description`, `created_at`, `updated_at`) VALUES (1, 'Единица', '2012-02-09 06:58:33', '1971-07-07 07:26:20');
INSERT INTO `grades` (`id`, `description`, `created_at`, `updated_at`) VALUES (2, 'Неудовлетворительно', '2016-10-09 08:55:25', '1987-05-08 17:53:35');
INSERT INTO `grades` (`id`, `description`, `created_at`, `updated_at`) VALUES (3, 'Удовлетворительно', '1974-05-27 08:57:12', '2009-02-06 04:08:20');
INSERT INTO `grades` (`id`, `description`, `created_at`, `updated_at`) VALUES (4, 'Хорошо', '2005-04-11 00:02:50', '1975-07-03 00:05:16');
INSERT INTO `grades` (`id`, `description`, `created_at`, `updated_at`) VALUES (5, 'Отлично', '1970-08-03 21:28:06', '1995-03-20 03:54:29');

INSERT INTO `subjects` (`id`, `faculty_id`, `subject_name`, `subject_author`, `subject_about`, `rating`, `created_at`, `updated_at`) VALUES (1, 1, 'Креатив в рекламе', 'Possimus maiores quia voluptate voluptas quo.', 'Possimus maiores quia voluptate voluptas quo.', 7, '1995-12-02 15:13:29', '1976-01-20 07:26:44');
INSERT INTO `subjects` (`id`, `faculty_id`, `subject_name`, `subject_author`, `subject_about`, `rating`, `created_at`, `updated_at`) VALUES (2, 2, 'Python', 'Rerum numquam sed aut.', 'Perferendis libero alias doloribus voluptates mollitia dignissimos.', 6, '2008-03-03 03:02:58', '2019-11-22 04:48:00');
INSERT INTO `subjects` (`id`, `faculty_id`, `subject_name`, `subject_author`, `subject_about`, `rating`, `created_at`, `updated_at`) VALUES (3, 3, 'Интернет-магазин на Tilda', 'Quia at est deserunt esse molestiae et.', 'Qui minima repellat qui non consequatur repellendus.', 8, '1976-02-03 17:13:37', '1982-05-02 05:22:04');
INSERT INTO `subjects` (`id`, `faculty_id`, `subject_name`, `subject_author`, `subject_about`, `rating`, `created_at`, `updated_at`) VALUES (4, 4, 'Создание подкастов', 'Rerum rerum sequi dolore nulla sed harum.', 'Reprehenderit dolor tempora quidem voluptatum.', 3, '2009-11-11 15:59:05', '1976-05-25 11:04:22');
INSERT INTO `subjects` (`id`, `faculty_id`, `subject_name`, `subject_author`, `subject_about`, `rating`, `created_at`, `updated_at`) VALUES (5, 5, 'Инвестиции', 'Id expedita odio tenetur ad asperiores fugiat nostrum.', 'Adipisci corrupti veritatis voluptates aut sed consequatur ut.', 1, '2019-04-21 01:20:52', '1976-01-12 20:31:30');
INSERT INTO `subjects` (`id`, `faculty_id`, `subject_name`, `subject_author`, `subject_about`, `rating`, `created_at`, `updated_at`) VALUES (6, 6, 'Сторителлинг', 'Est nesciunt consequatur fuga nam.', 'Nam quo sunt odit voluptatum temporibus.', 4, '2011-06-24 21:45:03', '2004-04-22 16:48:45');

INSERT INTO `subscriptions` (`id`, `subscription_name`, `subscription_description`, `price`, `created_at`, `updated_at`) VALUES (1, 'Тестовая подписка', 'Dolores ut aliquid rem a inventore. Et nulla molestiae necessitatibus et sit laboriosam tempore. Und', '100', '1983-01-16 19:52:52', '2017-10-17 14:47:07');
INSERT INTO `subscriptions` (`id`, `subscription_name`, `subscription_description`, `price`, `created_at`, `updated_at`) VALUES (2, 'Подписка на год', 'Repudiandae quia expedita nostrum laudantium quod. Autem aut aliquid incidunt consectetur porro et. ', '1000', '2000-04-08 15:49:21', '2000-12-28 03:44:33');
INSERT INTO `subscriptions` (`id`, `subscription_name`, `subscription_description`, `price`, `created_at`, `updated_at`) VALUES (3, 'Подписка навсегда', 'Nam labore deleniti aut voluptatem error ut. Aliquam est totam quae. Dolores asperiores molestiae se', '10000', '2011-08-07 18:20:52', '2007-09-03 01:12:25');

INSERT INTO `topics` (`id`, `subject_id`, `topic_name`, `created_at`, `updated_at`) VALUES (1, 1, 'Метрики автовебинаров', '2003-01-30 05:24:05', '2016-06-23 10:10:18');
INSERT INTO `topics` (`id`, `subject_id`, `topic_name`, `created_at`, `updated_at`) VALUES (2, 2, 'Структура продающего автовебинара и лестница продаж', '1989-02-19 12:59:10', '1977-12-05 12:21:49');
INSERT INTO `topics` (`id`, `subject_id`, `topic_name`, `created_at`, `updated_at`) VALUES (3, 3, 'Стоимость и ценность дизайна', '1970-01-13 23:41:49', '1981-05-03 09:23:09');
INSERT INTO `topics` (`id`, `subject_id`, `topic_name`, `created_at`, `updated_at`) VALUES (4, 4, 'Что такое портфолио дизайнера', '2007-01-31 21:38:33', '2004-11-05 23:29:12');
INSERT INTO `topics` (`id`, `subject_id`, `topic_name`, `created_at`, `updated_at`) VALUES (5, 5, 'Как составлять структуру проекта и презентовать его', '1989-05-02 08:32:06', '1998-11-02 12:23:08');
INSERT INTO `topics` (`id`, `subject_id`, `topic_name`, `created_at`, `updated_at`) VALUES (6, 6, 'Как составлять бриф и подготовиться к интервью', '2010-04-29 17:44:18', '2010-09-23 18:42:34');

INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `phone`, `created_at`, `updated_at`) VALUES (1, 'Hershel', 'Pouros', 'nboyle@example.org', '9239418636', '1982-08-22 03:49:12', '2013-03-21 10:06:29');
INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `phone`, `created_at`, `updated_at`) VALUES (2, 'Enoch', 'Johnson', 'jocelyn.gibson@example.com', '9239418637', '1981-10-18 03:57:35', '1972-03-20 00:21:51');
INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `phone`, `created_at`, `updated_at`) VALUES (3, 'Gene', 'Gottlieb', 'kira.thiel@example.org', '9239418638', '2007-04-11 06:48:08', '2014-12-04 16:55:37');
INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `phone`, `created_at`, `updated_at`) VALUES (4, 'Tyra', 'Simonis', 'earl47@example.org', '9239418639', '1999-01-19 04:17:03', '2012-11-25 18:46:00');
INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `phone`, `created_at`, `updated_at`) VALUES (5, 'Delmer', 'Bogisich', 'jaskolski.isaias@example.org', '9239418610', '1971-01-12 22:59:34', '2015-01-16 08:45:04');
INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `phone`, `created_at`, `updated_at`) VALUES (6, 'Velma', 'Simonis', 'ondricka.velda@example.net', '9239418611', '2016-04-10 11:39:06', '1975-03-05 13:24:02');
INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `phone`, `created_at`, `updated_at`) VALUES (7, 'Jermey', 'Donnelly', 'ransom.klein@example.net', '9239418612', '2000-03-25 07:03:02', '2006-07-22 04:24:42');
INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `phone`, `created_at`, `updated_at`) VALUES (8, 'Tamia', 'Fisher', 'cassandre86@example.com', '9239418613', '1998-03-17 20:51:08', '2020-04-12 11:07:22');
INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `phone`, `created_at`, `updated_at`) VALUES (9, 'Aylin', 'Corkery', 'valentin69@example.net', '9239418614', '2002-07-26 09:38:20', '2000-10-28 08:03:46');
INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `phone`, `created_at`, `updated_at`) VALUES (10, 'Enoch', 'Champlin', 'sroberts@example.net', '9239418615', '2007-04-06 11:27:35', '1983-05-08 20:25:52');


INSERT INTO `user_faculty` (`user_id`, `faculty_id`, `start_of_study`, `end_of_study`, `created_at`, `updated_at`) VALUES (1, 1, '1989-12-06 04:10:05', '1976-03-27 06:12:31', '2012-09-25 23:50:50', '1979-08-17 15:43:51');
INSERT INTO `user_faculty` (`user_id`, `faculty_id`, `start_of_study`, `end_of_study`, `created_at`, `updated_at`) VALUES (2, 2, '1996-08-29 02:31:21', '1973-12-29 06:31:19', '1999-03-17 17:20:50', '2019-04-25 16:41:23');
INSERT INTO `user_faculty` (`user_id`, `faculty_id`, `start_of_study`, `end_of_study`, `created_at`, `updated_at`) VALUES (3, 3, '2008-09-17 14:13:22', '1983-03-07 11:09:37', '1992-10-16 00:12:18', '1977-03-02 03:56:00');
INSERT INTO `user_faculty` (`user_id`, `faculty_id`, `start_of_study`, `end_of_study`, `created_at`, `updated_at`) VALUES (4, 4, '2004-06-23 10:31:14', '1981-11-01 09:00:39', '2006-02-24 16:16:55', '2004-09-10 23:45:11');
INSERT INTO `user_faculty` (`user_id`, `faculty_id`, `start_of_study`, `end_of_study`, `created_at`, `updated_at`) VALUES (5, 5, '1972-10-08 00:34:47', '2020-01-27 20:24:05', '1989-09-25 22:50:26', '1979-08-30 13:09:26');
INSERT INTO `user_faculty` (`user_id`, `faculty_id`, `start_of_study`, `end_of_study`, `created_at`, `updated_at`) VALUES (6, 6, '1995-04-22 14:44:36', '1993-12-21 18:05:20', '1974-06-01 03:57:21', '1981-05-12 10:40:28');

INSERT INTO `user_grade` (`user_id`, `subject_id`, `grade_id`, `start_of_study`, `end_of_study`, `created_at`, `updated_at`) VALUES (1, 1, 1, '2017-01-18 09:35:30', '1974-07-29 03:21:53', '1972-08-01 02:55:35', '1979-03-02 22:48:12');
INSERT INTO `user_grade` (`user_id`, `subject_id`, `grade_id`, `start_of_study`, `end_of_study`, `created_at`, `updated_at`) VALUES (2, 2, 2, '1983-01-04 11:52:30', '2003-12-24 14:32:05', '2016-06-16 07:16:09', '1993-08-31 03:25:48');
INSERT INTO `user_grade` (`user_id`, `subject_id`, `grade_id`, `start_of_study`, `end_of_study`, `created_at`, `updated_at`) VALUES (3, 3, 3, '2019-01-06 08:47:19', '2020-12-25 07:51:48', '2014-09-18 10:58:16', '2013-12-04 20:16:05');
INSERT INTO `user_grade` (`user_id`, `subject_id`, `grade_id`, `start_of_study`, `end_of_study`, `created_at`, `updated_at`) VALUES (4, 4, 4, '1985-02-11 05:10:16', '2003-03-26 14:14:41', '1975-11-19 02:07:13', '2004-02-22 15:10:14');
INSERT INTO `user_grade` (`user_id`, `subject_id`, `grade_id`, `start_of_study`, `end_of_study`, `created_at`, `updated_at`) VALUES (5, 5, 5, '2008-10-23 13:31:59', '2014-06-11 08:50:16', '1972-05-12 14:05:03', '1971-06-16 10:00:27');

INSERT INTO `user_subscription` (`user_id`, `subscription_id`, `created_at`, `updated_at`) VALUES (1, 1, '1970-02-06 09:10:35', '1981-05-31 18:41:17');
INSERT INTO `user_subscription` (`user_id`, `subscription_id`, `created_at`, `updated_at`) VALUES (2, 2, '2001-08-21 12:12:25', '1971-12-13 05:17:51');
INSERT INTO `user_subscription` (`user_id`, `subscription_id`, `created_at`, `updated_at`) VALUES (3, 3, '2003-01-10 17:08:47', '2003-05-08 13:46:27');
COMMIT;

# Тестовая реализация сервиса-образца для курсовой работы: https://www.praktika.school/

CREATE DATABASE praktika_school;
USE praktika_school;

CREATE TABLE users (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор пользователя",
first_name VARCHAR(100) NOT NULL COMMENT "Имя пользователя",
last_name VARCHAR(100) NOT NULL COMMENT "Фамилия пользователя",
email VARCHAR(100) NOT NULL UNIQUE COMMENT "Почта",
phone VARCHAR(100) NOT NULL UNIQUE COMMENT "Телефон",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

CREATE TABLE faculties (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор факультета",
faculty_name VARCHAR(100) NOT NULL COMMENT "Название факультета",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

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

ALTER TABLE subjects ADD CONSTRAINT fk_subjects_faculty FOREIGN KEY (faculty_id) REFERENCES faculties (id);

CREATE TABLE topic (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор темы",
subject_id INT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатор предмета",
topic_name VARCHAR(100) NOT NULL COMMENT "Название темы",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

ALTER TABLE topic ADD CONSTRAINT fk_subjects_topic FOREIGN KEY (subject_id) REFERENCES subjects (id);

CREATE TABLE advantages (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор преимущества",
subject_id INT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатор предмета",
advantage VARCHAR(100) NOT NULL COMMENT "Название преимущества",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

ALTER TABLE advantages ADD CONSTRAINT fk_subjects_advantages FOREIGN KEY (subject_id) REFERENCES subjects (id);

CREATE TABLE useful_for (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор преимущества",
subject_id INT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатор предмета",
useful_for VARCHAR(100) NOT NULL COMMENT "Кому полезен курс",
useful_why VARCHAR(100) NOT NULL COMMENT "Почему полезен курс",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

ALTER TABLE useful_for ADD CONSTRAINT fk_subjects_useful FOREIGN KEY (subject_id) REFERENCES subjects (id);

CREATE TABLE user_faculty (
user_id INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT "Идентификатор пользователя",
faculty_id INT UNSIGNED NOT NULL COMMENT "Идентификатор факультета",
start_of_study DATETIME COMMENT "Дата начала обучения",
end_of_study DATETIME COMMENT "Дата окончания обучения",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
PRIMARY KEY (user_id, faculty_id)
);

ALTER TABLE user_faculty ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE user_faculty ADD CONSTRAINT fk_faculty_id FOREIGN KEY (faculty_id) REFERENCES faculties (id);

CREATE TABLE user_study (
user_id INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT "Идентификатор пользователя",
subject_id INT UNSIGNED NOT NULL COMMENT "Идентификатор предмета",
grade INT UNSIGNED NOT NULL COMMENT "Оценка за предмет",
start_of_study DATETIME COMMENT "Дата начала обучения",
end_of_study DATETIME COMMENT "Дата окончания обучения",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
PRIMARY KEY (user_id, subject_id)
);

ALTER TABLE user_study ADD CONSTRAINT fk_user_study_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE user_study ADD CONSTRAINT fk_subject_id FOREIGN KEY (subject_id) REFERENCES subjects (id);

CREATE DATABASE dimension_current;
USE dimension_current;

CREATE TABLE user_status (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор подписки",
user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатор пользователя",
status_name VARCHAR(100) NOT NULL COMMENT "Название подписки: Тестовая подписка на 10 дней, Годовая подписка, Подписка навсегда",
description_  VARCHAR(100) NOT NULL COMMENT "Описание подписки",
price FLOAT COMMENT "Сумма за подписку",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

ALTER TABLE user_status ADD CONSTRAINT fk_users_status FOREIGN KEY (user_id) REFERENCES praktika_school.users (id);

CREATE DATABASE dimension_history;
USE dimension_history;

CREATE TABLE user_status (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор статуса",
user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатор пользователя",
status_name VARCHAR(100) NOT NULL COMMENT "Название статуса: Тестовая подписка на 10 дней, Годовая подписка, Подписка навсегда",
description_  VARCHAR(100) NOT NULL COMMENT "Описание подписки",
price FLOAT COMMENT "Сумма за подписку",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
);

ALTER TABLE user_status ADD CONSTRAINT fk_user_status FOREIGN KEY (user_id) REFERENCES praktika_school.users (id);


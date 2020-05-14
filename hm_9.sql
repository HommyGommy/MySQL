-- В базе данных shop и sample присутствуют одни и те же таблицы учебной базы данных.
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;
UPDATE lesson_5.users SET name = (SELECT name FROM shop.users WHERE id = 1);
UPDATE lesson_5.users SET birthday_at = (SELECT birthday_at FROM shop.users WHERE id = 1);
UPDATE lesson_5.users SET created_at = (SELECT created_at FROM shop.users WHERE id = 1);
UPDATE lesson_5.users SET updated_at = (SELECT updated_at FROM shop.users WHERE id = 1);
SAVEPOINT updated_id;
COMMIT;

-- Создайте представление, которое выводит название name товарной позиции из таблицы products
--  и соответствующее название каталога name из таблицы catalogs.

CREATE VIEW only_name AS SELECT name FROM products;
SELECT * FROM only_name//

-- Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро",
-- с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
--  с 18:00 до 00:00 — "Добрый вечер",
--  с 00:00 до 6:00 — "Доброй ночи".

DELIMITER //
CREATE FUNCTION hello()
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
	DECLARE morning, midday, evening, night VARCHAR(255);
	SET morning = 'Good morning, sir';
	SET midday = 'Good day, sir';
	SET evening = 'Good evening, sir';
	SET night = 'Good night';
		IF NOW() BETWEEN '06:00' AND '12:00' THEN
		RETURN morning;
		END IF;
		IF NOW() BETWEEN '12:00' AND '18:00' THEN
		RETURN midday;
		END IF;
		IF NOW() BETWEEN '18:00' AND '00:00' THEN
		RETURN evening;
		END IF;
		IF NOW() BETWEEN '00:00' AND '06:00' THEN
		RETURN night;
		END IF;
END//

-- В таблице products есть два текстовых поля: name с названием товара и description с его описанием.
-- Допустимо присутствие обоих полей или одно из них.
-- Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема.
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены.
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.

CREATE TRIGGER not_null BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
  DECLARE name_id, desc_id VARCHAR(255);
  SELECT name INTO name_id, desc_id FROM catalogs LIMIT 1;
  SET NEW.name = COALESCE(NEW.name, OLD.name, name_id, desc_id);
END//
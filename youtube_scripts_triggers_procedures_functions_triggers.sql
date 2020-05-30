
-- Показать продолжительность жизни топ-10 юзеров, которые ставят исключительно dislike
-- Т.е. если юзеоры были созданы совсем недавно и поставили много дизлайков, они могут быть ботами
-- Использовано: JOIN, группировка, вложенный запрос - сделал намеренно из-за требований для курсовой

SELECT DISTINCT ch.id, ch.created_at,
ROUND((NOW() - ch.created_at ) / 3600 / 24 / 365 / 12, 2) AS life_in_months,
COUNT(*) OVER(PARTITION BY ch.id) AS dislike_meter
  FROM channels ch
    LEFT JOIN likes_videos lv
      ON ch.id = lv.channel_id
        WHERE ch.id IN (
          SELECT channel_id FROM( 
            SELECT channel_id, COUNT(*) AS dislike_meter
            FROM likes_videos
            GROUP BY channel_id
            HAVING like_video_type_id = 2
            ORDER BY dislike_meter DESC LIMIT 10) AS haters_list)
    ORDER BY dislike_meter DESC;

-- Посмотреть количество просмотров в разрезе категорий видео и поколений зрителей и посчитать их долю
-- пример: видео с тегом cars больше всего смотрят юзеры из 2010-х, их доля 36,67% из всех поколений
-- Использовано: оконные функции, многотабличный JOIN

SELECT DISTINCT t.tag,
LEFT(p.birthday, 3) AS 'decade',
COUNT(*) OVER w AS 'views',
ROUND(COUNT(*) OVER w / COUNT(*) OVER(PARTITION BY tag) * 100, 2) AS 'views share, %'
  FROM views v
    JOIN videos vi
      ON v.id_video_viewed = vi.id
    JOIN tags t
      ON vi.tag_id = t.id
    JOIN profiles p
      ON v.channel_id = p.google_id
  WINDOW w AS (PARTITION BY CONCAT(tag, LEFT(p.birthday, 3)) ORDER BY LEFT(p.birthday, 3))
    ORDER BY tag, decade, views DESC;

-- Индексы:
CREATE INDEX profiles_birthday_idx ON profiles(birthday);
CREATE INDEX channels_created_at_idx ON channels(created_at);
CREATE INDEX channels_updated_at_idx ON channels(updated_at);
CREATE INDEX videos_size_idx ON videos(size);
CREATE INDEX videos_duration_idx ON videos(duration);
CREATE INDEX videos_created_at_idx ON videos(created_at);
CREATE INDEX comments_created_at_idx ON comments(created_at);
CREATE INDEX subscriptions_created_at_idx ON subscriptions(created_at);

-- Представление №1
-- Самые просматриваемые категории за полседние 3 месяца

CREATE VIEW popularity_by_tags AS
  SELECT DISTINCT t.tag,
  COUNT(*) OVER(PARTITION BY tag) AS views
    FROM views v
      JOIN videos vi
        ON v.id_video_viewed = vi.id
      JOIN tags t
        ON t.id = vi.tag_id
     WHERE vi.created_at BETWEEN NOW() - INTERVAL 90 DAY AND NOW()
    ORDER BY views DESC;

SELECT * FROM popularity_by_tags;


   
-- Представление №2
-- Показывает 3 наиболее популярные категории, на которые оформлены платные подписки
-- Как вариант, это можно использовать для дальнейшей аналитики для рекламодателей, т.к. здесь платежеспособная аудитория

CREATE VIEW top_3_tags_for_future_commercial_adds AS
  SELECT DISTINCT t.tag,
  COUNT(*) OVER(PARTITION BY tag) AS views
    FROM views v
      LEFT JOIN videos vi
        ON v.id_video_viewed = vi.id
      LEFt JOIN tags t
        ON t.id = vi.tag_id
      LEFT JOIN channels ch 
        ON ch.id = vi.channel_id
      LEFT JOIN channel_subscriptions chs 
        ON chs.channel_id = ch.id
      LEFT JOIN subscriptions s 
        ON s.channel_id = ch.id AND s.subscription_type_id = 2
    ORDER BY views DESC
    LIMIT 3;
   
 SELECT * FROM top_3_tags_for_future_commercial_adds;
   

-- Процедура, которая делает реиндексацию каналов пользователей по дате обновленя,
-- а после удаляет юзера, если он не показывал активности за последние 50 лет (только для примера)

DELIMITER $$
CREATE PROCEDURE user_activity_reset_index
BEGIN
	DROP INDEX channels_updated_at_idx ON channels;
    CREATE INDEX channels_updated_at_idx ON channels(updated_at);
	DELETE FROM channels WHERE channels.updated_at < NOW() - INTERVAL YEAR 50;
END;
DELIMITER ;

-- Триггер, которые высылает письмо на почтовый ящик пользователя после его удаления
-- Я не уверен, что с помощью mysql можно написать такую функцию, поэтому оставил здесь заглушку

DELIMITER $$
CREATE TRIGGER aware_user_of__inactivity
AFTER DELETE 
ON channels FOR EACH ROW
BEGIN
	CALL 'NOTIFICATION EMAIL TO USER';
END $$
DELIMITER ;


-- Функция возвращает сообщение, если у заданного в параметре channel_id больше 1 миллиона просмотров

DELIMITER $$
CREATE FUNCTION one_million_subs(channels_needed) RETURNS VARCHAR(255)
BEGIN
	IF SELECT channel_id , COUNT(*) AS views FROM views GROUP BY channel_id HAVING channel_id = channels_needed > 1000000 THEN
	RETURN "The video has more than 1 million views";
	END IF
END $$
DELIMITER ;

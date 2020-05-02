USE vk;

-- Добавим все внешние ключи

ALTER TABLE media
  ADD CONSTRAINT media_media_type_id_fk
    FOREIGN KEY (media_type_id) REFERENCES media_types(id);

ALTER TABLE messages
  ADD CONSTRAINT messages_community_id
    FOREIGN KEY (community_id) REFERENCES communities(id);
   
ALTER TABLE communities_users 
  ADD CONSTRAINT communities_users_community_id_fk
    FOREIGN KEY (community_id) REFERENCES communities(id),
  ADD CONSTRAINT communities_users_user_id_fk
	FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE friendship 
  ADD CONSTRAINT friendship_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_friend_id_fk
	FOREIGN KEY (friend_id) REFERENCES users(id),
  ADD CONSTRAINT friendhip_status_id_fk
    FOREIGN KEY (status_id) REFERENCES friendship_statuses(id);
 
ALTER TABLE likes 
  ADD CONSTRAINT likes_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT likes_target_id_to_users_fk
	FOREIGN KEY (target_id) REFERENCES users(id),
  ADD CONSTRAINT likes_target_id__to_messages_fk
	FOREIGN KEY (target_id) REFERENCES messages(id),
  ADD CONSTRAINT likes_target_id_to_media_fk
	FOREIGN KEY (target_id) REFERENCES media(id),
  ADD CONSTRAINT likes_target_id_to_posts_fk
	FOREIGN KEY (target_id) REFERENCES posts(id),
  ADD CONSTRAINT likes_target_type_id_fk
    FOREIGN KEY (target_type_id) REFERENCES target_types(id);

ALTER TABLE posts 
  ADD CONSTRAINT posts_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT posts_community_id_fk
	FOREIGN KEY (community_id) REFERENCES communities(id),
  ADD CONSTRAINT posts_media_id_fk
    FOREIGN KEY (media_id) REFERENCES media(id);

-- Подсчитать общее количество лайков десяти самых молодых пользователей

SELECT COUNT(*)
  FROM likes 
  	WHERE target_type_id = 2 and target_id IN (
  	  SELECT * FROM (
	    SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10) AS temp);
	   
-- Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT gender, COUNT(*) AS likes_count
  FROM profiles
   WHERE user_id IN (
   	SELECT user_id FROM likes)
  	  GROUP BY gender
  	   ORDER BY likes_count DESC
  	  	LIMIT 1;

-- Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети
-- Лучше было бы создать отдельную таблицу activity, где суммировалось бы кол-во likes, posts, messages, но это не уместилось бы с 1 запрос)
-- Критерии минимальной активности: одновременная принадлежность к нижним 33% каждой из групп likes, posts messages +
-- максимально старая дата обновления пользователя на случай, если везде попадется по 1 лайку, 1 посту и 1 сообщению
-- Решение неидеальное, т.к. руками ставлю цифру 33 и в ответе у меня получается всего 2 юзера

SELECT id, updated_at
  FROM users
  	WHERE id IN(
	  SELECT user_id FROM (
		SELECT user_id, COUNT(*) AS likes_count FROM likes GROUP BY user_id ORDER BY likes_count LIMIT 33) as likes_activity)
	AND id IN(
	  SELECT user_id FROM (
	    SELECT user_id, COUNT(*) AS posts_count FROM posts GROUP BY user_id ORDER BY posts_count LIMIT 33) as posts_activity)
	AND id IN(
	  SELECT from_user_id FROM (
		SELECT from_user_id, COUNT(*) AS messages_count FROM messages GROUP BY from_user_id ORDER BY messages_count LIMIT 33) as mess_activity)
	ORDER BY updated_at
	LIMIT 10;

 
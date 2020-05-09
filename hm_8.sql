use vk;

-- Подсчитать общее количество лайков десяти самых молодых пользователей


SELECT SUM(likes_count) AS answer FROM
	(SELECT COUNT(l.id) AS likes_count
	  FROM profiles p
	    LEFT JOIN likes l
	      ON p.user_id = l.target_id
	        WHERE l.target_type_id = 2
	          GROUP BY p.user_id
	            ORDER BY p.birthday DESC
	              LIMIT 10) AS answer;
	             
        
 -- Определить кто больше поставил лайков (всего) - мужчины или женщины?

 SELECT p.gender, COUNT(*) AS likes_count
   FROM profiles AS p
     JOIN likes AS l
       ON l.user_id = p.user_id 
   	     GROUP BY gender
   	       ORDER BY likes_count DESC
   	         LIMIT 1;

 -- Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети
 
SELECT id, updated_at, (likes_count + messages_count + posts_count) AS activity FROM
  (SELECT u.id,
	      u.updated_at,
	      COUNT(DISTINCT(l.id)) AS likes_count,
	      COUNT(DISTINCT(m.id )) AS messages_count,
	      COUNT(DISTINCT(p.id)) AS posts_count
    FROM users AS u
      LEFT JOIN likes AS l
        ON u.id = l.user_id
      LEFT JOIN messages AS m
        ON u.id = m.from_user_id 
      LEFT JOIN posts AS p
        ON u.id = p.user_id 
          GROUP BY u.id) AS act
    ORDER BY activity
      LIMIT 10;
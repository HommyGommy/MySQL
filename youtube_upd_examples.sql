SELECT * FROM videos LIMIT 20;
SELECT * FROM subscriptions ORDER BY channel_id LIMIT 20;
SELECT * FROM channel_subscriptions ORDER BY channel_id LIMIT 20;



SELECT COUNT(*) FROM views;

UPDATE views SET id_video_viewed = FLOOR(1 + RAND() * 200);

DESC views;

ALTER TABLE views MODIFY ip_address VARCHAR(255) NOT NULL;
UPDATE profiles SET photo_id = (
  CONCAT('https://google.com/youtube_users/', FLOOR(100000 + RAND() * 100000)));


UPDATE channels SET updated_at = 
   DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % (DATEDIFF(DAY, '20050214', '20200214')+1)), '20050214'
  ));
 
SET @MIN = '2005-04-14 00:00:00';
SET @MAX = '2020-05-18 00:00:00';

UPDATE comments
  SET created_at = TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, @MIN, @MAX)), @MIN);
    WHERE created_at < channel_created_at;

SELECT v.id AS video_id, v.channel_id, v.created_at AS video_created, c.created_at AS channel_created
  FROM videos v
    JOIN channels c
      ON v.channel_id = c.id
        LIMIT 20;
       
ALTER TABLE subscriptions ADD COLUMN channel_created_at DATETIME;
ALTER TABLE subscription_types MODIFY  name VARCHAR(10);

UPDATE channel_subscriptions cs
  JOIN subscriptions s
    ON cs.subscription_id = s.channel_id
      SET cs.subscription_id = s.id;


ALTER TABLE views RENAME COLUMN view_tyoe_id TO view_type_id;

SELECT * FROM views LIMIT 20;

UPDATE views SET ip_address =
  CONCAT(
    FLOOR(100 + RAND() * 155), '.',
    FLOOR(1 + RAND() * 255), '.',
    FLOOR(1 + RAND() * 50), '.',
    FLOOR(1 + RAND() * 100));
    
UPDATE views SET ip_address = SUBSTRING(ip_address,2);



SELECT * FROM channel_subscriptions LIMIT 10;
SELECT * FROM channels LIMIT 20;
SELECT * FROM comments c2 LIMIT 10;
SELECT * FROM devices d2 LIMIT 10;
SELECT * FROM likes_comments lc LIMIT 10;
SELECT * FROM likes_comments_types lct LIMIT 10;
SELECT * FROM likes_videos lv LIMIT 10;
SELECT * FROM likes_comments_types lct LIMIT 10;
SELECT * FROM profiles p2 LIMIT 10;
SELECT * FROM subscription_types st LIMIT 10;
SELECT * FROM subscriptions s2 LIMIT 10;
SELECT * FROM videos v2 LIMIT 10;
SELECT * FROM view_type vt LIMIT 10;
SELECT * FROM views v2 LIMIT 10;
SELECT * FROM tags LIMIT 10;

ALTER TABLE videos ADD COLUMN link VARCHAR(100) NOT NULL AFTER id;
ALTER TABLE channels ADD COLUMN is_commercial INT NOT NULL AFTER id;
UPDATE videos SET link = 
  CONCAT('https://www.youtube/',channel_id, '/', SUBSTRING(title,1,5));
  
UPDATE channels SET is_commercial = FLOOR(0 + RAND() * 2) ;

SELECT is_commercial, COUNT(*) FROM channels GROUP BY is_commercial;

ALTER TABLE videos ADD COLUMN tag_id INT NOT NULL AFTER size;
UPDATE videos SET tag_id = FLOOR(1 + RAND() * 10);
-- Таблица профилей - по сути, google account
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
  google_id INT UNSIGNED NOT NULL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  gender CHAR(1) NOT NULL,
  photo_id INT UNSIGNED NOT NULL,
  birthday DATE,
  city VARCHAR(100),
  country VARCHAR(100),
  email VARCHAR(120) NOT NULL UNIQUE,
  phone VARCHAR(120) NOT NULL UNIQUE
);
  
-- У каждого пользователя youtube есть канал, даже если он не выкладывает свои видео.
-- Это и есть таблица users, но корректнее назвать ее channel
DROP TABLE IF EXISTS channels;
CREATE TABLE channels (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,  
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

-- Таблица подписок, где важно учитывать тип подписки (платная/бесплатная), а так же активна или нет в данный момент
DROP TABLE IF EXISTS subscriptions;
CREATE TABLE subscriptions (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  subscription_type_id INT UNSIGNED NOT NULL,
  channel_id INT UNSIGNED NOT NULL,
  is_active INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);
  
  
-- Таблица типа подписок
DROP TABLE IF EXISTS subscription_types;
CREATE TABLE subscription_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  subscription_type INT UNSIGNED NOT NULL
);

ALTER TABLE subscription_types MODIFY name ENUM('free','paid');


-- Таблица связей канал-подписка
DROP TABLE IF EXISTS channel_subscriptions;
CREATE TABLE channel_subscriptions (
  channel_id INT UNSIGNED NOT NULL,
  subscription_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (channel_id, subscription_id)
);

-- Таблица видео
DROP TABLE IF EXISTS videos;
CREATE TABLE videos (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  channel_id INT UNSIGNED NOT NULL,
  title TEXT NOT NULL,
  description MEDIUMTEXT NOT NULL,
  duration TIME NOT NULL,
  size INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица категорий (разметка)
DROP TABLE IF EXISTS tags;
CREATE TABLE tags (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  tag VARCHAR(255) NOT NULL
);

INSERT INTO tags VALUES
  (1, 'games'),
  (2, 'DIY'),
  (3, 'kids'),
  (4, 'news'),
  (5, 'sport'),
  (6, 'cars'),
  (7, 'entartainment'),
  (8, 'review'),
  (9, 'social'),
  (10, 'vlog');

-- Таблица просмотров
DROP TABLE IF EXISTS views;
CREATE TABLE views (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  channel_id INT UNSIGNED NOT NULL,
  id_video_viewed INT UNSIGNED NOT NULL,
  ip_address INT UNSIGNED NOT NULL UNIQUE, 
  device_type_id INT UNSIGNED NOT NULL,
  view_tyoe_id INT UNSIGNED NOT NULL
  duration TIME
);

-- Таблица типа просмотров: алогритм youtube учитывает просмотр,
-- если он был  >30 сек, т.к. может возникнуть много поддельных просмотрв или бот-просмоторв
DROP TABLE IF EXISTS view_type;
CREATE TABLE  view_type (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL
;

ALTER TABLE view_type ADD COLUMN name ENUM('ok','fraud');
UPDATE view_type SET name = 'ok' WHERE id = 1;
UPDATE view_type SET name = 'fraud' WHERE id = 2;

  
-- Таблица девайсов
DROP TABLE IF EXISTS devices;
CREATE TABLE devices (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

-- Таблица лайков для видео
DROP TABLE IF EXISTS likes_videos;
CREATE TABLE likes_videos (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  video_id INT UNSIGNED NOT NULL,
  like_video_type_id INT UNSIGNED NOT NULL
);

ALTER TABLE likes_videos ADD COLUMN channel_id INT UNSIGNED NOT NULL AFTER id;
UPDATE likes_videos SET channel_id = FLOOR(1 + RAND() * 1000);

-- Таблица для определения like/dislike для видео
DROP TABLE IF EXISTS likes_videos_types;
CREATE TABLE likes_videos_types (
  id INT UNSIGNED NOT NULL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

ALTER TABLE likes_videos_types DROP COLUMN name;
ALTER TABLE likes_videos_types ADD COLUMN name ENUM('like','dislike');
UPDATE likes_videos_types SET name = 'like' WHERE id = 1;
UPDATE likes_videos_types SET name = 'dislike' WHERE id = 2;

-- Таблица комментов
DROP TABLE IF EXISTS comments;
CREATE TABLE comments (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  channel_id INT UNSIGNED NOT NULL,
  video_id INT UNSIGNED NOT NULL,
  comment_text MEDIUMTEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица лайков для комментов
DROP TABLE IF EXISTS likes_comments;
CREATE TABLE likes_comments (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  comment_id INT UNSIGNED NOT NULL,
  like_comment_type_id INT UNSIGNED NOT NULL
);

ALTER TABLE likes_comments ADD COLUMN channel_id INT UNSIGNED NOT NULL AFTER id;
UPDATE likes_comments SET channel_id = FLOOR(1 + RAND() * 1000);

-- Таблица для определения like/dislike для комментов под видео
DROP TABLE IF EXISTS likes_comments_types;
CREATE TABLE likes_comments_types (
  id INT UNSIGNED NOT NULL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

ALTER TABLE likes_comments_types DROP COLUMN name;
ALTER TABLE likes_comments_types ADD COLUMN name ENUM('like','dislike');
UPDATE likes_comments_types SET name = 'like' WHERE id = 1;
UPDATE likes_comments_types SET name = 'dislike' WHERE id = 2;

-- Внешние ключи
DESC channels;

ALTER TABLE channels
  ADD CONSTRAINT channels_id_fk
    FOREIGN KEY (id) REFERENCES profiles(google_id);
   
ALTER TABLE subscriptions
  ADD CONSTRAINT subscriptions_type_id_fk
    FOREIGN KEY (subscription_type_id) REFERENCES subscription_types(id),
  ADD CONSTRAINT subscriptions_channel_id_fk
    FOREIGN KEY (channel_id) REFERENCES channels(id);
   
ALTER TABLE channel_subscriptions
  ADD CONSTRAINT channels_bscriptions_subscription_id_fk
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id);
   
ALTER TABLE likes_comments
  ADD CONSTRAINT like_comment_type_id_fk
    FOREIGN KEY (like_comment_type_id) REFERENCES likes_comments_types(id),
  ADD CONSTRAINT like_comment_comment_id_fk
    FOREIGN KEY (comment_id) REFERENCES comments(id);
   
ALTER TABLE likes_comments
  ADD CONSTRAINT likes_comments_channel_id_fk
    FOREIGN KEY (channel_id) REFERENCES channels(id);

ALTER TABLE likes_videos
  ADD CONSTRAINT like_video_type_id_fk
    FOREIGN KEY (like_video_type_id) REFERENCES likes_videos_types(id),
  ADD CONSTRAINT like_comment_video_id_fk
    FOREIGN KEY (video_id) REFERENCES videos(id);

ALTER TABLE likes_videos
  ADD CONSTRAINT likes_videos_channel_id_fk
    FOREIGN KEY (channel_id) REFERENCES channels(id);
   
ALTER TABLE views
  ADD CONSTRAINT views_channel_id_fk
    FOREIGN KEY (channel_id) REFERENCES channels(id),
  ADD CONSTRAINT views_id_video_viewed_fk
    FOREIGN KEY (id_video_viewed) REFERENCES videos(id),
  ADD CONSTRAINT views_device_type_id_fk
    FOREIGN KEY (device_type_id) REFERENCES devices(id),
  ADD CONSTRAINT views_view_type_id_fk
    FOREIGN KEY (view_type_id) REFERENCES view_type(id);
   
ALTER TABLE videos
  ADD CONSTRAINT videos_channel_id_fk
    FOREIGN KEY (channel_id) REFERENCES channels(id),
  ADD CONSTRAINT videos_tag_id_fk
    FOREIGN KEY (tag_id) REFERENCES tags(id);

ALTER TABLE comments
  ADD CONSTRAINT comments_channel_id_fk
    FOREIGN KEY (channel_id) REFERENCES channels(id),
  ADD CONSTRAINT comments_video_id_fk
    FOREIGN KEY (video_id) REFERENCES videos(id);


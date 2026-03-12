DROP DATABASE IF EXISTS koko_db;
CREATE DATABASE IF NOT EXISTS koko_db;
USE koko_db;

CREATE TABLE IF NOT EXISTS users (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  username    VARCHAR(50)  NOT NULL UNIQUE,
  email       VARCHAR(100) NOT NULL UNIQUE,
  password    VARCHAR(255) NOT NULL,
  token       VARCHAR(255) DEFAULT NULL,
  theme       VARCHAR(10)  DEFAULT 'light',
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100)  NOT NULL,
  description TEXT          NOT NULL,
  price       BIGINT        NOT NULL,
  category    VARCHAR(50)   NOT NULL,
  image       VARCHAR(255)  DEFAULT 'https://ih1.redbubble.net/image.4905811472.8675/st,extra_large,507x507-pad,600x600,f8f8f8.jpg',
  stock       INT           DEFAULT 0,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reviews (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  product_id  INT          NOT NULL,
  username    VARCHAR(50)  NOT NULL,
  rating      TINYINT      NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT         NOT NULL,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

INSERT INTO products (name, description, price, category, image, stock) VALUES
('Arabica Flores',   'Kopi Arabica single origin dari Flores dengan cita rasa fruity dan sedikit asam yang menyegarkan.', 85000, 'Single Origin', 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=400', 50),
('Robusta Lampung',  'Kopi Robusta pilihan dari Lampung, bold dan kuat cocok untuk espresso.', 65000, 'Single Origin', 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400', 75),
('House Blend KOKO', 'Racikan eksklusif KOKO, perpaduan sempurna Arabica dan Robusta dengan after taste cokelat.', 75000, 'Blend', 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400', 100),
('Gayo Aceh Premium','Kopi Gayo dari dataran tinggi Aceh, aroma harum dan rasa penuh yang memanjakan.', 95000, 'Single Origin', 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=400', 30),
('Toraja Sulawesi',  'Kopi Toraja dengan karakteristik earthy yang khas, cocok untuk pour over.', 90000, 'Single Origin', 'https://images.unsplash.com/photo-1504630083234-14187a9df0f5?w=400', 40);

-- Reviews
INSERT INTO reviews (product_id, username, rating, comment) VALUES
(1, 'keane', 5, 'Kopi terbaik yang pernah saya coba! Aroma dan rasanya luar biasa.'),
(1, 'admin', 4, 'Sangat enak, sedikit asam tapi justru itu yang bikin unik.'),
(2, 'keane', 4, 'Cocok banget buat yang suka kopi kuat. Recommended!'),
(3, 'admin', 5, 'House blend ini beneran enak, after taste cokelatnya kerasa banget.'),
(4, 'keane', 5, 'Gayo Aceh selalu jadi favorit. Kualitas top!');

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
('Arabica Flores',
 'Kopi Arabica single origin dari Flores dengan cita rasa fruity dan sedikit asam yang menyegarkan.',
 85000, 'Single Origin',
 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=400', 50),
('Robusta Lampung',
 'Kopi Robusta pilihan dari Lampung, bold dan kuat cocok untuk espresso.',
 65000, 'Single Origin',
 'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?w=400', 75),
('House Blend KOKO',
 'Racikan eksklusif KOKO, perpaduan sempurna Arabica dan Robusta dengan after taste cokelat.',
 75000, 'Blend',
 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400', 100),
('Gayo Aceh Premium',
 'Kopi Gayo dari dataran tinggi Aceh, aroma harum dan rasa penuh yang memanjakan.',
 95000, 'Single Origin',
 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=400', 30),
('Toraja Sulawesi',
 'Kopi Toraja dengan karakteristik earthy yang khas, cocok untuk pour over.',
 90000, 'Single Origin',
 'https://images.unsplash.com/photo-1504630083234-14187a9df0f5?w=400', 40),
('Mandheling Sumatra',
 'Kopi Mandheling dari Sumatra Utara, full body dengan rasa earthy dan sedikit cokelat gelap.',
 88000, 'Single Origin',
 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400', 35),
('Java Preanger',
 'Kopi Java dari pegunungan Preanger Jawa Barat, rasa bersih dengan hints of spice yang khas.',
 80000, 'Single Origin',
 'https://images.unsplash.com/photo-1521302080334-4bebac2763a6?w=400', 45),
('Kintamani Bali',
 'Kopi Arabica Kintamani dari Bali dengan proses natural, rasa citrusy dan floral yang unik.',
 92000, 'Single Origin',
 'https://images.unsplash.com/photo-1498804103079-a6351b050096?w=400', 25),
('Dark Roast Blend',
 'Blend premium dark roast untuk espresso kuat, cocok untuk cappuccino dan latte.',
 70000, 'Blend',
 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=400', 60),
('Cold Brew Concentrate',
 'Konsentrat cold brew siap pakai, diseduh 18 jam dengan biji pilihan untuk rasa smooth dan bold.',
 110000, 'Cold Brew',
 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400', 20),
('Wamena Papua',
 'Kopi langka dari lembah Baliem Wamena Papua, organic tanpa pestisida dengan rasa bersih dan kompleks.',
 120000, 'Single Origin',
 'https://images.unsplash.com/photo-1611854779393-1b2da9d400fe?w=400', 15),
('Liberica Lampung',
 'Kopi Liberica langka dari Lampung, aroma kayu dan buah tropis yang tidak ditemukan di jenis lain.',
 98000, 'Single Origin',
 'https://images.unsplash.com/photo-1559496417-e7f25cb247f3?w=400', 20);

-- Reviews
INSERT INTO reviews (product_id, username, rating, comment) VALUES
(1, 'keane', 5, 'Kopi terbaik yang pernah saya coba! Aroma dan rasanya luar biasa.'),
(1, 'admin', 4, 'Sangat enak, sedikit asam tapi justru itu yang bikin unik.'),
(2, 'keane', 4, 'Cocok banget buat yang suka kopi kuat. Recommended!'),
(3, 'admin', 5, 'House blend ini beneran enak, after taste cokelatnya kerasa banget.'),
(4, 'keane', 5, 'Gayo Aceh selalu jadi favorit. Kualitas top!');

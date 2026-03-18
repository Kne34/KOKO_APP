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

INSERT INTO products (id, name, description, price, category, image, stock, created_at) VALUES
(1, 'Arabica (Coffea Arabica)', 'Spesies kopi paling unggul yang tumbuh di ketinggian 1.000-2.000 mdpl. Memiliki bentuk biji lonjong dan garis tengah berlekuk. Secara sensorik, Arabica menawarkan kompleksitas rasa tinggi mulai dari buah-buahan (fruity), bunga (floral), hingga kacang-kacangan, dengan kadar kafein rendah (1.2%) dan keasaman yang cerah.', 125000, 'Species', 'https://www.foodandwine.com/thmb/XbKXqQvF61Csj9XLs_Nj3xwlwEI=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/Everything-You-Need-To-Know-About-Arabica-Coffee-FT-BLOG0822-2000-127d1551916e45138ea373de75f08138.jpg', 100, '2026-03-18 13:39:25'),
(2, 'Robusta (Coffea Canephora)', 'Kopi yang tangguh terhadap hama dan tumbuh di dataran rendah (di bawah 800 mdpl). Bijinya cenderung bulat dengan garis tengah lurus. Robusta memiliki kadar kafein hampir dua kali lipat Arabica (2.2%-2.7%), menghasilkan body yang sangat tebal, aroma seperti gandum/tanah, dan rasa dominan cokelat pahit tanpa asam.', 85000, 'Species', 'https://static.wixstatic.com/media/nsplsh_8db0116dbe7f4ca89215b696d4c3b94d~mv2.jpg/v1/fill/w_1000,h_668,al_c,q_85,usm_0.66_1.00_0.01/nsplsh_8db0116dbe7f4ca89215b696d4c3b94d~mv2.jpg', 150, '2026-03-18 13:39:25'),
(3, 'Liberica (Coffea Liberica)', 'Sering disebut \"Kopi Nangka\" di Indonesia karena ukurannya yang 2x lebih besar dari Arabica. Spesies ini berasal dari Afrika Barat dan sangat toleran terhadap tanah gambut. Profil rasanya sangat unik dan kontroversial; memiliki aroma kayu yang kuat, smoky, dengan sentuhan rasa buah nangka yang matang dan manis.', 115000, 'Species', 'https://www.tastingtable.com/img/gallery/what-makes-liberica-coffee-unique/l-intro-1679591419.jpg', 40, '2026-03-18 13:39:25'),
(4, 'Excelsa (Coffea Dewevrei)', 'Awalnya dianggap spesies terpisah, namun kini diklasifikasikan sebagai varietas Liberica. Excelsa memiliki profil rasa yang tajam (tart) dan kompleks yang sering digunakan dalam blend untuk menambah kedalaman rasa. Karakteristiknya menyerupai buah beri liar yang difermentasi dengan aroma yang sangat menusuk namun memikat.', 110000, 'Species', 'https://trubus.id/wp-content/uploads/2024/11/Kopi-Excelsa-Wonosalam-Mendunia.jpg', 30, '2026-03-18 13:39:25'),
(5, 'Geisha / Gesha', 'Varietas Arabica yang berasal dari Ethiopia namun meledak di Panama. Geisha dikenal sebagai kopi paling mahal karena tingkat kesulitan tanamnya. Karakteristiknya menyerupai teh (tea-like), sangat ringan dengan dominasi aroma melati (jasmine), jeruk bergamot, dan kejernihan rasa yang tidak ditemukan di varietas lain.', 350000, 'Varietal', 'https://wnfdiary.com/wp-content/uploads/2019/05/geisha-coffee-2.jpg', 10, '2026-03-18 13:39:25'),
(6, 'Typica', 'Induk dari banyak varietas Arabica modern. Meskipun produktivitasnya rendah dan rentan penyakit, Typica dihargai karena kualitas cangkirnya yang sangat bersih (clean cup), manis alami, dan body yang halus. Banyak ditemukan di perkebunan kopi tua di Jawa dan Amerika Latin.', 140000, 'Varietal', 'https://cornercoffeestore.com/wp-content/uploads/2022/11/typica-roasted-coffee-beans_Kieu-images_Shutterstock.jpg', 25, '2026-03-18 13:39:25'),
(7, 'Bourbon', 'Keturunan langsung Typica yang bermutasi di Pulau Bourbon (sekarang Réunion). Bourbon memiliki potensi kemanisan (sweetness) yang luar biasa mirip karamel atau butterscotch. Teksturnya lebih padat dan buttery dibandingkan Typica, menjadikannya favorit bagi para roaster kopi specialty.', 135000, 'Varietal', 'https://www.coffeeness.de/wp-content/uploads/2023/08/arabica-coffee-beans.jpg', 35, '2026-03-18 13:39:25'),
(8, 'Peaberry (Kopi Lanang)', 'Bukanlah varietas botani, melainkan anomali alami di mana buah kopi hanya menghasilkan satu biji tunggal berbentuk bulat (bukan dua biji pipih berpasangan). Karena nutrisi terserap hanya ke satu biji, Peaberry dipercaya memiliki rasa yang lebih terkonsentrasi, lebih cerah, dan tingkat kemanisan yang lebih tinggi.', 160000, 'Specialty', 'https://upload.wikimedia.org/wikipedia/commons/b/b3/Peaberry_coffee_beans%2C_close_up.jpg', 20, '2026-03-18 13:39:25'),
(9, 'Yellow Caturra', 'Mutasi dari varietas Bourbon yang memiliki warna buah kuning terang saat matang sempurna (umumnya kopi berwarna merah). Pigmen kuning ini sering kali berkorelasi dengan profil rasa yang lebih condong ke arah buah-buahan tropis seperti nanas atau jeruk, dengan tingkat keasaman yang lebih tinggi dari Red Caturra.', 130000, 'Varietal', 'https://lantang.id/wp-content/uploads/2022/11/Kopi-yellow-caturra-1.jpg', 20, '2026-03-18 13:39:25'),
(10, 'Maragogype', 'Varian Typica dengan ukuran biji yang sangat besar (Elephant Bean). Tumbuh optimal di dataran tinggi. Meskipun bijinya raksasa, rasanya justru sangat halus dan ringan dengan profil aroma herbal dan floral yang lembut. Sangat populer di pasar kopi Eropa sebagai barang mewah.', 175000, 'Varietal', 'https://bachacoffee.com/images/default-source/loose-coffee/details-page/single-origin/bacha-single-origin-elephant-maragogype-loose-coffee-beans-1000x1000.tmb-bc00000005.jpeg?Culture=en', 15, '2026-03-18 13:39:25'),
(11, 'Pacamara', 'Persilangan antara varietas Pacas dan Maragogype. Menghasilkan biji yang besar dengan profil rasa yang sangat kompleks dan intens. Seringkali muncul sensasi rasa rempah, cokelat hitam, dan buah batu (stone fruit) seperti plum atau ceri hitam dalam satu seduhan.', 180000, 'Varietal', 'https://awsimages.detik.net.id/community/media/visual/2022/12/12/3-fakta-biji-kopi-pacamara-salah-satu-biji-kopi-terbaik-tahun-2022.jpeg?w=1200', 15, '2026-03-18 13:39:25'),
(12, 'Longberry', 'Varietas Arabica yang banyak dikembangkan di wilayah Gayo, Aceh. Sesuai namanya, biji ini memiliki bentuk fisik yang jauh lebih panjang dan ramping dibanding Arabica biasa. Memiliki profil rasa yang eksotis dengan body sedang dan tingkat keasaman yang seimbang.', 145000, 'Varietal', 'https://algro.co.id/wp-content/uploads/2023/01/gayo-longberry.jpg', 20, '2026-03-18 13:39:25');

INSERT INTO reviews (product_id, username, rating, comment) VALUES
(1, 'keane', 5, 'Kopi terbaik yang pernah saya coba! Aroma dan rasanya luar biasa.'),
(1, 'admin', 4, 'Sangat enak, sedikit asam tapi justru itu yang bikin unik.'),
(2, 'keane', 4, 'Cocok banget buat yang suka kopi kuat. Recommended!'),
(3, 'admin', 5, 'House blend ini beneran enak, after taste cokelatnya kerasa banget.'),
(4, 'keane', 5, 'Gayo Aceh selalu jadi favorit. Kualitas top!');

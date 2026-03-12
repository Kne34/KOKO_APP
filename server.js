const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'koko_db',
  waitForConnections: true,
  connectionLimit: 10,
});

pool.getConnection()
  .then(conn => { console.log('✅ MySQL connected'); conn.release(); })
  .catch(err => { console.error('❌ MySQL failed:', err.message); process.exit(1); });

const ok  = (res, data, msg = 'Success', status = 200) =>
  res.status(status).json({ success: true, message: msg, data });
const err = (res, msg, status = 400) =>
  res.status(status).json({ success: false, message: msg, data: null });

// ── AUTH ──────────────────────────────────────────────────────────
app.post('/api/auth/register', async (req, res) => {
  const { username, email, password } = req.body;
  if (!username || !email || !password) return err(res, 'Semua field wajib diisi');
  if (username.length < 4)   return err(res, 'Username minimal 4 karakter');
  if (username.includes(' ')) return err(res, 'Username tidak boleh ada spasi');
  if (password.length < 6)   return err(res, 'Password minimal 6 karakter');
  if (!/[0-9]/.test(password)) return err(res, 'Password harus mengandung angka');
  if (!/^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/.test(email)) return err(res, 'Format email tidak valid');
  try {
    const [ex] = await pool.query('SELECT id FROM users WHERE username=? OR email=?', [username, email]);
    if (ex.length > 0) return err(res, 'Username atau email sudah digunakan');
    const hashed = await bcrypt.hash(password, 10);
    const [r] = await pool.query('INSERT INTO users (username,email,password) VALUES (?,?,?)', [username, email, hashed]);
    return ok(res, { id: r.insertId, username, email }, 'Registrasi berhasil', 201);
  } catch(e) { return err(res, 'Server error', 500); }
});

app.post('/api/auth/login', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) return err(res, 'Username dan password wajib diisi');
  try {
    const [rows] = await pool.query('SELECT * FROM users WHERE username=?', [username]);
    if (rows.length === 0) return err(res, 'Username tidak ditemukan', 404);
    const match = await bcrypt.compare(password, rows[0].password);
    if (!match) return err(res, 'Password salah', 401);
    const { password: _, ...u } = rows[0];
    return ok(res, u, 'Login berhasil');
  } catch(e) { return err(res, 'Server error', 500); }
});

// ── USERS ─────────────────────────────────────────────────────────
app.get('/api/users', async (req, res) => {
  const [rows] = await pool.query('SELECT id,username,email,created_at FROM users');
  return ok(res, rows);
});

app.get('/api/users/:id', async (req, res) => {
  const [rows] = await pool.query('SELECT id,username,email,created_at FROM users WHERE id=?', [req.params.id]);
  if (!rows.length) return err(res, 'User tidak ditemukan', 404);
  return ok(res, rows[0]);
});

app.put('/api/users/:id', async (req, res) => {
  const { username, email, password } = req.body;
  const updates = []; const values = [];
  if (username) { updates.push('username=?'); values.push(username); }
  if (email)    { updates.push('email=?');    values.push(email); }
  if (password) { updates.push('password=?'); values.push(await bcrypt.hash(password, 10)); }
  if (!updates.length) return err(res, 'Tidak ada field yang diupdate');
  values.push(req.params.id);
  await pool.query(`UPDATE users SET ${updates.join(',')} WHERE id=?`, values);
  const [rows] = await pool.query('SELECT id,username,email,created_at FROM users WHERE id=?', [req.params.id]);
  return ok(res, rows[0], 'User berhasil diupdate');
});

app.delete('/api/users/:id', async (req, res) => {
  const [r] = await pool.query('DELETE FROM users WHERE id=?', [req.params.id]);
  if (!r.affectedRows) return err(res, 'User tidak ditemukan', 404);
  return ok(res, null, 'User berhasil dihapus');
});

// ── PRODUCTS ──────────────────────────────────────────────────────
app.get('/api/products', async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM products ORDER BY created_at DESC');
  return ok(res, rows);
});

app.get('/api/products/:id', async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM products WHERE id=?', [req.params.id]);
  if (!rows.length) return err(res, 'Produk tidak ditemukan', 404);
  return ok(res, rows[0]);
});

app.post('/api/products', async (req, res) => {
  const { name, description, price, category, image, stock } = req.body;
  if (!name || !description || !price || !category) return err(res, 'name, description, price, category wajib diisi');
  const [r] = await pool.query(
    'INSERT INTO products (name,description,price,category,image,stock) VALUES (?,?,?,?,?,?)',
    [name, description, Number(price), category,
     image || 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=400',
     Number(stock) || 0]
  );
  const [rows] = await pool.query('SELECT * FROM products WHERE id=?', [r.insertId]);
  return ok(res, rows[0], 'Produk berhasil ditambahkan', 201);
});

app.put('/api/products/:id', async (req, res) => {
  const { name, description, price, category, image, stock } = req.body;
  const updates = []; const values = [];
  if (name)        { updates.push('name=?');        values.push(name); }
  if (description) { updates.push('description=?'); values.push(description); }
  if (price)       { updates.push('price=?');       values.push(Number(price)); }
  if (category)    { updates.push('category=?');    values.push(category); }
  if (image)       { updates.push('image=?');       values.push(image); }
  if (stock !== undefined) { updates.push('stock=?'); values.push(Number(stock)); }
  if (!updates.length) return err(res, 'Tidak ada field yang diupdate');
  values.push(req.params.id);
  const [r] = await pool.query(`UPDATE products SET ${updates.join(',')} WHERE id=?`, values);
  if (!r.affectedRows) return err(res, 'Produk tidak ditemukan', 404);
  const [rows] = await pool.query('SELECT * FROM products WHERE id=?', [req.params.id]);
  return ok(res, rows[0], 'Produk berhasil diupdate');
});

app.delete('/api/products/:id', async (req, res) => {
  const [r] = await pool.query('DELETE FROM products WHERE id=?', [req.params.id]);
  if (!r.affectedRows) return err(res, 'Produk tidak ditemukan', 404);
  return ok(res, null, 'Produk berhasil dihapus');
});

// ── REVIEWS ───────────────────────────────────────────────────────
app.get('/api/products/:id/reviews', async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM reviews WHERE product_id=? ORDER BY created_at DESC', [req.params.id]);
  return ok(res, rows);
});

app.post('/api/products/:id/reviews', async (req, res) => {
  const { username, rating, comment } = req.body;
  if (!username || !rating || !comment) return err(res, 'username, rating, comment wajib diisi');
  if (rating < 1 || rating > 5) return err(res, 'Rating harus 1-5');
  const [prod] = await pool.query('SELECT id FROM products WHERE id=?', [req.params.id]);
  if (!prod.length) return err(res, 'Produk tidak ditemukan', 404);
  const [r] = await pool.query(
    'INSERT INTO reviews (product_id,username,rating,comment) VALUES (?,?,?,?)',
    [req.params.id, username, Number(rating), comment]
  );
  const [rows] = await pool.query('SELECT * FROM reviews WHERE id=?', [r.insertId]);
  return ok(res, rows[0], 'Review berhasil ditambahkan', 201);
});

app.delete('/api/reviews/:id', async (req, res) => {
  const [r] = await pool.query('DELETE FROM reviews WHERE id=?', [req.params.id]);
  if (!r.affectedRows) return err(res, 'Review tidak ditemukan', 404);
  return ok(res, null, 'Review berhasil dihapus');
});

app.listen(PORT, () => console.log(`✅ KOKO API → http://localhost:${PORT}`));

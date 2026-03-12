var express = require('express');
var db = require('../database/database');
var router  = express.Router();
var auth = require('../middleware/token');
var path    = require('path');
var multer  = require('multer');
var { ok, err } = require("../helper/helper");
const adminOnly = require('../middleware/adminonly');

var storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'public/uploads/');
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    },
});

var upload = multer({
    storage,
    fileFilter: (req, file, cb) => {
        const allowed = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp'];
        if (allowed.includes(file.mimetype)) cb(null, true);
        else cb(new Error('Hanya file gambar yang diizinkan'));
    },
    limits: {fileSize: 2 * 1024 * 1024},
});


router.get('/', auth, (req, res) => {
    db.query(
        'SELECT * FROM products ORDER BY created_at DESC',
        (err2, result) => {
            if(err2) return err(res, "Gagal Query");
            return ok(res, result, "Berhasil Query");
        }
    )    
});

router.get('/:id', auth, (req, res) => {
    db.query(
        'SELECT * FROM products WHERE id = ?',
        [req.params.id],
        (err2, result) => {
            if (err2) return err(res, err2.message, 500); 
            if (result.length === 0) return err(res, 'Produk tidak ditemukan', 404); 
            return ok(res, result, "Produk berhasil ditemukan")
        }
    );
});

router.post('/', auth, adminOnly, upload.single('image'), (req, res) => {
    const {name, description, price, category, stock} = req.body;
    
    if (!name || !description || !price || !category) return err(res, 'Field name, description, price, category wajib diisi');
    
    const image = req.file ? `http://10.0.0.2:3000/uploads/${req.file.filename}` : null;
    
    db.query(
        'INSERT INTO products (name, description, price, category, image, stock) VALUES (?, ?, ?, ?, ?, ?)',
        [name, description, price, category, image, stock ?? 0],
        (err2, result) => {
            if (err2) return err(res, err2.message, 500);
            return ok(res, {
                id: result.insertId,
                name, description, price, category, image,
                stock: stock ?? 0,
            }, 'Produk berhasil ditambahkan', 201);
        }
    );
});

router.put('/:id', auth, adminOnly, upload.single('image'), (req, res) => {
    const {name, description, price, category, stock} = req.body;
    const updates = [];
    const values  = [];
    
    if (name) { 
        updates.push('name = ?');
        values.push(name);
    }
    if (description) {
        updates.push('description = ?');
        values.push(description);
    }
    if (price) {
        updates.push('price = ?');
        values.push(price);
    }
    if (category) {
        updates.push('category = ?');
        values.push(category);
    }
    if (stock !== undefined) {
        updates.push('stock = ?');
        values.push(stock);
    }
    if (req.file) {
        updates.push('image = ?');
        values.push(`http://10.0.0.2:3000/uploads/${req.file.filename}`);
    }
    
    if (updates.length === 0) return err(res, 'Tidak ada field yang diupdate');
    
    values.push(req.params.id);
    db.query(
        `UPDATE products SET ${updates.join(', ')} WHERE id = ?`,
        values,
        (err2) => {
            if (err2) return err(res, err2.message, 500);
            db.query(
                'SELECT * FROM products WHERE id = ?',
                [req.params.id],
                (err3, result) => {
                    if (err3) return err(res, err3.message, 500);
                    return ok(res, result[0], 'Produk berhasil diupdate');
                }
            );
        }
    );
});

router.delete('/:id', auth, adminOnly, (req, res) => {
    db.query(
        'DELETE FROM products WHERE id = ?',
        [req.params.id],
        (err2, result) => {
            if (err2) return err(res, err2.message, 500);
            if (result.affectedRows === 0) return err(res, 'Produk tidak ditemukan', 404);
            return ok(res, null, 'Produk berhasil dihapus');
        }
    );
});

module.exports = router;
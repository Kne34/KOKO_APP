var express = require('express');
var router  = express.Router({ mergeParams: true });
var db      = require('../database/database');
var auth    = require('../middleware/token');
var { ok, err } = require('../helper/helper');

router.get('/', auth, (req, res) => {
    db.query(
        'SELECT * FROM reviews WHERE product_id = ? ORDER BY created_at DESC',
        [req.params.id],
        (err2, result) => {
            if (err2) return err(res, err2.message, 500);
            return ok(res, result);
        }
    );
});

router.post('/', auth, (req, res) => {
    const { username, rating, comment } = req.body;
    const productId = req.params.id;
    
    if (!username || !rating || !comment)
        return err(res, 'User harus ada');
    if (rating < 1 || rating > 5)
        return err(res, 'Rating harus antara 1 sampai 5');
    
    db.query(
        'SELECT id FROM products WHERE id = ?',
        [productId],
        (err2, result) => {
            if (err2) return err(res, err2.message, 500);
            if (result.length === 0) return err(res, 'Produk tidak ditemukan', 404);
            
            db.query(
                'INSERT INTO reviews (product_id, username, rating, comment) VALUES (?, ?, ?, ?)',
                [productId, username, rating, comment],
                (err3, insertResult) => {
                    if (err3) return err(res, err3.message, 500);
                    return ok(res, {
                        id: insertResult.insertId,
                        product_id: parseInt(productId),
                        username,
                        rating,
                        comment,
                    }, 'Review berhasil ditambahkan', 201);
                }
            );
        }
    );
});

router.delete('/:reviewId', auth, (req, res) => {
    db.query(
        'DELETE FROM reviews WHERE id = ? AND product_id = ?',
        [req.params.reviewId, req.params.id],
        (err2, result) => {
            if (err2) return err(res, err2.message, 500);
            if (result.affectedRows === 0) return err(res, 'Review tidak ditemukan', 404);
            return ok(res, null, 'Review berhasil dihapus');
        }
    );
});

module.exports = router;
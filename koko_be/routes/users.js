var express = require("express");
var db = require("../database/database");
var bcrypt = require("bcryptjs");
var router = express.Router();
var auth = require('../middleware/token')
var { ok, err } = require("../helper/helper");

router.get("/", (req, res) => {
    db.query(
        "SELECT id, username, email, created_at FROM users",
        (err2, result) => {
            if (err2) return err(res, err2.message, 500);
            return ok(res, result);
        },
    );
});

router.get("/:id", (req, res) => {
    db.query(
        "SELECT id, username, email, created_at FROM users WHERE id = ?",
        [req.params.id],
        (err2, result) => {
            if (err2) return err(res, err2.message, 500);
            if (result.length === 0) return err(res, "User tidak ditemukan", 404);
            return ok(res, result[0]);
        },
    );
});

router.put('/:id/theme', auth, (req, res) => {
    const { theme } = req.body;
    if (!theme) return err(res, 'Theme wajib diisi');
    if (!['light', 'dark'].includes(theme)) return err(res, 'Theme tidak valid');
    
    db.query(
        'UPDATE users SET theme = ? WHERE id = ?',
        [theme, req.params.id],
        (err2) => {
            if (err2) return err(res, err2.message, 500);
            return ok(res, { theme }, 'Theme berhasil diupdate');
        }
    );
});

module.exports = router;

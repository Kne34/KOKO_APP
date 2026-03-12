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

router.put("/:id", auth, (req, res) => {
    const { username, email, password } = req.body;
    const updates = [];
    const values = [];
    
    if (username) {
        updates.push("username = ?");
        values.push(username);
    }
    if (email) {
        updates.push("email = ?");
        values.push(email);
    }
    
    const update = () => {
        finalValues.push(req.params.id);
        db.query(
            `UPDATE users SET ${updates.join(", ")} WHERE id = ?`,
            finalValues,
            (err2) => {
                if (err2) return err(res, err2.message, 500);
                db.query(
                    "SELECT id, username, email, created_at FROM users WHERE id = ?",
                    [req.params.id],
                    (err3, result) => {
                        if (err3) return err(res, err3.message, 500);
                        return ok(res, result[0], "User berhasil diupdate");
                    },
                );
            },
        );
    };
    
    if (password) {
        bcrypt.hash(password, 10, (err2, hashed) => {
            if (err2) return err(res, "Server error", 500);
            updates.push("password = ?");
            values.push(hashed);
            update([...values]);
        });
    } else {
        if (updates.length === 0) return err(res, "Tidak ada field yang diupdate");
        update([...values]);
    }
});

router.delete("/:id", auth, (req, res) => {
    db.query(
        "DELETE FROM users WHERE id = ?",
        [req.params.id],
        (err2, result) => {
            if (err2) return err(res, err2.message, 500);
            if (result.affectedRows === 0)
                return err(res, "User tidak ditemukan", 404);
            return ok(res, null, "User berhasil dihapus");
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

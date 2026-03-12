var express = require("express");
var router = express.Router();
var bcrypt = require("bcryptjs");
var db = require("../database/database");
var { generateToken, ok, err } = require("../helper/helper");

router.post("/register", (req, res) => {
    const { username, email, password } = req.body;
    
    if (!username || !email || !password)
        return err(res, "Semua field wajib diisi");
    if (username.length < 4) return err(res, "Username minimal 4 karakter");
    if (username.includes(" ")) return err(res, "Username tidak boleh ada spasi");
    if (password.length < 8) return err(res, "Password minimal 8 karakter");
    if (!/[0-9]/.test(password))
        return err(res, "Password harus mengandung angka");
    if (!/^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/.test(email))
        return err(res, "Format email tidak valid");
    
    db.query(
        "SELECT id FROM users WHERE username = ? OR email = ?",
        [username, email],
        (err2, result) => {
            if (err2) return err(res, err2.message, 500);
            if (result.length > 0)
                return err(res, "Username atau email sudah digunakan");
            
            bcrypt.hash(password, 10, (hashErr, hashed) => {
                if (hashErr) return err(res, "Server error", 500);
                
                const token = generateToken(32);
                
                db.query(
                    "INSERT INTO users (username, email, password, token) VALUES (?, ?, ?, ?)",
                    [username, email, hashed, token],
                    (insertErr, insertResult) => {
                        if (insertErr) return err(res, insertErr.message, 500);
                        return ok(
                            res,
                            {
                                id: insertResult.insertId,
                                username,
                                email,
                                token,
                            },
                            "Registrasi berhasil",
                            201,
                        );
                    },
                );
            });
        },
    );
});

router.post("/login", (req, res) => {
    const { email, password } = req.body;
    
    if (!email || !password) return err(res, "Email dan password wajib diisi");
    
    db.query("SELECT * FROM users WHERE email = ?", [email], (err2, result) => {
        if (err2) return err(res, err2.message, 500);
        if (result.length === 0) return err(res, "Email tidak ditemukan", 404);
        
        const user = result[0];
        bcrypt.compare(password, user.password, (compareErr, match) => {
            if (compareErr) return err(res, "Server error", 500);
            if (!match) return err(res, "Password salah", 401);
            
            const token = generateToken(32);
            
            db.query(
                "UPDATE users SET token = ? WHERE id = ?",
                [token, user.id],
                (updateErr) => {
                    if (updateErr) return err(res, updateErr.message, 500);
                    return ok(
                        res,
                        {
                            id: user.id,
                            username: user.username,
                            email: user.email,
                            token,
                            theme: user.theme,
                        },
                        "Login berhasil",
                    );
                },
            );
        });
    });
});

router.post("/logout", (req, res) => {
    const { token } = req.body;
    
    if (!token) return err(res, "Token wajib ada");
    
    db.query(
        "UPDATE users SET token = NULL WHERE token = ?",
        [token],
        (err2, result) => {
            if (err2) return err(res, err2.message, 500);
            if (result.affectedRows === 0) return err(res, "Token tidak valid", 404);
            return ok(res, null, "Logout berhasil");
        },
    );
});

module.exports = router;

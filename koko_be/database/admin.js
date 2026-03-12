var db = require('./database');
var bcrypt = require('bcryptjs');

const users = [
    { username: 'admin', email: 'admin@koko.com', password: 'admin123' },
];

users.forEach(({ username, email, password }) => {
    bcrypt.hash(password, 10, (err, hashed) => {
        if (err) return console.error(err);
        db.query(
            'INSERT IGNORE INTO users (username, email, password) VALUES (?, ?, ?)',
            [username, email, hashed],
            (err2) => {
                if (err2) console.error(err2);
            }
        );
    });
});
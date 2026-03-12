var db = require('../database/database');
var { err } = require('../helper/helper');

function Authentication(req, res, next) {
    const token = req.headers['token'];
    if (!token) return err(res, 'Token tidak ada', 401);

    db.query(
        'SELECT id, username FROM users WHERE token = ?',
        [token],
        (err2, result) => {
            if (err2) return err(res, err2.message, 500);
            if (result.length == 0) return err(res, "Token tidak Valid", 500);
            req.user = result[0];
            next();
        }
    )
}

module.exports = Authentication;
var { err } = require('../helper/helper');

function adminOnly(req, res, next) {
    if (req.user.username !== 'admin') {
        return err(res, 'Hanya admin yang bisa', 403);
    }
    next();
}

module.exports = adminOnly;
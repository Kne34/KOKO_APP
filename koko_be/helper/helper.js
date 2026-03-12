function generateToken(n) {
    var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    var token = "";
    for (var i = 0; i < n; i++) {
        token += chars[Math.floor(Math.random() * chars.length)];
    }
    return token;
}

function ok(res, data, msg, status) {
    return res
    .status(status || 200)
    .json({success: true, message: msg || "Success", data: data});
}

function err(res, msg, status) {
    return res
    .status(status || 400)
    .json({success: false, message: msg, data: null});
}

module.exports = { generateToken, ok, err };

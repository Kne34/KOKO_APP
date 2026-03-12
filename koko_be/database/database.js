const mySql = require('mysql2');
const connectiondb = mySql.createConnection(
    {
        host: 'localhost',
        user: 'root',
        password: '',
        database: 'koko_db'
    }
)

connectiondb.connect();
module.exports = connectiondb;
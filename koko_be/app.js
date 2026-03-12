var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var cors = require('cors');

var usersRouter = require('./routes/users');
var authRouter = require('./routes/auth');
var prodRouter = require('./routes/product');
var revRouter = require('./routes/reviews');

var app = express();

app.use(cors())
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/api/users', usersRouter);
app.use('/api/auth', authRouter);
app.use('/api/products', prodRouter);
app.use('/api/products/:id/reviews', revRouter);

module.exports = app;

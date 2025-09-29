// middleware/auth.js
const jwt = require('jsonwebtoken');
const db = require('../models');
const User = db.User;
require('dotenv').config();

module.exports = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'] || req.headers['Authorization'];
    if (!authHeader) return res.status(401).json({ error: 'No token provided' });

    const token = authHeader.split(' ')[1] || authHeader.split(' ')[0];
    if (!token) return res.status(401).json({ error: 'Token malformed' });

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findByPk(decoded.id);

    if (!user) return res.status(401).json({ error: 'User not found' });

    req.user = { id: user.id, email: user.email };
    next();
  } catch (err) {
    console.error('Auth error:', err);
    return res.status(401).json({ error: 'Unauthorized' });
  }
};

// middleware/auth.js
const jwt = require('jsonwebtoken');
require('dotenv').config();

module.exports = (req, res, next) => {
  const auth = req.header('Authorization') || req.header('authorization');
  if (!auth) return res.status(401).json({ error: 'No token provided' });

  const parts = auth.split(' ');
  const token = parts.length === 2 ? parts[1] : parts[0];

  jwt.verify(token, process.env.JWT_SECRET, (err, payload) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = { id: payload.id, email: payload.email }; // keep minimal
    next();
  });
};

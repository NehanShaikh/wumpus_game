// server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const db = require('./models');

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

// routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/games', require('./routes/games'));

console.log('DB_USER:', process.env.DB_USER);
console.log('DB_PASS:', process.env.DB_PASS);
console.log('DB_NAME:', process.env.DB_NAME);


// health
app.get('/api/health', (req, res) => res.json({ ok: true, ts: new Date() }));



const PORT = process.env.PORT || 5000;
(async () => {
  try {
    await db.sequelize.authenticate();
    console.log('DB connected');
    // Sync models (create tables if not exist). In production use migrations.
    // We already created tables manually
    await db.sequelize.authenticate();
    console.log("Database connected successfully.");
    // alter:false for safety; change to true for dev auto-alter
    console.log('Models synced');
    app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
  } catch (err) {
    console.error('Unable to start server:', err);
  }
})();

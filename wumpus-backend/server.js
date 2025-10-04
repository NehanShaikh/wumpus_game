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

// health check
app.get('/api/health', (req, res) => res.json({ ok: true, ts: new Date() }));

const PORT = process.env.PORT || 5000;

(async () => {
  try {
    await db.sequelize.authenticate();
    console.log('Database connected successfully.');

    // Auto-create tables in PostgreSQL if not exist
    await db.sequelize.sync({ alter: true });
    console.log('Models synced');

    app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
  } catch (err) {
    console.error('Unable to start server:', err);
  }
})();

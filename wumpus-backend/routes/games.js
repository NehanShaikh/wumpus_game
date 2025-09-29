// routes/games.js
const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');

const db = require('../models');
const SavedGame = db.SavedGame;
const authMiddleware = require('../middleware/auth');

// POST /api/games  -> create save
router.post('/', authMiddleware, [
  body('boardSize').isInt({ min: 2 }),
  body('gameState').notEmpty()
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const { name, boardSize, gameState, metadata } = req.body;
    const saved = await SavedGame.create({
      userId: req.user.id,
      name: name || 'Untitled',
      boardSize,
      gameState,
      metadata: metadata || {}
    });
    return res.json({ saved });
  } catch (err) {
    console.error('Create save error', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/games -> list user's saves
router.get('/', authMiddleware, async (req, res) => {
  try {
    const saves = await SavedGame.findAll({
      where: { userId: req.user.id },
      order: [['updated_at', 'DESC']],
    });
    return res.json({ saves });
  } catch (err) {
    console.error('List saves error', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/games/stats -> get summary of user's game stats
// GET /api/games/stats -> summary by difficulty
// GET /api/games/stats
router.get('/stats', authMiddleware, async (req, res) => {
  try {
    console.log('Fetching stats for user:', req.user.id);
    const saves = await SavedGame.findAll({ where: { userId: req.user.id } });
    console.log('Found saves:', saves.length);

    const summary = saves.reduce((acc, save) => {
      const diff = (save.difficulty || "Easy").toLowerCase();
      if (!acc[diff]) acc[diff] = { wins: 0, losses: 0, matches: 0 };
      acc[diff].wins += save.wins;
      acc[diff].losses += save.losses;
      acc[diff].matches += save.matches;
      return acc;
    }, {});

    return res.json({ summary });
  } catch (err) {
    console.error("Stats error", err);
    return res.status(500).json({ error: "Server error" });
  }
});

// GET /api/games/:id -> get one save
router.get('/:id', authMiddleware, async (req, res) => {
  const id = req.params.id;
  try {
    const save = await SavedGame.findOne({ where: { id, userId: req.user.id }});
    if (!save) return res.status(404).json({ error: 'Save not found' });
    return res.json({ save });
  } catch (err) {
    console.error('Get save error', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// PUT /api/games/:id -> update save
router.put('/:id', authMiddleware, [
  body('gameState').notEmpty(),
], async (req, res) => {
  const id = req.params.id;
  try {
    const save = await SavedGame.findOne({ where: { id, userId: req.user.id }});
    if (!save) return res.status(404).json({ error: 'Save not found' });

    const { name, boardSize, gameState, metadata } = req.body;
    save.name = name ?? save.name;
    save.boardSize = boardSize ?? save.boardSize;
    save.gameState = gameState ?? save.gameState;
    save.metadata = metadata ?? save.metadata;
    await save.save();
    return res.json({ save });
  } catch (err) {
    console.error('Update save error', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// DELETE /api/games/:id -> delete save
router.delete('/:id', authMiddleware, async (req, res) => {
  const id = req.params.id;
  try {
    const count = await SavedGame.destroy({ where: { id, userId: req.user.id }});
    if (!count) return res.status(404).json({ error: 'Save not found' });
    return res.json({ message: 'Deleted' });
  } catch (err) {
    console.error('Delete save error', err);
    return res.status(500).json({ error: 'Server error' });
  }
});





// POST /api/games/save
router.post('/save', authMiddleware, [
  body('boardSize').isInt({ min: 2 }),
  body('gameState').notEmpty(),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const { name, boardSize, gameState, difficulty, wins, losses, matches, metadata } = req.body;

    const saved = await SavedGame.create({
      userId: req.user.id,
      name: name || 'Untitled',
      boardSize,
      gameState,
      difficulty: difficulty || 'Easy',
      wins: wins || 0,
      losses: losses || 0,
      matches: matches || 1,
      metadata: metadata || {},
    });

    return res.json({ message: 'Game saved', saved });
  } catch (err) {
    console.error('Save game error', err);
    return res.status(500).json({ error: 'Server error' });
  }
});


module.exports = router;

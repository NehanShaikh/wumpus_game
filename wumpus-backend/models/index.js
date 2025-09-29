// models/index.js
const Sequelize = require('sequelize');
const sequelize = require('../config/db');

const db = {};
db.Sequelize = Sequelize;
db.sequelize = sequelize;

db.User = require('./user')(sequelize, Sequelize);
db.SavedGame = require('./savedGame')(sequelize, Sequelize);

// associations
db.User.hasMany(db.SavedGame, { foreignKey: 'userId', onDelete: 'CASCADE' });
db.SavedGame.belongsTo(db.User, { foreignKey: 'userId' });

module.exports = db;

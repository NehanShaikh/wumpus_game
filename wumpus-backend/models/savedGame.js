module.exports = (sequelize, DataTypes) => {
  const SavedGame = sequelize.define('SavedGame', {
    id: {
      type: DataTypes.INTEGER.UNSIGNED,
      autoIncrement: true,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.INTEGER.UNSIGNED,
      allowNull: false,
      field: 'user_id'
    },
    name: {
      type: DataTypes.STRING(120),
      defaultValue: 'Untitled',
    },
    boardSize: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: 'board_size'
    },
    gameState: {
      type: DataTypes.JSON,
      allowNull: false,
      field: 'game_state'
    },
    difficulty: {
      type: DataTypes.STRING(20),
      allowNull: false,
      defaultValue: 'Easy',
    },
    wins: {
      type: DataTypes.INTEGER.UNSIGNED,
      allowNull: false,
      defaultValue: 0,
    },
    losses: {
      type: DataTypes.INTEGER.UNSIGNED,
      allowNull: false,
      defaultValue: 0,
    },
    matches: {
      type: DataTypes.INTEGER.UNSIGNED,
      allowNull: false,
      defaultValue: 0,
    },
    metadata: {
      type: DataTypes.JSON,
      allowNull: true,
    },
    createdAt: {
      type: DataTypes.DATE,
      field: 'created_at',
    },
    updatedAt: {
      type: DataTypes.DATE,
      field: 'updated_at',
    },
  }, {
    tableName: 'saved_games',
    timestamps: true,
    underscored: true,
  });

  return SavedGame;
};

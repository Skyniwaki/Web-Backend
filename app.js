const express = require('express');
const cors = require('cors');
require('dotenv').config();

const {
  getGames,
  getCategories,
  getGameById
} = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());


// GET /api/games
app.get('/api/games', async (req, res) => {
  try {
    const { category, q, sort, editors_pick, limit } = req.query;

    const games = await getGames({
      category,
      q,
      sort,
      editors_pick,
      limit
    });

    res.json(games);
  } catch (error) {
    console.error('GET /api/games error:', error);

    res.status(500).json({
      error: 'ไม่สามารถโหลดข้อมูลเกมได้'
    });
  }
});


// GET /api/categories
app.get('/api/categories', async (req, res) => {
  try {
    const categories = await getCategories();

    res.json(categories);
  } catch (error) {
    console.error('GET /api/categories error:', error);

    res.status(500).json({
      error: 'ไม่สามารถโหลดหมวดหมู่ได้'
    });
  }
});


// GET /api/games/:id
app.get('/api/games/:id', async (req, res) => {
  try {
    const game = await getGameById(req.params.id);

    if (!game) {
      return res.status(404).json({
        error: 'ไม่พบเกมที่ต้องการ'
      });
    }

    res.json(game);
  } catch (error) {
    console.error('GET /api/games/:id error:', error);

    res.status(500).json({
      error: 'ไม่สามารถโหลดข้อมูลเกมได้'
    });
  }
});


// Reviews
app.get('/reviews', (req, res) => {
  res.json([]);
});


// Start server
app.listen(PORT, () => {
  console.log(`Server กำลังทำงานที่ http://localhost:${PORT}`);
});
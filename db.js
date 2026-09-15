const supabase = require('./supabase');

// GET games พร้อม filter/search/sort/limit
async function getGames({ category, q, sort, editors_pick, limit }) {
  let query = supabase
    .from('games')
    .select('*');

  // Filter category
  if (category) {
    query = query.ilike('category', `%${category}%`);
  }

  // Search
  if (q) {
    query = query.or(
      `title.ilike.%${q}%,category.ilike.%${q}%,description.ilike.%${q}%`
    );
  }

  // Editor's pick
  if (editors_pick === '1') {
    query = query.eq('editors_pick', 1);
  }

  // Sort
  switch (sort) {
    case 'score_desc':
      query = query.order('score', { ascending: false });
      break;

    case 'score_asc':
      query = query.order('score', { ascending: true });
      break;

    case 'title_asc':
      query = query.order('title', { ascending: true });
      break;

    case 'title_desc':
      query = query.order('title', { ascending: false });
      break;

    case 'newest':
      query = query.order('id', { ascending: false });
      break;

    default:
      query = query.order('id', { ascending: true });
      break;
  }

  // Limit
  const limitNum = Number(limit);

  if (limit && Number.isInteger(limitNum) && limitNum > 0) {
    query = query.limit(limitNum);
  }

  const { data, error } = await query;

  if (error) {
    throw error;
  }

  return data;
}

// GET categories + จำนวนเกมในแต่ละ category
async function getCategories() {
  const { data, error } = await supabase
    .from('games')
    .select('category');

  if (error) {
    throw error;
  }

  const counts = {};

  for (const game of data) {
    counts[game.category] = (counts[game.category] || 0) + 1;
  }

  return Object.entries(counts)
    .map(([category, count]) => ({
      category,
      count
    }))
    .sort((a, b) => b.count - a.count);
}

// GET game ตาม id
async function getGameById(id) {
  const { data, error } = await supabase
    .from('games')
    .select('*')
    .eq('id', id)
    .maybeSingle();

  if (error) {
    throw error;
  }

  return data;
}

module.exports = {
  getGames,
  getCategories,
  getGameById
};
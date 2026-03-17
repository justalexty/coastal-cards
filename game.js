// === Coastal Cards — Full Game Engine ===
// Vanilla JS/DOM PWA game engine

(function() {
'use strict';

// ============================================================
// DATA MODULE — All game data, including generated minor arcana
// ============================================================
const DATA = {
  tarotDeck: null,
  economy: null,
  holidays: null,
  lunar: null,
  achievements: null,
  brooms: null,
  notifications: null,
  broomLore: null,
  broomEmotions: null,
  premiumEconomy: null,
  dialogueExamples: null,
};

// Generate the full 56 minor arcana since data file only has partial
function generateMinorArcana() {
  const suits = {
    wands: { element: 'Fire', theme: 'creativity, action, passion' },
    cups: { element: 'Water', theme: 'emotions, relationships, intuition' },
    swords: { element: 'Air', theme: 'thoughts, communication, conflict' },
    pentacles: { element: 'Earth', theme: 'material, career, money' },
  };
  const ranks = [
    { rank: 'Ace', kw: ['new beginnings','potential','opportunity'], upright: 'A burst of new energy', reversed: 'Missed opportunity, delays' },
    { rank: 'Two', kw: ['balance','partnership','decisions'], upright: 'Partnership and balance', reversed: 'Imbalance, indecision' },
    { rank: 'Three', kw: ['growth','creativity','collaboration'], upright: 'Growth and expansion', reversed: 'Lack of growth, setbacks' },
    { rank: 'Four', kw: ['stability','structure','rest'], upright: 'Stability and foundation', reversed: 'Restlessness, instability' },
    { rank: 'Five', kw: ['conflict','loss','challenge'], upright: 'Challenge and adversity', reversed: 'Recovery, resolution' },
    { rank: 'Six', kw: ['harmony','nostalgia','generosity'], upright: 'Harmony and giving', reversed: 'Clinging to the past' },
    { rank: 'Seven', kw: ['reflection','assessment','patience'], upright: 'Reflection and perseverance', reversed: 'Impatience, giving up' },
    { rank: 'Eight', kw: ['movement','speed','progress'], upright: 'Swift action and progress', reversed: 'Stagnation, rushing' },
    { rank: 'Nine', kw: ['fulfillment','resilience','near completion'], upright: 'Near fulfillment', reversed: 'Anxiety, incompletion' },
    { rank: 'Ten', kw: ['completion','legacy','culmination'], upright: 'Completion and legacy', reversed: 'Burden, unfinished business' },
    { rank: 'Page', kw: ['curiosity','messages','student'], upright: 'Curiosity and new messages', reversed: 'Immaturity, lack of direction' },
    { rank: 'Knight', kw: ['action','adventure','energy'], upright: 'Pursuit and energy', reversed: 'Recklessness, haste' },
    { rank: 'Queen', kw: ['nurturing','mastery','intuition'], upright: 'Mastery and compassion', reversed: 'Insecurity, neglect' },
    { rank: 'King', kw: ['authority','leadership','control'], upright: 'Leadership and wisdom', reversed: 'Tyranny, rigidity' },
  ];
  const suitSpecific = {
    wands: { uprightMod: 'with passion and creativity', reversedMod: 'through blocked creativity' },
    cups: { uprightMod: 'through emotional wisdom', reversedMod: 'with emotional confusion' },
    swords: { uprightMod: 'with mental clarity', reversedMod: 'through mental struggle' },
    pentacles: { uprightMod: 'in material matters', reversedMod: 'with financial worry' },
  };
  const cards = [];
  for (const [suit, info] of Object.entries(suits)) {
    const mod = suitSpecific[suit];
    for (const r of ranks) {
      const suitName = suit.charAt(0).toUpperCase() + suit.slice(1);
      cards.push({
        name: `${r.rank} of ${suitName}`,
        suit: suit,
        element: info.element,
        keywords: r.kw,
        upright_meaning: `${r.upright} ${mod.uprightMod}`,
        reversed_meaning: `${r.reversed} ${mod.reversedMod}`,
        visual_description: `${r.rank} figure surrounded by ${suit} symbolism`,
      });
    }
  }
  return cards;
}

async function loadAllData() {
  const files = {
    tarotDeck: 'data/tarot_deck.json',
    economy: 'data/economy.json',
    holidays: 'data/holiday_effects.json',
    lunar: 'data/lunar_effects.json',
    achievements: 'data/achievements.json',
    brooms: 'data/complete_broom_catalog.json',
    notifications: 'data/croneslist_notifications.json',
    broomLore: 'data/broom_lore.json',
    broomEmotions: 'data/broom_selling_emotions.json',
    premiumEconomy: 'data/premium_broom_economy.json',
    dialogueExamples: 'data/dialogue_examples.json',
  };
  const promises = Object.entries(files).map(async ([key, path]) => {
    try {
      const r = await fetch(path);
      DATA[key] = await r.json();
    } catch(e) {
      console.warn(`Failed to load ${path}:`, e);
      DATA[key] = {};
    }
  });
  await Promise.all(promises);
}

// Build the full 78-card deck
function buildFullDeck() {
  const major = (DATA.tarotDeck.major_arcana || []).map(c => ({
    name: c.name,
    suit: 'major',
    element: c.element,
    keywords: c.keywords || [],
    upright_meaning: c.upright_meaning,
    reversed_meaning: c.reversed_meaning,
    visual_description: c.visual_description || '',
    number: c.number,
  }));
  const minor = generateMinorArcana();
  return [...major, ...minor];
}

// ============================================================
// GAME STATE
// ============================================================
const SAVE_KEY = 'coastal_cards_save';

const DEFAULT_STATE = {
  // Character
  name: '',
  pronouns: 'she',
  customPronouns: null,
  bodyType: 'feminine',
  skinTone: 'medium',
  hairStyle: 'long_straight',
  hairColor: 'brown',
  outfit: 'traditional',
  accessory: 'none',
  // Game progress
  day: 1, // Day 1 = March 1
  timeOfDay: 0, // 0=morning, 1=afternoon, 2=evening, 3=night
  money: 25,
  energy: 100,
  reputation: 0, // 0-100
  location: 'apartment',
  // Permits
  permits: { market_square: false, university_district: false },
  // Broom
  broom: null,
  broomHistory: [],
  // Readings
  totalReadings: 0,
  todayReadings: 0,
  // Calendar
  startYear: 2026,
  // Achievements
  unlockedAchievements: [],
  // Statistics
  stats: {
    days_without_broom: 0,
    readings_completed: 0,
    money_earned: 0,
    money_spent: 0,
    ramen_dinners: 0,
    perfect_readings: 0,
    brooms_purchased: 0,
    brooms_sold: 0,
    locations_visited: [],
  },
  // Messages
  messages: [],
  // Croneslist
  activeListings: [],
  lastListingRefresh: 0,
  // Save metadata
  lastSaved: null,
  openingComplete: false,
};

let state = {};
let fullDeck = [];

function deepClone(obj) { return JSON.parse(JSON.stringify(obj)); }

function newGame() {
  state = deepClone(DEFAULT_STATE);
}

function saveGame() {
  state.lastSaved = Date.now();
  localStorage.setItem(SAVE_KEY, JSON.stringify(state));
  return true;
}

function loadGame() {
  const raw = localStorage.getItem(SAVE_KEY);
  if (!raw) return false;
  try {
    const saved = JSON.parse(raw);
    state = { ...deepClone(DEFAULT_STATE), ...saved };
    return true;
  } catch(e) { return false; }
}

function hasSave() { return !!localStorage.getItem(SAVE_KEY); }

// ============================================================
// CALENDAR & MOON
// ============================================================
const MONTH_NAMES = ['January','February','March','April','May','June','July','August','September','October','November','December'];
const MONTH_SHORT = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const MONTH_DAYS = [31,28,31,30,31,30,31,31,30,31,30,31];

function getDateFromDay(day) {
  // Day 1 = March 1 of startYear
  let m = 2; // March = index 2
  let d = day;
  let y = state.startYear;
  while (d > MONTH_DAYS[m]) {
    d -= MONTH_DAYS[m];
    m++;
    if (m >= 12) { m = 0; y++; }
  }
  return { month: m, day: d, year: y, monthName: MONTH_NAMES[m], monthShort: MONTH_SHORT[m] };
}

function formatDate(day) {
  const dt = getDateFromDay(day || state.day);
  return `${dt.monthShort} ${dt.day}`;
}

function isRentDay() {
  const dt = getDateFromDay(state.day);
  return dt.day === 1 && state.day > 1;
}

function daysUntilRent() {
  const dt = getDateFromDay(state.day);
  const daysInMonth = MONTH_DAYS[dt.month];
  return daysInMonth - dt.day + 1;
}

// Moon phase: 29.5 day cycle, new moon on March 1
const MOON_CYCLE = 29.5;
const MOON_PHASES = [
  { name: 'New Moon', symbol: '🌑', key: 'new_moon' },
  { name: 'Waxing Crescent', symbol: '🌒', key: 'waxing_crescent' },
  { name: 'First Quarter', symbol: '🌓', key: 'first_quarter' },
  { name: 'Waxing Gibbous', symbol: '🌔', key: 'waxing_gibbous' },
  { name: 'Full Moon', symbol: '🌕', key: 'full_moon' },
  { name: 'Waning Gibbous', symbol: '🌖', key: 'waning_gibbous' },
  { name: 'Last Quarter', symbol: '🌗', key: 'last_quarter' },
  { name: 'Waning Crescent', symbol: '🌘', key: 'waning_crescent' },
];

function getMoonPhase(day) {
  const pos = ((day - 1) % MOON_CYCLE) / MOON_CYCLE;
  const idx = Math.floor(pos * 8) % 8;
  return MOON_PHASES[idx];
}

function getMoonBonus() {
  const phase = getMoonPhase(state.day);
  const lunarData = DATA.lunar?.moon_phases?.[phase.key];
  if (!lunarData) return 1.0;
  return 1.0 + (lunarData.effects?.divination_bonus || lunarData.effects?.new_client_bonus || 0);
}

// Holidays
function getHoliday(day) {
  const dt = getDateFromDay(day);
  const holidays = DATA.holidays || {};
  // Check date-based holidays
  if (dt.month === 2 && dt.day === 20) return holidays.spring_equinox; // ~March 20
  if (dt.month === 5 && dt.day === 21) return holidays.summer_solstice;
  if (dt.month === 8 && dt.day === 22) return holidays.autumn_equinox;
  if (dt.month === 11 && dt.day === 21) return holidays.winter_solstice;
  if (dt.month === 9 && dt.day === 31) return holidays.samhain; // Oct 31
  if (dt.month === 4 && dt.day === 1) return holidays.beltane; // May 1
  // Lunar new year: late Jan/early Feb — simplified to Feb 10
  if (dt.month === 1 && dt.day >= 10 && dt.day <= 12) return holidays.lunar_new_year;
  return null;
}

function getHolidayBonus() {
  const h = getHoliday(state.day);
  if (!h) return 1.0;
  return 1.0 + (h.effects?.tip_multiplier ? h.effects.tip_multiplier - 1 : h.effects?.reading_accuracy_bonus || 0);
}

// Time of day
const TIME_NAMES = ['Morning', 'Afternoon', 'Evening', 'Night'];
const TIME_EMOJI = ['🌅', '☀️', '🌇', '🌙'];

function getTimeName() { return TIME_NAMES[state.timeOfDay]; }

function advanceTime() {
  state.timeOfDay++;
  if (state.timeOfDay >= 4) {
    state.timeOfDay = 0;
    advanceDay();
  }
  updateHUD();
}

function advanceDay() {
  state.day++;
  state.todayReadings = 0;
  // Daily expenses
  const foodCost = DATA.economy?.daily_expenses?.food || 8;
  state.money -= foodCost;
  state.stats.money_spent += foodCost;
  if (!state.broom) state.stats.days_without_broom++;
  // Energy partial recovery overnight
  state.energy = Math.min(100, state.energy + 30);
  // Check rent day
  if (isRentDay()) {
    handleRent();
  }
  // Check achievements
  checkAchievements();
  // Refresh croneslist
  refreshCroneslist();
  // Random messages
  maybeAddMessage();
}

// ============================================================
// LOCATIONS
// ============================================================
const LOCATIONS = {
  apartment: { name: 'Studio Apartment', emoji: '🏠', desc: 'Your tiny home. A bed, kitchenette, and not much else. But it\'s yours.', free: true, canRead: false, actions: ['rest', 'mirror'] },
  boardwalk: { name: 'Boardwalk', emoji: '🌊', desc: 'Tourists strolling along the ocean. Great for quick readings — no permit needed!', free: true, canRead: true, clientType: 'tourist' },
  market: { name: 'Market Square', emoji: '🏪', desc: 'Bustling local market. Regular clients who spread the word. Requires a permit.', free: false, permit: 'market_square', canRead: true, clientType: 'local' },
  university: { name: 'University District', emoji: '🎓', desc: 'Students with deep questions and decent tips. Requires a permit.', free: false, permit: 'university_district', canRead: true, clientType: 'student' },
  harbor: { name: 'Harbor', emoji: '⚓', desc: 'Sailors and merchants seeking guidance before voyages.', free: true, canRead: true, clientType: 'sailor' },
  park: { name: 'Park', emoji: '🌳', desc: 'Families and couples enjoying the greenery. Relationship readings are popular here.', free: true, canRead: true, clientType: 'family' },
};

// ============================================================
// ECONOMY
// ============================================================
function calculateReadingIncome() {
  const eco = DATA.economy?.reading_prices?.three_card || { base: 15, reputation_multiplier: 1.0 };
  const base = eco.base;
  const repLevel = state.reputation / 20; // 0-5
  const repBonus = repLevel * eco.reputation_multiplier;
  const moonBonus = getMoonBonus();
  const holidayBonus = getHolidayBonus();
  const loc = LOCATIONS[state.location];
  const touristMarkup = loc?.clientType === 'tourist' ? (eco.tourist_markup || 5) : 0;
  return Math.round((base + repBonus + touristMarkup) * moonBonus * holidayBonus);
}

function handleRent() {
  const rent = DATA.economy?.monthly_rent || 700;
  if (state.money >= rent) {
    state.money -= rent;
    state.stats.money_spent += rent;
    showRentWarning(`Rent day! $${rent} paid. You have $${state.money} remaining.`, false);
    checkAchievement('made_rent');
  } else {
    const deficit = rent - state.money;
    showRentWarning(`RENT IS DUE! You need $${rent} but only have $${state.money}. You're $${deficit} short! Late fees will accumulate.`, true);
    // Apply late fee
    state.money -= rent;
    state.stats.money_spent += rent;
  }
}

// ============================================================
// PRONOUNS
// ============================================================
function pronoun(type) {
  const p = state.pronouns;
  if (p === 'custom' && state.customPronouns) {
    const cp = state.customPronouns;
    if (type === 'subj') return cp.subject || 'they';
    if (type === 'obj') return cp.object || 'them';
    if (type === 'poss') return cp.possessive || 'their';
    return cp.subject || 'they';
  }
  const map = {
    she: { subj: 'she', obj: 'her', poss: 'her', Subj: 'She' },
    he: { subj: 'he', obj: 'him', poss: 'his', Subj: 'He' },
    they: { subj: 'they', obj: 'them', poss: 'their', Subj: 'They' },
  };
  const m = map[p] || map.they;
  return m[type] || m.subj;
}

// ============================================================
// SCREENS & UI
// ============================================================
function $(sel) { return document.querySelector(sel); }
function $$(sel) { return document.querySelectorAll(sel); }

function showScreen(id) {
  $$('.screen').forEach(s => { s.classList.remove('active'); });
  const el = $(`#screen-${id}`);
  if (el) {
    el.classList.add('active');
    el.style.display = 'flex';
    // Fade in
    requestAnimationFrame(() => { el.style.opacity = '1'; });
  }
}

function showOverlay(id) {
  const el = $(`#overlay-${id}`);
  if (el) el.style.display = 'flex';
}

function hideOverlay(id) {
  const el = $(`#overlay-${id}`);
  if (el) el.style.display = 'none';
}

function showToast(msg) {
  const t = $('#toast');
  t.textContent = msg;
  t.style.display = 'block';
  t.style.animation = 'none';
  requestAnimationFrame(() => {
    t.style.animation = '';
  });
  setTimeout(() => { t.style.display = 'none'; }, 3000);
}

function showAchievement(name, desc) {
  const popup = $('#achievement-popup');
  popup.querySelector('.achievement-name').textContent = name;
  popup.querySelector('.achievement-desc').textContent = desc;
  popup.style.display = 'block';
  popup.style.animation = 'none';
  requestAnimationFrame(() => { popup.style.animation = ''; });
  setTimeout(() => { popup.style.display = 'none'; }, 4000);
}

function showRentWarning(text, urgent) {
  const el = $('#rent-warning');
  $('#rent-warning-text').textContent = text;
  el.style.display = 'flex';
  if (urgent) {
    el.querySelector('.rent-warning-inner').style.borderColor = 'var(--danger)';
  }
}

// ============================================================
// PARTICLES
// ============================================================
function initParticles() {
  const container = $('#particles');
  const colors = ['rgba(200,162,200,', 'rgba(212,165,116,', 'rgba(94,196,182,', 'rgba(255,215,0,'];
  for (let i = 0; i < 20; i++) {
    const p = document.createElement('div');
    p.className = 'particle';
    const color = colors[Math.floor(Math.random() * colors.length)];
    const size = 2 + Math.random() * 4;
    p.style.cssText = `
      left:${Math.random()*100}%;
      width:${size}px; height:${size}px;
      background:${color}0.6);
      animation-duration:${8+Math.random()*12}s;
      animation-delay:${Math.random()*10}s;
    `;
    container.appendChild(p);
  }
}

// ============================================================
// TITLE SCREEN
// ============================================================
function initTitle() {
  if (hasSave()) {
    $('#btn-continue').style.display = 'inline-block';
  }
  $('#btn-new-game').addEventListener('click', () => {
    newGame();
    fullDeck = buildFullDeck();
    showScreen('opening');
    startOpening();
  });
  $('#btn-continue').addEventListener('click', () => {
    if (loadGame()) {
      fullDeck = buildFullDeck();
      if (state.openingComplete) {
        showScreen('game');
        renderGame();
      } else {
        showScreen('opening');
        startOpening();
      }
    }
  });
}

// ============================================================
// CHARACTER CREATION
// ============================================================
function initCreation() {
  let page = 0;
  const pages = $$('.creation-page');
  const dots = $('#page-dots');
  const prevBtn = $('#btn-prev-page');
  const nextBtn = $('#btn-next-page');

  function showPage(p) {
    pages.forEach((pg, i) => {
      pg.classList.toggle('active', i === p);
    });
    prevBtn.disabled = p === 0;
    nextBtn.textContent = p === 2 ? 'Begin ✧' : 'Next →';
    const dotStr = Array.from({length:3}, (_,i) => i === p ? '●' : '○').join(' ');
    dots.textContent = dotStr;
  }

  prevBtn.addEventListener('click', () => { if (page > 0) { page--; showPage(page); } });
  nextBtn.addEventListener('click', () => {
    if (page < 2) { page++; showPage(page); }
    else {
      // Validate & start game
      const name = $('#input-name').value.trim();
      if (!name) { showToast('Please enter your witch name!'); return; }
      state.name = name;
      state.hairStyle = $('#sel-hairstyle').value;
      state.hairColor = $('#sel-haircolor').value;
      if (state.pronouns === 'custom') {
        state.customPronouns = {
          subject: $('#custom-subject').value || 'they',
          object: $('#custom-object').value || 'them',
          possessive: $('#custom-possessive').value || 'their',
        };
      }
      fullDeck = buildFullDeck();
      showScreen('opening');
      startOpening();
    }
  });

  // Pronoun buttons
  $$('.pronoun-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      $$('.pronoun-btn').forEach(b => b.classList.remove('selected'));
      btn.classList.add('selected');
      state.pronouns = btn.dataset.pronouns;
      $('#custom-pronouns').style.display = state.pronouns === 'custom' ? 'flex' : 'none';
    });
  });

  // Option buttons (appearance, outfit, etc.)
  $$('.opt-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const field = btn.dataset.field;
      if (!field) return;
      // Deselect siblings
      btn.parentElement.querySelectorAll('.opt-btn').forEach(b => b.classList.remove('selected'));
      btn.classList.add('selected');
      state[field] = btn.dataset.val;
    });
  });
}

// ============================================================
// OPENING SEQUENCE
// ============================================================
const OPENING_LINES = [
  "The coastal train rattles along the cliffside tracks...",
  "Through the salt-streaked window, the ocean stretches out to the horizon.",
  "Pastel buildings tumble down to a harbor glittering in the afternoon sun.",
  "You clutch your worn suitcase — everything you own fits inside it.",
  "Your old apprentice broom broke last week. The train was all you could afford.",
  "But you've got your tarot deck, your compact mirror, and $25 to your name.",
  "You pull out your compact and take one last look before arriving...",
  "__OPEN_COMPACT__",
  "The conductor calls out: \"Seaglass Harbor! Last stop!\"",
  "You step onto the platform. The ocean breeze carries the scent of salt and possibility.",
  "This is it. Your new life as a professional tarot reader starts now.",
];

let openingLine = 0;
let openingCharIdx = 0;
let openingTimer = null;

function startOpening() {
  openingLine = 0;
  openingCharIdx = 0;
  $('#opening-text').textContent = '';
  typeNextChar();
}

let openingPaused = false;

function typeNextChar() {
  if (openingLine >= OPENING_LINES.length) {
    state.openingComplete = true;
    saveGame();
    setTimeout(() => {
      showScreen('game');
      renderGame();
      showToast('Welcome to Seaglass! 🔮');
      addMessage('WitchNet', 'Welcome to Seaglass! The Boardwalk is free to set up — no permit needed.');
    }, 500);
    return;
  }
  const line = OPENING_LINES[openingLine];
  // Special: open compact mirror mid-opening
  if (line === '__OPEN_COMPACT__') {
    openingPaused = true;
    showOverlay('compact');
    syncStylingTab();
    switchCompactTab('styling');
    // Override close to resume opening
    const closeBtn = $('#btn-close-compact');
    const origClose = closeBtn.onclick;
    closeBtn.onclick = () => {
      hideOverlay('compact');
      closeBtn.onclick = origClose;
      openingPaused = false;
      openingLine++;
      openingCharIdx = 0;
      typeNextChar();
    };
    return;
  }
  if (openingCharIdx <= line.length) {
    $('#opening-text').textContent = line.substring(0, openingCharIdx);
    openingCharIdx++;
    openingTimer = setTimeout(typeNextChar, 30);
  }
}

function advanceOpening() {
  if (openingPaused) return;
  if (openingTimer) clearTimeout(openingTimer);
  const line = OPENING_LINES[openingLine];
  if (line === '__OPEN_COMPACT__') { typeNextChar(); return; }
  if (openingCharIdx < line.length) {
    openingCharIdx = line.length;
    $('#opening-text').textContent = line;
  } else {
    openingLine++;
    openingCharIdx = 0;
    if (openingLine < OPENING_LINES.length) {
      $('#opening-text').textContent = '';
      typeNextChar();
    } else {
      typeNextChar(); // Will trigger completion
    }
  }
}

// ============================================================
// MAIN GAME / HUD
// ============================================================
function updateHUD() {
  $('#hud-date').textContent = formatDate();
  const moon = getMoonPhase(state.day);
  $('#hud-moon').textContent = moon.symbol;
  $('#hud-moon').title = moon.name;
  const loc = LOCATIONS[state.location];
  $('#hud-location').textContent = loc ? loc.name : 'Unknown';
  $('#hud-money').textContent = `$${state.money}`;
  $('#hud-energy').textContent = `⚡${state.energy}`;
  // Holiday
  const holiday = getHoliday(state.day);
  const hEl = $('#hud-holiday');
  if (holiday) {
    hEl.textContent = `✨ ${holiday.name}`;
    hEl.style.display = 'inline';
  } else {
    hEl.style.display = 'none';
  }
}

function renderGame() {
  updateHUD();
  renderLocation();
}

// ============================================================
// INTERACTIVE SCENE ENGINE
// ============================================================
const TILE = 16;
const SCENE_W = 20; // tiles wide
const SCENE_H = 12; // tiles tall
const SCENE_PX = SCENE_W * TILE; // 320
const SCENE_PH = SCENE_H * TILE; // 192
const SCENE_SHEETS = {};
let sceneLoop = null;
let sceneNPCs = [];
let playerPos = { x: 5, y: 6 }; // tile coords
let playerTarget = null; // {x,y} tile destination
let playerDir = 2; // 0=up,1=left,2=down,3=right (sprite row)
let playerFrame = 0;
let frameCount = 0;
let tablePos = null; // {x,y} where player placed table
let tableSetUp = false;

function loadSheet(name) {
  if (SCENE_SHEETS[name]) return Promise.resolve(SCENE_SHEETS[name]);
  return new Promise((res, rej) => {
    const img = new Image();
    img.onload = () => { SCENE_SHEETS[name] = img; res(img); };
    img.onerror = rej;
    img.src = `assets/scenes/${name}.png`;
  });
}

function spr(ctx, sheet, sx, sy, dx, dy, sw, sh) {
  sw = sw || TILE; sh = sh || TILE;
  ctx.drawImage(sheet, sx, sy, sw, sh, dx, dy, sw, sh);
}

const TIME_TINTS = [
  null,
  null,
  'rgba(255,140,60,0.15)',
  'rgba(20,10,50,0.45)',
];

// Location scene data: walkable tiles, table spots, NPC spawn/paths, solid objects
const SCENE_DATA = {
  apartment: {
    ground: '#b8956a', wall: '#d4c4a8',
    solids: [[0,0,3,3],[17,0,3,3],[8,0,4,2]], // furniture blocks
    tableSpots: [], // can't read at home
    npcPaths: [],
    playerStart: {x:10,y:8},
    indoor: true,
    draw: 'apartment',
  },
  boardwalk: {
    ground: '#e8d5a8',
    solids: [[0,0,20,2],[0,10,20,2]], // top wall + ocean
    tableSpots: [{x:5,y:5,label:'By the stalls'},{x:14,y:5,label:'Ocean view'}],
    npcPaths: [
      {spawn:{x:-1,y:6},dest:{x:21,y:6}},
      {spawn:{x:21,y:7},dest:{x:-1,y:7}},
      {spawn:{x:-1,y:4},dest:{x:21,y:4}},
    ],
    playerStart: {x:10,y:6},
    draw: 'boardwalk',
  },
  market: {
    ground: '#a09080',
    solids: [[0,0,20,2],[2,3,2,2],[8,3,2,2],[15,3,2,2]], // wall + stalls
    tableSpots: [{x:5,y:6,label:'Between stalls'},{x:12,y:8,label:'Center square'}],
    npcPaths: [
      {spawn:{x:-1,y:5},dest:{x:21,y:5}},
      {spawn:{x:21,y:7},dest:{x:-1,y:7}},
      {spawn:{x:10,y:-1},dest:{x:10,y:12}},
    ],
    playerStart: {x:10,y:7},
    draw: 'market',
  },
  university: {
    ground: '#6aaa5a',
    solids: [[0,0,20,3],[0,0,2,12],[18,0,2,12]], // building + tree walls
    tableSpots: [{x:7,y:6,label:'Campus lawn'},{x:13,y:8,label:'Near the path'}],
    npcPaths: [
      {spawn:{x:10,y:-1},dest:{x:10,y:12}},
      {spawn:{x:10,y:12},dest:{x:10,y:-1}},
      {spawn:{x:-1,y:7},dest:{x:21,y:7}},
    ],
    playerStart: {x:10,y:7},
    draw: 'university',
  },
  harbor: {
    ground: '#808080',
    solids: [[0,0,20,2],[0,9,20,3]], // dock edge + water
    tableSpots: [{x:4,y:5,label:'Near the crates'},{x:15,y:5,label:'Dock end'}],
    npcPaths: [
      {spawn:{x:-1,y:4},dest:{x:21,y:4}},
      {spawn:{x:21,y:6},dest:{x:-1,y:6}},
    ],
    playerStart: {x:10,y:5},
    draw: 'harbor',
  },
  park: {
    ground: '#5a9a4a',
    solids: [[1,1,2,2],[12,2,2,2],[17,1,2,2],[6,9,2,2]], // trees
    tableSpots: [{x:8,y:5,label:'By the bench'},{x:15,y:7,label:'Under the tree'}],
    npcPaths: [
      {spawn:{x:-1,y:5},dest:{x:21,y:5}},
      {spawn:{x:21,y:8},dest:{x:-1,y:8}},
      {spawn:{x:5,y:-1},dest:{x:15,y:12}},
    ],
    playerStart: {x:10,y:6},
    draw: 'park',
  },
};

// NPC class
class NPC {
  constructor(path, speed) {
    this.x = path.spawn.x * TILE;
    this.y = path.spawn.y * TILE;
    this.destX = path.dest.x * TILE;
    this.destY = path.dest.y * TILE;
    this.speed = speed || (0.3 + Math.random() * 0.3);
    this.dir = 2; // sprite row
    this.frame = 0;
    this.state = 'walking'; // walking | approaching | reading | leaving | gone
    this.waitTimer = 0;
    this.skinV = 'v' + String(Math.floor(Math.random() * 6) * 2).padStart(2, '0');
    this.hairV = 'v' + String(Math.floor(Math.random() * 14)).padStart(2, '0');
    this.hairStyle = Math.random() < 0.5 ? 'bob1' : 'dap1';
    this.outfitCode = ['fstr', 'pfpn'][Math.floor(Math.random() * 2)];
    this.outfitV = 'v' + String(Math.floor(Math.random() * 5) + 1).padStart(2, '0');
    this.body = Math.random() < 0.5 ? 'p1' : 'pONE1';
    // Direction based on movement
    const dx = this.destX - this.x, dy = this.destY - this.y;
    if (Math.abs(dx) > Math.abs(dy)) this.dir = dx > 0 ? 3 : 1;
    else this.dir = dy > 0 ? 2 : 0;
  }

  update(dt) {
    if (this.state === 'gone') return;

    if (this.state === 'walking') {
      const dx = this.destX - this.x, dy = this.destY - this.y;
      const dist = Math.sqrt(dx * dx + dy * dy);
      if (dist < 2) { this.state = 'gone'; return; }

      // Check if near player table — chance to stop
      if (tableSetUp && tablePos) {
        const tx = tablePos.x * TILE, ty = tablePos.y * TILE;
        const tdist = Math.sqrt((this.x - tx) ** 2 + (this.y - ty) ** 2);
        if (tdist < TILE * 2.5 && this.state === 'walking') {
          const stopChance = 0.15 + (state.reputation / 100) * 0.45; // 15-60%
          if (Math.random() < stopChance) {
            this.state = 'approaching';
            this.destX = tx + TILE;
            this.destY = ty;
            return;
          }
        }
      }

      const mx = (dx / dist) * this.speed;
      const my = (dy / dist) * this.speed;
      this.x += mx;
      this.y += my;
      this.frame += 0.08;

    } else if (this.state === 'approaching') {
      const dx = this.destX - this.x, dy = this.destY - this.y;
      const dist = Math.sqrt(dx * dx + dy * dy);
      if (dist < 2) {
        this.state = 'reading';
        this.waitTimer = 120 + Math.random() * 180; // wait 2-5 sec
        this.dir = 1; // face left toward table
        // Show reading prompt!
        if (!$('#scene-reading-prompt')) {
          const prompt = document.createElement('div');
          prompt.id = 'scene-reading-prompt';
          prompt.className = 'scene-prompt';
          prompt.innerHTML = `<button class="magic-btn" onclick="Game.startReading()">🃏 Do Reading</button>`;
          $('#location-scene').appendChild(prompt);
        }
        return;
      }
      const mx = (dx / dist) * this.speed * 0.7;
      const my = (dy / dist) * this.speed * 0.7;
      this.x += mx;
      this.y += my;
      this.frame += 0.06;

    } else if (this.state === 'reading') {
      this.waitTimer--;
      if (this.waitTimer <= 0) {
        this.state = 'leaving';
        this.destX = (Math.random() < 0.5 ? -2 : 22) * TILE;
        this.destY = this.y;
        const el = $('#scene-reading-prompt');
        if (el) el.remove();
      }

    } else if (this.state === 'leaving') {
      const dx = this.destX - this.x;
      this.x += Math.sign(dx) * this.speed;
      this.dir = dx > 0 ? 3 : 1;
      this.frame += 0.08;
      if (Math.abs(this.destX - this.x) < 2) this.state = 'gone';
    }
  }

  getSpriteFiles() {
    return [
      `char_a_${this.body}_0bas_humn_${this.skinV}.png`,
      `char_a_${this.body}_1out_${this.outfitCode}_${this.outfitV}.png`,
      `char_a_${this.body}_4har_${this.hairStyle}_${this.hairV}.png`,
    ];
  }
}

// Spawn NPCs for current location
function spawnNPCs() {
  sceneNPCs = [];
  const sd = SCENE_DATA[state.location];
  if (!sd || !sd.npcPaths.length) return;
  // Spawn 2-4 NPCs
  const count = 2 + Math.floor(Math.random() * 3);
  for (let i = 0; i < count; i++) {
    const path = sd.npcPaths[i % sd.npcPaths.length];
    const npc = new NPC(path);
    // Stagger spawns
    npc.x += (Math.random() - 0.5) * TILE * 4;
    sceneNPCs.push(npc);
  }
}

// Periodically spawn new NPCs
let npcSpawnTimer = 0;
function maybeSpawnNPC() {
  npcSpawnTimer++;
  if (npcSpawnTimer < 180) return; // every ~3 sec
  npcSpawnTimer = 0;
  const sd = SCENE_DATA[state.location];
  if (!sd || !sd.npcPaths.length) return;
  if (sceneNPCs.filter(n => n.state !== 'gone').length >= 5) return;
  const path = sd.npcPaths[Math.floor(Math.random() * sd.npcPaths.length)];
  sceneNPCs.push(new NPC(path));
}

// Draw a character sprite (player or NPC) at pixel position
async function drawCharSprite(ctx, files, px, py, dir, frame, scale) {
  scale = scale || 1;
  const col = Math.floor(frame) % 7;
  const row = dir; // 0=down,1=up,2=left,3=right — but Seliel: row0=down, row1=up, row2=left, row3=right? Check.
  // Seliel layout: row 0=down, 1=up, 2=left, 3=right (walk)
  // We want: 0=up,1=left,2=down,3=right → remap
  const spriteRow = [1, 2, 0, 3][dir] || 0;
  for (const file of files) {
    try {
      const img = await loadSprite(SPRITE_PATH + file);
      ctx.drawImage(img,
        col * SPRITE_FRAME, spriteRow * SPRITE_FRAME, SPRITE_FRAME, SPRITE_FRAME,
        px - SPRITE_FRAME * scale / 2, py - SPRITE_FRAME * scale + 4, SPRITE_FRAME * scale, SPRITE_FRAME * scale
      );
    } catch(e) {}
  }
}

// Get player sprite layer files
function getPlayerSpriteFiles() {
  const bp = BODY_PREFIX[state.bodyType || 'feminine'] || 'p1';
  const skinV = SKIN_VARIANT_MAP[state.skinTone || 'pale'] || 'v00';
  const outfitCode = OUTFIT_MAP_SPRITE[state.outfit || 'traditional'] || 'fstr';
  const outfitV = OUTFIT_VARIANT_MAP[state.outfit || 'traditional'] || 'v01';
  const hairCode = (state.hairStyle || 'bob').includes('bob') || (state.hairStyle || '').includes('short') ? 'bob1' : 'dap1';
  const hairV = HAIR_COLOR_MAP[state.hairColor || 'brown'] || 'v00';
  const layers = [
    `char_a_${bp}_0bas_humn_${skinV}.png`,
    `char_a_${bp}_1out_${outfitCode}_${outfitV}.png`,
    `char_a_${bp}_4har_${hairCode}_${hairV}.png`,
  ];
  if (state.accessory === 'hat') layers.push(`char_a_${bp}_5hat_pfht_v01.png`);
  return layers;
}

// Draw background for location
async function drawSceneBG(ctx) {
  const sd = SCENE_DATA[state.location];
  const tod = state.timeOfDay;
  ctx.imageSmoothingEnabled = false;

  // Load sheets
  const [grass, water, houses, exterior, nature, trees, hills, furnState, floors] = await Promise.all([
    loadSheet('grass'), loadSheet('water'), loadSheet('houses'),
    loadSheet('exterior'), loadSheet('nature'), loadSheet('trees2'),
    loadSheet('hills'), loadSheet('TopDownHouse_FurnitureState1'),
    loadSheet('TopDownHouse_FloorsAndWalls'),
  ]);

  // Fill ground
  ctx.fillStyle = sd.ground;
  ctx.fillRect(0, 0, SCENE_PX, SCENE_PH);

  const d = sd.draw;

  if (d === 'apartment') {
    // Wooden floor planks
    ctx.strokeStyle = '#a07850'; ctx.lineWidth = 1;
    for (let y = 0; y < SCENE_PH; y += TILE) {
      ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(SCENE_PX, y); ctx.stroke();
    }
    for (let x = 0; x < SCENE_PX; x += TILE * 2) {
      ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, SCENE_PH); ctx.stroke();
    }
    // Back wall
    ctx.fillStyle = '#d4c4a8';
    ctx.fillRect(0, 0, SCENE_PX, TILE * 3);
    ctx.fillStyle = '#c8b898';
    ctx.fillRect(0, TILE * 3 - 8, SCENE_PX, 8);
    // Window
    ctx.fillStyle = '#87CEEB';
    ctx.fillRect(TILE * 8, TILE, TILE * 4, TILE * 1.5);
    ctx.strokeStyle = '#8b7355'; ctx.lineWidth = 2;
    ctx.strokeRect(TILE * 8, TILE, TILE * 4, TILE * 1.5);
    // Bed (top-left)
    spr(ctx, furnState, 0, 0, 0, TILE, 32, 48);
    // Bookshelf (top-right)
    spr(ctx, furnState, 48, 0, TILE * 17, TILE, 32, 48);
    // Rug
    ctx.fillStyle = 'rgba(140,60,80,0.35)';
    ctx.fillRect(TILE * 7, TILE * 6, TILE * 6, TILE * 4);
  }

  if (d === 'boardwalk') {
    // Top: stalls/buildings
    ctx.fillStyle = '#c4a870';
    ctx.fillRect(0, 0, SCENE_PX, TILE * 2);
    spr(ctx, exterior, 0, 0, TILE * 2, 0, 32, 32);
    spr(ctx, exterior, 32, 0, TILE * 8, 0, 32, 32);
    spr(ctx, exterior, 64, 0, TILE * 14, 0, 32, 32);
    // Boardwalk planks (middle)
    ctx.fillStyle = '#a08860';
    ctx.fillRect(0, TILE * 3, SCENE_PX, TILE * 5);
    ctx.strokeStyle = '#8b7355'; ctx.lineWidth = 1;
    for (let x = 0; x < SCENE_PX; x += 20) {
      ctx.beginPath(); ctx.moveTo(x, TILE * 3); ctx.lineTo(x, TILE * 8); ctx.stroke();
    }
    // Railing
    ctx.fillStyle = '#c4a870';
    ctx.fillRect(0, TILE * 8, SCENE_PX, 3);
    for (let x = 8; x < SCENE_PX; x += 24) ctx.fillRect(x, TILE * 7.5, 2, TILE);
    // Sand + ocean
    ctx.fillStyle = '#e8d5a8';
    ctx.fillRect(0, TILE * 8 + 3, SCENE_PX, TILE);
    ctx.fillStyle = '#3a8abf';
    ctx.fillRect(0, TILE * 10, SCENE_PX, TILE * 2);
    ctx.strokeStyle = 'rgba(255,255,255,0.3)'; ctx.lineWidth = 1;
    for (let wy = TILE * 10; wy < SCENE_PH; wy += 8) {
      ctx.beginPath();
      for (let wx = 0; wx < SCENE_PX; wx += 4) ctx.lineTo(wx, wy + Math.sin(wx * 0.08 + frameCount * 0.02) * 2);
      ctx.stroke();
    }
  }

  if (d === 'market') {
    // Cobblestone
    ctx.strokeStyle = '#908070'; ctx.lineWidth = 0.5;
    for (let y = 0; y < SCENE_PH; y += TILE)
      for (let x = (y % 32 === 0 ? 0 : 8); x < SCENE_PX; x += TILE)
        ctx.strokeRect(x, y, TILE, TILE);
    // Back wall with shops
    ctx.fillStyle = '#706050';
    ctx.fillRect(0, 0, SCENE_PX, TILE * 2);
    spr(ctx, houses, 0, 0, 0, -16, 64, 64);
    spr(ctx, houses, 64, 0, TILE * 5, -16, 64, 64);
    spr(ctx, houses, 128, 0, TILE * 10, -16, 64, 64);
    spr(ctx, houses, 0, 64, TILE * 15, -16, 64, 64);
    // Stalls
    spr(ctx, exterior, 0, 0, TILE * 2, TILE * 3, 32, 32);
    spr(ctx, exterior, 32, 0, TILE * 8, TILE * 3, 32, 32);
    spr(ctx, exterior, 64, 0, TILE * 15, TILE * 3, 32, 32);
  }

  if (d === 'university') {
    // Building (top)
    ctx.fillStyle = '#8a7060';
    ctx.fillRect(TILE * 3, 0, TILE * 14, TILE * 3);
    ctx.fillStyle = '#a08870';
    ctx.fillRect(TILE * 3 + 2, 2, TILE * 14 - 4, TILE * 3 - 4);
    ctx.fillStyle = '#87CEEB';
    for (let wx = TILE * 4; wx < TILE * 16; wx += TILE * 2) {
      ctx.fillRect(wx, TILE, TILE * 1.2, TILE * 1.2);
    }
    ctx.fillStyle = '#5a3a1a';
    ctx.fillRect(TILE * 9.5, TILE * 1.5, TILE * 1.2, TILE * 1.5);
    // Stone path
    ctx.fillStyle = '#c4b090';
    ctx.fillRect(TILE * 9, TILE * 3, TILE * 2, SCENE_PH);
    // Trees (sides)
    spr(ctx, trees, 0, 0, 0, TILE * 2, 32, 32);
    spr(ctx, trees, 0, 0, TILE * 18, TILE * 2, 32, 32);
    spr(ctx, trees, 32, 0, 0, TILE * 7, 32, 32);
    spr(ctx, trees, 32, 0, TILE * 18, TILE * 7, 32, 32);
  }

  if (d === 'harbor') {
    // Stone dock (top part)
    ctx.fillStyle = '#808080';
    ctx.fillRect(0, 0, SCENE_PX, TILE * 9);
    ctx.strokeStyle = '#606060'; ctx.lineWidth = 0.5;
    for (let y = 0; y < TILE * 9; y += TILE)
      for (let x = (y % 32 === 0 ? 0 : 8); x < SCENE_PX; x += TILE)
        ctx.strokeRect(x, y, TILE, TILE);
    // Crates/barrels
    spr(ctx, exterior, 240, 0, TILE, TILE * 2, TILE, TILE);
    spr(ctx, exterior, 256, 0, TILE * 2, TILE * 2, TILE, TILE);
    spr(ctx, exterior, 240, 0, TILE * 17, TILE * 3, TILE, TILE);
    // Ocean
    ctx.fillStyle = '#2878a8';
    ctx.fillRect(0, TILE * 9, SCENE_PX, TILE * 3);
    ctx.strokeStyle = 'rgba(255,255,255,0.2)'; ctx.lineWidth = 1;
    for (let wy = TILE * 9; wy < SCENE_PH; wy += 8) {
      ctx.beginPath();
      for (let wx = 0; wx < SCENE_PX; wx += 4) ctx.lineTo(wx, wy + Math.sin(wx * 0.06 + frameCount * 0.015) * 2);
      ctx.stroke();
    }
    // Dock edge
    ctx.fillStyle = '#6a6a6a';
    ctx.fillRect(0, TILE * 8.5, SCENE_PX, TILE * 0.5);
  }

  if (d === 'park') {
    // Winding path
    ctx.fillStyle = '#d4c4a0';
    ctx.beginPath();
    ctx.moveTo(0, TILE * 5);
    ctx.quadraticCurveTo(TILE * 6, TILE * 3, TILE * 10, TILE * 6);
    ctx.quadraticCurveTo(TILE * 14, TILE * 9, TILE * 20, TILE * 7);
    ctx.lineTo(TILE * 20, TILE * 8);
    ctx.quadraticCurveTo(TILE * 14, TILE * 10, TILE * 10, TILE * 7);
    ctx.quadraticCurveTo(TILE * 6, TILE * 4, 0, TILE * 6);
    ctx.fill();
    // Trees
    spr(ctx, trees, 0, 0, TILE, TILE, 32, 32);
    spr(ctx, trees, 32, 0, TILE * 12, TILE * 2, 32, 32);
    spr(ctx, trees, 0, 0, TILE * 17, TILE, 32, 32);
    spr(ctx, trees, 32, 0, TILE * 6, TILE * 9, 32, 32);
    // Flowers
    for (let i = 0; i < 5; i++) {
      spr(ctx, nature, 32, 0, TILE * (3 + i * 3.5), TILE * (5 + (i % 3)), TILE, TILE);
    }
    // Bench
    ctx.fillStyle = '#8b7355';
    ctx.fillRect(TILE * 8 - 8, TILE * 5, 32, 5);
    ctx.fillRect(TILE * 8 - 6, TILE * 5 + 5, 4, 6);
    ctx.fillRect(TILE * 8 + 18, TILE * 5 + 5, 4, 6);
  }

  // Table spots — show indicators
  const sd2 = SCENE_DATA[state.location];
  if (sd2.tableSpots && !tableSetUp) {
    ctx.globalAlpha = 0.4 + Math.sin(frameCount * 0.05) * 0.2;
    sd2.tableSpots.forEach(spot => {
      ctx.fillStyle = '#d4a574';
      ctx.fillRect(spot.x * TILE, spot.y * TILE, TILE * 2, TILE * 2);
      ctx.strokeStyle = '#a07850';
      ctx.lineWidth = 1;
      ctx.strokeRect(spot.x * TILE, spot.y * TILE, TILE * 2, TILE * 2);
    });
    ctx.globalAlpha = 1;
  }

  // Draw placed table
  if (tableSetUp && tablePos) {
    const tx = tablePos.x * TILE, ty = tablePos.y * TILE;
    // Table
    ctx.fillStyle = '#8b6a3a';
    ctx.fillRect(tx, ty + 4, TILE * 2, TILE - 4);
    ctx.fillStyle = '#a07850';
    ctx.fillRect(tx + 1, ty, TILE * 2 - 2, 5);
    // Cloth
    ctx.fillStyle = '#4a2060';
    ctx.fillRect(tx + 2, ty + 1, TILE * 2 - 4, 3);
    // Crystal ball
    ctx.fillStyle = 'rgba(180,160,220,0.7)';
    ctx.beginPath();
    ctx.arc(tx + TILE, ty + 3, 3, 0, Math.PI * 2);
    ctx.fill();
  }

  // Time-of-day tint
  const tint = TIME_TINTS[state.timeOfDay];
  if (tint) {
    ctx.fillStyle = tint;
    ctx.fillRect(0, 0, SCENE_PX, SCENE_PH);
  }

  // Night stars
  if (state.timeOfDay === 3 && !SCENE_DATA[state.location].indoor) {
    ctx.fillStyle = '#fff';
    for (let i = 0; i < 12; i++) {
      ctx.globalAlpha = 0.3 + Math.random() * 0.5;
      ctx.fillRect(Math.random() * SCENE_PX, Math.random() * TILE * 2, 1, 1);
    }
    ctx.globalAlpha = 1;
  }
}

// Main scene loop
async function sceneFrame() {
  const canvas = $('#scene-canvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  ctx.imageSmoothingEnabled = false;
  frameCount++;

  // Draw background
  await drawSceneBG(ctx);

  // Update & draw NPCs
  maybeSpawnNPC();
  sceneNPCs = sceneNPCs.filter(n => n.state !== 'gone');
  for (const npc of sceneNPCs) {
    npc.update(1);
    if (npc.x > -TILE && npc.x < SCENE_PX + TILE && npc.y > -TILE && npc.y < SCENE_PH + TILE) {
      await drawCharSprite(ctx, npc.getSpriteFiles(), npc.x, npc.y + TILE, npc.dir, npc.frame, 0.5);
    }
  }

  // Move player toward target
  if (playerTarget) {
    const tx = playerTarget.x * TILE + TILE / 2, ty = playerTarget.y * TILE + TILE / 2;
    const dx = tx - (playerPos.x * TILE + TILE / 2), dy = ty - (playerPos.y * TILE + TILE / 2);
    const dist = Math.sqrt(dx * dx + dy * dy);
    if (dist < 2) {
      playerPos.x = playerTarget.x;
      playerPos.y = playerTarget.y;
      playerTarget = null;
      playerFrame = 0;
      // Check if we stepped on a table spot
      checkTableSpot();
    } else {
      const spd = 0.8;
      playerPos.x += (dx / dist) * spd / TILE;
      playerPos.y += (dy / dist) * spd / TILE;
      if (Math.abs(dx) > Math.abs(dy)) playerDir = dx > 0 ? 3 : 1;
      else playerDir = dy > 0 ? 2 : 0;
      playerFrame += 0.1;
    }
  }

  // Draw player
  const pfiles = getPlayerSpriteFiles();
  await drawCharSprite(ctx, pfiles, playerPos.x * TILE + TILE / 2, playerPos.y * TILE + TILE, playerDir, playerTarget ? playerFrame : 0, 0.5);

  sceneLoop = requestAnimationFrame(sceneFrame);
}

function checkTableSpot() {
  if (tableSetUp) return;
  const sd = SCENE_DATA[state.location];
  if (!sd.tableSpots) return;
  for (const spot of sd.tableSpots) {
    if (Math.abs(playerPos.x - spot.x) < 2 && Math.abs(playerPos.y - spot.y) < 2) {
      // Show "set up table" prompt
      const existing = $('#scene-table-prompt');
      if (existing) existing.remove();
      const prompt = document.createElement('div');
      prompt.id = 'scene-table-prompt';
      prompt.className = 'scene-prompt';
      prompt.innerHTML = `<button class="magic-btn" onclick="Game.setUpTable(${spot.x},${spot.y})">Set Up Table Here 🔮</button>`;
      $('#location-scene').appendChild(prompt);
      return;
    }
  }
}

function setUpTable(x, y) {
  tablePos = {x, y};
  tableSetUp = true;
  const el = $('#scene-table-prompt');
  if (el) el.remove();
  showToast('Table set up! Clients may stop by...');
}

function stopScene() {
  if (sceneLoop) { cancelAnimationFrame(sceneLoop); sceneLoop = null; }
  sceneNPCs = [];
  tableSetUp = false;
  tablePos = null;
}

function startScene() {
  stopScene();
  const sd = SCENE_DATA[state.location];
  if (!sd) return;
  playerPos = {...sd.playerStart};
  playerTarget = null;
  playerDir = 2;
  playerFrame = 0;
  frameCount = 0;
  npcSpawnTimer = 0;
  if (sd.npcPaths.length) spawnNPCs();
  sceneFrame();
}

function renderLocation() {
  stopScene();
  const loc = LOCATIONS[state.location];
  const scene = $('#location-scene');
  const timeEmoji = TIME_EMOJI[state.timeOfDay];
  let actionsHTML = '';

  if (loc.permit && !state.permits[loc.permit]) {
    actionsHTML += `<button class="magic-btn" onclick="Game.buyPermit('${loc.permit}')">Buy Permit ($${DATA.economy?.permit_costs?.[loc.permit] || 50})</button>`;
  }

  if (state.location === 'apartment') {
    actionsHTML += `<button class="magic-btn" onclick="Game.rest()">Rest 😴</button>`;
  }

  actionsHTML += `<button class="magic-btn" onclick="Game.advanceTime()">Wait (${getTimeName()} → ${TIME_NAMES[(state.timeOfDay + 1) % 4]})</button>`;

  scene.innerHTML = `
    <canvas id="scene-canvas" width="${SCENE_PX}" height="${SCENE_PH}"></canvas>
    <div class="scene-hud">
      <span>${timeEmoji} ${getTimeName()}</span>
      <span>${loc.name}</span>
    </div>
    <div class="location-actions">${actionsHTML}</div>
  `;

  // Tap to move
  const canvas = $('#scene-canvas');
  canvas.addEventListener('click', (e) => {
    const rect = canvas.getBoundingClientRect();
    const scaleX = SCENE_PX / rect.width, scaleY = SCENE_PH / rect.height;
    const cx = (e.clientX - rect.left) * scaleX;
    const cy = (e.clientY - rect.top) * scaleY;
    const tx = Math.floor(cx / TILE), ty = Math.floor(cy / TILE);
    // Check walkability
    const sd = SCENE_DATA[state.location];
    const blocked = sd.solids.some(s => tx >= s[0] && tx < s[0] + s[2] && ty >= s[1] && ty < s[1] + s[3]);
    if (!blocked && tx >= 0 && tx < SCENE_W && ty >= 0 && ty < SCENE_H) {
      playerTarget = {x: tx, y: ty};
    }
  });

  startScene();
}

// ============================================================
// LOCATION SELECT
// ============================================================
function showLocations() {
  showOverlay('locations');
  const list = $('#location-list');
  list.innerHTML = '';
  for (const [id, loc] of Object.entries(LOCATIONS)) {
    const needsPermit = loc.permit && !state.permits[loc.permit];
    const isCurrent = id === state.location;
    const card = document.createElement('div');
    card.className = `location-card${needsPermit ? ' locked' : ''}${isCurrent ? ' current' : ''}`;
    card.innerHTML = `
      <div class="loc-emoji">${loc.emoji}</div>
      <div class="loc-name">${loc.name}</div>
      <div class="loc-info">${loc.free ? 'Free' : 'Permit needed'}</div>
      ${needsPermit ? `<div class="loc-lock">🔒 Need permit</div>` : ''}
      ${isCurrent ? `<div class="loc-info" style="color:var(--gold)">You are here</div>` : ''}
    `;
    if (!isCurrent) {
      card.addEventListener('click', () => {
        // Travel costs energy
        if (state.energy < 5) { showToast('Too tired to travel!'); return; }
        state.energy -= 5;
        state.location = id;
        if (!state.stats.locations_visited.includes(id)) {
          state.stats.locations_visited.push(id);
          if (state.stats.locations_visited.length >= 6) checkAchievement('all_locations');
        }
        hideOverlay('locations');
        renderGame();
        showToast(`Arrived at ${loc.name}`);
      });
    }
    list.appendChild(card);
  }
}

// ============================================================
// TAROT READING
// ============================================================
let readingCards = [];
let revealedCount = 0;

function startReading() {
  const loc = LOCATIONS[state.location];
  if (!loc.canRead) { showToast("Can't do readings here!"); return; }
  if (loc.permit && !state.permits[loc.permit]) { showToast('You need a permit for this location!'); return; }
  if (state.energy < 20) { showToast('Too tired for a reading! Rest first.'); return; }
  if (state.timeOfDay >= 3) { showToast("It's too late for readings. Rest and try tomorrow."); return; }

  state.energy -= 20;
  revealedCount = 0;

  // Draw 3 cards
  const shuffled = [...fullDeck].sort(() => Math.random() - 0.5);
  readingCards = shuffled.slice(0, 3).map(card => ({
    ...card,
    reversed: Math.random() < 0.35,
    revealed: false,
  }));

  // Update moon bonus display
  const moonBonus = getMoonBonus();
  const moonPhase = getMoonPhase(state.day);
  $('#reading-moon-bonus').textContent = moonBonus > 1 ? `${moonPhase.symbol} ${moonPhase.name} (+${Math.round((moonBonus-1)*100)}%)` : moonPhase.symbol + ' ' + moonPhase.name;

  // Render cards
  const spread = $('#card-spread');
  spread.innerHTML = '';
  readingCards.forEach((card, i) => {
    const slot = document.createElement('div');
    slot.className = 'card-slot';
    slot.innerHTML = `
      <div class="card" data-idx="${i}">
        <div class="card-inner">
          <div class="card-back">
            <div class="card-back-design">
              <div class="back-border">
                <div class="back-pattern">
                  <span class="moon-symbol">☽</span>
                  <span class="star-ring">✦ ✦ ✦</span>
                  <span class="eye-symbol">👁</span>
                  <span class="star-ring">✦ ✦ ✦</span>
                  <span class="moon-symbol">☾</span>
                </div>
              </div>
            </div>
          </div>
          <div class="card-front">
            <div class="card-number">${card.number !== undefined ? (card.number === 0 ? '0' : card.number) : ''}</div>
            <div class="card-illustration" ${card.reversed ? 'style="transform:rotate(180deg)"' : ''}>
              <div class="card-art-symbol">${getCardSymbol(card)}</div>
            </div>
            <div class="card-name">${card.name}</div>
            <div class="card-orientation ${card.reversed ? 'reversed' : 'upright'}">${card.reversed ? '↓ Reversed' : '↑ Upright'}</div>
          </div>
        </div>
      </div>
    `;
    spread.appendChild(slot);
  });

  // Card click handlers
  spread.querySelectorAll('.card').forEach(cardEl => {
    cardEl.addEventListener('click', () => revealCard(cardEl));
  });

  $('#reading-hint').style.display = 'block';
  $('#btn-finish-reading').style.display = 'none';

  showScreen('reading');
  updateHUD();
}

function revealCard(cardEl) {
  if (cardEl.classList.contains('revealed')) {
    // Tapping a revealed card shows its interpretation
    const idx = parseInt(cardEl.dataset.idx);
    if (!isNaN(idx)) showInterpretation(idx);
    return;
  }
  cardEl.classList.add('revealed', 'flipping');
  createSparkles(cardEl);
  const idx = parseInt(cardEl.dataset.idx);
  revealedCount++;

  // Show interpretation bubble after flip
  setTimeout(() => {
    if (!isNaN(idx)) showInterpretation(idx);
  }, 800);

  if (revealedCount >= 3) {
    $('#reading-hint').style.display = 'none';
    $('#btn-finish-reading').style.display = 'inline-block';
  }
}

const SPREAD_LABELS = ['Past', 'Present', 'Future'];

function showInterpretation(idx) {
  const card = readingCards[idx];
  if (!card) return;
  const bubble = $('#interpretation-bubble');
  bubble.innerHTML = `
    <div class="interp-header">
      <span class="interp-position">${SPREAD_LABELS[idx] || ''}</span>
      <span class="interp-name">${card.name} ${card.reversed ? '(Reversed)' : ''}</span>
      <button class="interp-close" onclick="this.closest('#interpretation-bubble').style.display='none'">✕</button>
    </div>
    <div class="interp-keywords">${(card.keywords || []).join(' · ')}</div>
    <div class="interp-element">${card.element || ''}</div>
    <div class="interp-meaning">${card.reversed ? card.reversed_meaning : card.upright_meaning}</div>
    <div class="interp-visual">"${card.visual_description || ''}"</div>
  `;
  bubble.style.display = 'block';
}

function getCardSymbol(card) {
  const symbols = {
    'The Fool': '🌀', 'The Magician': '✨', 'The High Priestess': '🌙',
    'The Empress': '🌿', 'The Emperor': '👑', 'The Hierophant': '🔑',
    'The Lovers': '💕', 'The Chariot': '⚡', 'Strength': '🦁',
    'The Hermit': '🏔️', 'Wheel of Fortune': '☸️', 'Justice': '⚖️',
    'The Hanged Man': '🔮', 'Death': '🦋', 'Temperance': '🌊',
    'The Devil': '🔥', 'The Tower': '⛈️', 'The Star': '⭐',
    'The Moon': '🌑', 'The Sun': '☀️', 'Judgement': '🎺',
    'The World': '🌍',
  };
  if (symbols[card.name]) return symbols[card.name];
  // Minor arcana
  const suitSymbols = { Wands: '🪄', Cups: '🏆', Swords: '⚔️', Pentacles: '💰' };
  if (card.suit) return suitSymbols[card.suit] || '✦';
  return '✦';
}

function createSparkles(cardEl) {
  const rect = cardEl.getBoundingClientRect();
  for (let i = 0; i < 12; i++) {
    const spark = document.createElement('div');
    spark.className = 'sparkle';
    const angle = (Math.PI * 2 / 12) * i;
    const dist = 30 + Math.random() * 40;
    spark.style.cssText = `
      left:${rect.left + rect.width/2}px;
      top:${rect.top + rect.height/2}px;
      --sx:${Math.cos(angle)*dist}px;
      --sy:${Math.sin(angle)*dist}px;
      position:fixed;
    `;
    document.body.appendChild(spark);
    setTimeout(() => spark.remove(), 600);
  }
}

function finishReading() {
  const income = calculateReadingIncome();
  state.money += income;
  state.stats.money_earned += income;
  state.totalReadings++;
  state.todayReadings++;
  // Reputation gain
  state.reputation = Math.min(100, state.reputation + 2);

  if (state.totalReadings === 1) checkAchievement('first_reading');

  advanceTime();
  showScreen('game');
  renderGame();
  showToast(`Reading complete! Earned $${income} 💰`);
}

// ============================================================
// COMPACT MIRROR
// ============================================================
function showCompact() {
  showOverlay('compact');
  renderMessages();
  renderCroneslist();
  renderSaveTab();
  syncStylingTab();
  // Reset to messages tab
  switchCompactTab('messages');
}

// ============================================================
// CHARACTER STYLING (in Compact Mirror)
// ============================================================
// Seliel sprite system — 512x512 sheets, 64px frames, 8 per row
// Naming: char_a_{bodyType}_0bas_humn_{skinV}.png, 1out_{outfit}_{outfitV}.png, 4har_{hair}_{hairV}.png, 5hat_{hat}_{hatV}.png
const SPRITE_FRAME = 64;
const SPRITE_PATH = 'assets/sprites/character/seliel/';
const SKIN_VARIANT_MAP = { pale: 'v00', light: 'v02', medium: 'v04', tan: 'v06', dark: 'v08', deep: 'v10' };
const HAIR_STYLE_MAP = { bob: 'bob1', dapper: 'dap1' };
const HAIR_COLOR_MAP = { grey: 'v00', silver: 'v01', sandy: 'v02', blonde: 'v03', auburn: 'v04', ginger: 'v05', rose: 'v06', purple: 'v07', teal: 'v08', blue: 'v09', charcoal: 'v10', brown: 'v11', pink: 'v12', slate: 'v13' };
const HAIR_COLOR_HEX = { grey: '#82838b', silver: '#969f99', sandy: '#9a866b', blonde: '#b99141', auburn: '#af7060', ginger: '#b55b25', rose: '#bc7c85', purple: '#785d8b', teal: '#57938e', blue: '#527ba8', charcoal: '#6c6e78', brown: '#664630', pink: '#c26ba1', slate: '#60677f' };
const OUTFIT_MAP_SPRITE = { traditional: 'fstr', modern: 'pfpn', casual: 'fstr', traveler: 'fstr', punk: 'pfpn' };
const OUTFIT_VARIANT_MAP = { traditional: 'v01', modern: 'v01', casual: 'v03', traveler: 'v04', punk: 'v03' };
const HAT_MAP = { hat: 'pfht', pointy: 'pnty' };
const BODY_PREFIX = { feminine: 'p1', androgynous: 'p1', masculine: 'pONE1' };

const spriteCache = {};
function loadSprite(src) {
  if (spriteCache[src]) return Promise.resolve(spriteCache[src]);
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => { spriteCache[src] = img; resolve(img); };
    img.onerror = () => reject(new Error('Failed: ' + src));
    img.src = src;
  });
}

async function drawCharPreview() {
  const canvas = $('#char-preview');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.imageSmoothingEnabled = false;

  const bp = BODY_PREFIX[state.bodyType || 'feminine'] || 'p1';
  const skinV = SKIN_VARIANT_MAP[state.skinTone || 'pale'] || 'v00';
  const outfitCode = OUTFIT_MAP_SPRITE[state.outfit || 'traditional'] || 'fstr';
  const outfitV = OUTFIT_VARIANT_MAP[state.outfit || 'traditional'] || 'v01';
  const hairCode = (state.hairStyle || 'bob').includes('bob') || (state.hairStyle || '').includes('short') ? 'bob1' : 'dap1';
  const hairV = HAIR_COLOR_MAP[state.hairColor || 'brown'] || 'v00';

  const layers = [
    `char_a_${bp}_0bas_humn_${skinV}.png`,
    `char_a_${bp}_1out_${outfitCode}_${outfitV}.png`,
    `char_a_${bp}_4har_${hairCode}_${hairV}.png`,
  ];
  if (state.accessory === 'hat') {
    layers.push(`char_a_${bp}_5hat_pfht_v01.png`);
  }

  // Draw front-facing idle frame (row 0, col 0) from each layer
  const scale = Math.min(canvas.width / SPRITE_FRAME, canvas.height / SPRITE_FRAME);
  const dx = (canvas.width - SPRITE_FRAME * scale) / 2;
  const dy = (canvas.height - SPRITE_FRAME * scale) / 2;

  for (const file of layers) {
    try {
      const img = await loadSprite(SPRITE_PATH + file);
      ctx.drawImage(img, 0, 0, SPRITE_FRAME, SPRITE_FRAME, dx, dy, SPRITE_FRAME * scale, SPRITE_FRAME * scale);
    } catch(e) {
      // Layer missing, skip silently
    }
  }
}

function syncStylingTab() {
  const n = $('#compact-name');
  if (n) n.value = state.name || '';
  const p = $('#compact-pronouns');
  if (p) p.value = state.pronouns || 'she';
  const b = $('#compact-body');
  if (b) b.value = state.bodyType || 'feminine';
  const hs = $('#compact-hairstyle');
  if (hs) hs.value = state.hairStyle || 'long_straight';
  $$('.hair-dot').forEach(d => d.classList.toggle('selected', d.dataset.hair === (state.hairColor || 'brown')));
  const o = $('#compact-outfit');
  if (o) o.value = state.outfit || 'traditional';
  const a = $('#compact-accessory');
  if (a) a.value = state.accessory || 'none';
  // Skin dots
  $$('.skin-dot').forEach(d => d.classList.toggle('selected', d.dataset.skin === (state.skinTone || 'pale')));
  drawCharPreview();
}

function initStylingTab() {
  // Skin tone dots
  $$('.skin-dot').forEach(dot => {
    dot.addEventListener('click', () => {
      $$('.skin-dot').forEach(d => d.classList.remove('selected'));
      dot.classList.add('selected');
      state.skinTone = dot.dataset.skin;
      drawCharPreview();
    });
  });

  // Hair color dots
  $$('.hair-dot').forEach(dot => {
    dot.addEventListener('click', () => {
      $$('.hair-dot').forEach(d => d.classList.remove('selected'));
      dot.classList.add('selected');
      state.hairColor = dot.dataset.hair;
      drawCharPreview();
    });
  });

  // Live preview on any change
  ['compact-pronouns','compact-body','compact-hairstyle','compact-outfit','compact-accessory'].forEach(id => {
    const el = $(`#${id}`);
    if (el) el.addEventListener('change', () => {
      state.pronouns = $('#compact-pronouns').value;
      state.bodyType = $('#compact-body').value;
      state.hairStyle = $('#compact-hairstyle').value;
      
      state.outfit = $('#compact-outfit').value;
      state.accessory = $('#compact-accessory').value;
      drawCharPreview();
    });
  });

  // Save button
  const saveBtn = $('#btn-save-appearance');
  if (saveBtn) saveBtn.addEventListener('click', () => {
    const name = $('#compact-name').value.trim();
    if (name) state.name = name;
    state.pronouns = $('#compact-pronouns').value;
    state.bodyType = $('#compact-body').value;
    state.hairStyle = $('#compact-hairstyle').value;
    
    state.outfit = $('#compact-outfit').value;
    state.accessory = $('#compact-accessory').value;
    saveGame();
    showToast('Appearance saved! ✨');
    renderGame();
  });
}

function switchCompactTab(tab) {
  $$('.tab-btn').forEach(b => b.classList.toggle('active', b.dataset.tab === tab));
  $$('.tab-content').forEach(c => c.classList.toggle('active', c.id === `tab-${tab}`));
}

function renderMessages() {
  const list = $('#message-list');
  if (state.messages.length === 0) {
    list.innerHTML = '<p class="coming-soon">No messages yet. Check back later!</p>';
    return;
  }
  list.innerHTML = state.messages.slice(-20).reverse().map(m => `
    <div class="message-item${m.unread ? ' message-unread' : ''}">
      <div class="message-sender">${m.sender}</div>
      <div class="message-text">${m.text}</div>
      <div class="message-time">Day ${m.day}</div>
    </div>
  `).join('');
  // Mark as read
  state.messages.forEach(m => m.unread = false);
}

function addMessage(sender, text) {
  state.messages.push({ sender, text, day: state.day, unread: true });
}

function maybeAddMessage() {
  if (Math.random() < 0.3) {
    const tips = DATA.dialogueExamples?.witch_network_messages?.tips || [];
    const encouragement = DATA.dialogueExamples?.witch_network_messages?.encouragement || [];
    const all = [...tips, ...encouragement];
    if (all.length > 0) {
      let msg = all[Math.floor(Math.random() * all.length)];
      // Replace pronoun placeholders
      msg = msg.replace(/\{subj\}/g, pronoun('subj'))
               .replace(/\{Subj\}/g, pronoun('subj').charAt(0).toUpperCase() + pronoun('subj').slice(1))
               .replace(/\{obj\}/g, pronoun('obj'))
               .replace(/\{poss\}/g, pronoun('poss'))
               .replace(/\{is\/are\}/g, state.pronouns === 'they' ? 'are' : 'is')
               .replace(/\{has\/have\}/g, state.pronouns === 'they' ? 'have' : 'has')
               .replace(/\{s\/\}/g, state.pronouns === 'they' ? '' : 's')
               .replace(/\{need\}/g, state.pronouns === 'they' ? 'need' : 'needs')
               .replace(/\{want\}/g, state.pronouns === 'they' ? 'want' : 'wants');
      const senders = ['WitchNet', 'LocalWitch42', 'SeaglassCoven', 'BroomShare', 'FriendlyHex'];
      addMessage(senders[Math.floor(Math.random() * senders.length)], msg);
    }
  }
}

// ============================================================
// CRONESLIST
// ============================================================
function refreshCroneslist() {
  state.activeListings = [];
  const catalog = DATA.brooms?.broom_catalog;
  if (!catalog) return;
  const sellers = DATA.notifications?.seller_names || {};
  const allSellers = [...(sellers.desperate||[]), ...(sellers.moving||[]), ...(sellers.upgrading||[])];

  // Generate 3-6 listings
  const numListings = 3 + Math.floor(Math.random() * 4);
  const tiers = ['budget_tier', 'budget_tier', 'budget_tier', 'mid_tier', 'mid_tier', 'premium_tier'];

  for (let i = 0; i < numListings; i++) {
    const tier = tiers[Math.floor(Math.random() * tiers.length)];
    const tierData = catalog[tier];
    if (!tierData) continue;
    const broomKeys = Object.keys(tierData);
    const broomKey = broomKeys[Math.floor(Math.random() * broomKeys.length)];
    const broom = tierData[broomKey];
    if (!broom) continue;
    const priceRange = broom.used_price_range || [broom.retail_price * 0.5, broom.retail_price * 0.8];
    const price = Math.round(priceRange[0] + Math.random() * (priceRange[1] - priceRange[0]));
    const issues = broom.aesthetic_issues_when_used || [];
    const issue = issues[Math.floor(Math.random() * issues.length)] || 'Minor wear';
    const seller = allSellers[Math.floor(Math.random() * allSellers.length)] || 'AnonymousWitch';
    const isPremium = tier === 'premium_tier';
    const minutesLeft = isPremium ? 3 + Math.floor(Math.random() * 5) : 10 + Math.floor(Math.random() * 30);

    state.activeListings.push({
      id: `${broomKey}_${Date.now()}_${i}`,
      name: broom.description ? broomKey.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()) : broomKey,
      description: broom.description || '',
      issue,
      price,
      seller,
      premium: isPremium,
      minutesLeft,
      speed: broom.flight_speed || '',
    });
  }
}

function renderCroneslist() {
  const listings = $('#cl-listings');
  const empty = $('#cl-empty');
  const balEl = $('.cl-balance');
  if (balEl) balEl.textContent = `Balance: $${state.money}`;

  // Show sell button if player has broom
  const sellBtn = $('#btn-cl-sell');
  if (sellBtn) sellBtn.style.display = state.broom ? 'inline-block' : 'none';

  if (state.activeListings.length === 0) {
    listings.innerHTML = '';
    empty.style.display = 'block';
    return;
  }
  empty.style.display = 'none';

  listings.innerHTML = state.activeListings.map(l => {
    const canAfford = state.money >= l.price;
    const urgent = l.minutesLeft < 5;
    return `
      <div class="cl-listing${l.premium ? ' premium' : ''}">
        <div class="cl-listing-name">${l.premium ? '✨ ' : ''}${l.name}</div>
        <div class="cl-listing-desc">"${l.issue}"</div>
        <div style="font-size:0.6rem;color:var(--crystal)">${l.speed}</div>
        <div class="cl-listing-meta">
          <span class="cl-listing-price" style="color:${canAfford ? 'var(--success)' : 'var(--danger)'}">$${l.price}</span>
          <span class="cl-listing-timer${urgent ? ' urgent' : ''}">${l.minutesLeft}min left</span>
          <button class="cl-buy-btn" ${canAfford ? '' : 'disabled'} onclick="Game.buyBroom('${l.id}')">Buy</button>
        </div>
        <div class="cl-listing-seller">Posted by ${l.seller}</div>
      </div>
    `;
  }).join('');
}

function buyBroom(listingId) {
  const listing = state.activeListings.find(l => l.id === listingId);
  if (!listing) { showToast('Listing no longer available!'); return; }
  if (state.money < listing.price) { showToast('Not enough money!'); return; }

  state.money -= listing.price;
  state.stats.money_spent += listing.price;
  state.stats.brooms_purchased++;
  state.broom = { name: listing.name, price: listing.price, premium: listing.premium };
  state.activeListings = state.activeListings.filter(l => l.id !== listingId);

  checkAchievement('got_broom');
  if (listing.premium) checkAchievement('got_premium_broom');

  renderCroneslist();
  updateHUD();
  showToast(`You bought ${listing.name}! 🧹✨`);
  addMessage('Croneslist', `Purchase confirmed: ${listing.name} for $${listing.price}. Happy flying!`);
}

function buyPermit(permitId) {
  const cost = DATA.economy?.permit_costs?.[permitId] || 50;
  if (state.money < cost) { showToast(`Not enough money! Need $${cost}`); return; }
  state.money -= cost;
  state.stats.money_spent += cost;
  state.permits[permitId] = true;
  updateHUD();
  renderGame();
  showToast(`Permit acquired! ✅`);
}

// ============================================================
// SAVE TAB
// ============================================================
function renderSaveTab() {
  const status = $('#save-status');
  if (state.lastSaved) {
    const d = new Date(state.lastSaved);
    status.textContent = `Last saved: ${d.toLocaleString()}`;
  } else {
    status.textContent = '';
  }
}

// ============================================================
// CALENDAR
// ============================================================
function showCalendar() {
  showOverlay('calendar');
  const dt = getDateFromDay(state.day);
  const moon = getMoonPhase(state.day);
  const holiday = getHoliday(state.day);

  $('#calendar-header').textContent = `${dt.monthName} ${dt.year}`;
  $('#calendar-moon').textContent = `${moon.symbol} ${moon.name}`;

  const daysLeft = daysUntilRent();
  const rentEl = $('#calendar-rent');
  rentEl.textContent = `Rent due in ${daysLeft} days ($${DATA.economy?.monthly_rent || 700})`;
  rentEl.style.color = daysLeft <= 5 ? 'var(--danger)' : 'var(--warning)';

  // Build calendar grid
  const daysInMonth = MONTH_DAYS[dt.month];
  // Simple grid: just show days with current day highlighted
  let grid = 'Su Mo Tu We Th Fr Sa\n';
  // Figure out what day of week the 1st is (simplified)
  const firstDayOffset = (state.day - dt.day) ; // day number of 1st of this month
  // We'll use a simple offset: March 1 2026 is a Sunday = 0
  const march1Dow = 0; // Sunday
  const daysSinceMarch1 = state.day - 1 - (dt.day - 1);
  const firstDow = ((march1Dow + daysSinceMarch1) % 7 + 7) % 7;

  for (let i = 0; i < firstDow; i++) grid += '   ';
  for (let d = 1; d <= daysInMonth; d++) {
    const dow = (firstDow + d - 1) % 7;
    const isCurrent = d === dt.day;
    grid += isCurrent ? `[${String(d).padStart(2)}]` : ` ${String(d).padStart(2)} `;
    if (dow === 6 && d < daysInMonth) grid += '\n';
  }
  $('#calendar-grid').textContent = grid;

  $('#calendar-holiday').textContent = holiday ? `✨ ${holiday.name}: ${(holiday.messages || [''])[0]}` : '';
}

// ============================================================
// REST
// ============================================================
function rest() {
  if (state.location !== 'apartment') {
    showToast('You need to go home to rest properly!');
    return;
  }
  const recovery = 40;
  state.energy = Math.min(100, state.energy + recovery);
  advanceTime();
  renderGame();
  showToast(`Rested! Energy restored to ${state.energy}⚡`);
}

// ============================================================
// ACHIEVEMENTS
// ============================================================
function checkAchievement(id) {
  if (state.unlockedAchievements.includes(id)) return;
  const achievements = DATA.achievements?.achievements || [];
  const ach = achievements.find(a => a.id === id);
  if (!ach) return;
  state.unlockedAchievements.push(id);
  showAchievement(ach.name, ach.description);
}

function checkAchievements() {
  if (state.day >= 8 && !state.unlockedAchievements.includes('survived_week')) {
    checkAchievement('survived_week');
  }
  if (state.money >= 500 && !state.unlockedAchievements.includes('saved_500')) {
    checkAchievement('saved_500');
  }
  if (state.stats.days_without_broom >= 100) {
    checkAchievement('walked_100_days');
  }
}

// ============================================================
// SERVICE WORKER REGISTRATION
// ============================================================
function registerSW() {
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('sw.js').catch(e => console.warn('SW registration failed:', e));
  }
}

// ============================================================
// EVENT WIRING
// ============================================================
function initEvents() {
  // Opening click to advance
  $('#screen-opening').addEventListener('click', advanceOpening);

  // Game action buttons
  $('#btn-compact').addEventListener('click', showCompact);
  $('#btn-calendar').addEventListener('click', showCalendar);
  $('#btn-location').addEventListener('click', showLocations);
  $('#btn-readings').addEventListener('click', startReading);
  $('#btn-rest').addEventListener('click', rest);

  // Close buttons
  $('#btn-close-compact').addEventListener('click', () => hideOverlay('compact'));
  $('#btn-close-calendar').addEventListener('click', () => hideOverlay('calendar'));
  $('#btn-close-locations').addEventListener('click', () => hideOverlay('locations'));

  // Compact tabs
  $$('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => switchCompactTab(btn.dataset.tab));
  });

  // Save button
  $('#btn-save-game').addEventListener('click', () => {
    saveGame();
    renderSaveTab();
    showToast('Game saved! ✨');
  });

  // Compact mirror styling
  initStylingTab();

  // Finish reading
  $('#btn-finish-reading').addEventListener('click', finishReading);

  // Back from reading
  $('#btn-back-from-reading').addEventListener('click', () => {
    showScreen('game');
    renderGame();
  });

  // Rent dismiss
  $('#btn-dismiss-rent').addEventListener('click', () => {
    $('#rent-warning').style.display = 'none';
  });

  // Sell broom
  const sellBtn = $('#btn-cl-sell');
  if (sellBtn) {
    sellBtn.addEventListener('click', () => {
      if (!state.broom) return;
      const sellPrice = Math.round(state.broom.price * 0.7);
      if (confirm(`Sell ${state.broom.name} for $${sellPrice}?`)) {
        state.money += sellPrice;
        state.stats.money_earned += sellPrice;
        state.stats.brooms_sold++;
        if (state.broom.premium) checkAchievement('sold_premium_for_rent');
        else checkAchievement('sold_for_rent');
        state.broom = null;
        renderCroneslist();
        updateHUD();
        showToast(`Broom sold for $${sellPrice}. 💔`);
      }
    });
  }
}

// ============================================================
// INIT
// ============================================================
async function init() {
  await loadAllData();
  initParticles();
  initTitle();
  initCreation();
  initEvents();
  registerSW();
}

// Expose public API for inline handlers
window.Game = {
  startReading,
  buyBroom,
  buyPermit,
  rest,
  advanceTime,
  setUpTable,
};

// Boot
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}

})();

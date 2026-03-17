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
  bodyType: 'androgynous',
  skinTone: 'medium',
  hairStyle: 'long_straight',
  hairColor: 'black',
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
  "You pull out your compact and...",
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

function renderLocation() {
  const loc = LOCATIONS[state.location];
  const scene = $('#location-scene');
  const timeEmoji = TIME_EMOJI[state.timeOfDay];
  let actionsHTML = '';

  if (loc.canRead && state.timeOfDay < 3) {
    // Check permit
    if (loc.permit && !state.permits[loc.permit]) {
      actionsHTML += `<button class="magic-btn" onclick="Game.buyPermit('${loc.permit}')">Buy Permit ($${DATA.economy?.permit_costs?.[loc.permit] || 50})</button>`;
    } else {
      actionsHTML += `<button class="magic-btn" onclick="Game.startReading()">Do Reading 🃏</button>`;
    }
  }

  if (state.location === 'apartment') {
    actionsHTML += `<button class="magic-btn" onclick="Game.rest()">Rest 😴</button>`;
  }

  actionsHTML += `<button class="magic-btn" onclick="Game.advanceTime()">Wait (${getTimeName()} → ${TIME_NAMES[(state.timeOfDay + 1) % 4]})</button>`;

  scene.innerHTML = `
    <div class="location-emoji">${loc.emoji}</div>
    <h2>${loc.name}</h2>
    <div class="location-desc">${timeEmoji} ${getTimeName()} — ${loc.desc}</div>
    <div class="location-actions">${actionsHTML}</div>
  `;
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
            <div class="card-element">${card.element || ''}</div>
            <div class="card-name">${card.name}</div>
            <div class="card-visual">${card.visual_description || ''}</div>
            <div class="card-keywords">${(card.keywords || []).join(' • ')}</div>
            <div class="card-orientation ${card.reversed ? 'reversed' : 'upright'}">${card.reversed ? '↓ Reversed' : '↑ Upright'}</div>
            <div class="card-meaning">${card.reversed ? card.reversed_meaning : card.upright_meaning}</div>
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
  if (cardEl.classList.contains('revealed')) return;
  cardEl.classList.add('revealed', 'flipping');
  // Sparkle effects
  createSparkles(cardEl);
  revealedCount++;

  if (revealedCount >= 3) {
    $('#reading-hint').style.display = 'none';
    $('#btn-finish-reading').style.display = 'inline-block';
  }
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
const HAIR_COLOR_MAP = { black: 'v00', brown: 'v03', blonde: 'v05', red: 'v07', purple: 'v09', blue: 'v11', green: 'v12', white: 'v13', pink: 'v10' };
const OUTFIT_MAP_SPRITE = { traditional: 'fstr', modern_witch: 'pfpn', casual: 'fstr', traveler: 'fstr', punk_witch: 'boxr' };
const OUTFIT_VARIANT_MAP = { traditional: 'v01', modern_witch: 'v01', casual: 'v03', traveler: 'v04', punk_witch: 'v01' };
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
  const hairV = HAIR_COLOR_MAP[state.hairColor || 'black'] || 'v00';

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
  const hc = $('#compact-haircolor');
  if (hc) hc.value = state.hairColor || 'black';
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

  // Live preview on any change
  ['compact-pronouns','compact-body','compact-hairstyle','compact-haircolor','compact-outfit','compact-accessory'].forEach(id => {
    const el = $(`#${id}`);
    if (el) el.addEventListener('change', () => {
      state.pronouns = $('#compact-pronouns').value;
      state.bodyType = $('#compact-body').value;
      state.hairStyle = $('#compact-hairstyle').value;
      state.hairColor = $('#compact-haircolor').value;
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
    state.hairColor = $('#compact-haircolor').value;
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
};

// Boot
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}

})();

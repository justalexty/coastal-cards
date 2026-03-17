const CACHE_NAME = 'coastal-cards-v1';
const ASSETS = [
  '/',
  '/index.html',
  '/style.css',
  '/game.js',
  '/manifest.json',
  '/data/achievements.json',
  '/data/broom_lore.json',
  '/data/broom_selling_emotions.json',
  '/data/complete_broom_catalog.json',
  '/data/croneslist_notifications.json',
  '/data/dialogue_examples.json',
  '/data/economy.json',
  '/data/holiday_effects.json',
  '/data/lunar_effects.json',
  '/data/premium_broom_economy.json',
  '/data/tarot_deck.json',
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE_NAME).then(c => c.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys =>
    Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
  ));
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  e.respondWith(
    caches.match(e.request).then(r => r || fetch(e.request))
  );
});

// Bhasha Setu Progressive Web App (PWA) Service Worker — Enhanced Offline-First V5 (upgraded from bhasha-setu-pwa-v3)
const CACHE_NAME = 'bhasha-setu-pwa-v5';

const PRECACHE_ASSETS = [
  '/',
  '/index.html',
  '/favicon.svg',
  '/manifest.json',
  '/apple-touch-icon.png',
  '/icon-192.png',
  '/icon-512.png',
  '/sql-wasm.wasm',
  '/sql-wasm-browser.wasm',
  '/data/translations.db',
  '/data/model_manifest.json'
];

// Install event: cache core static app shell + icons + SQLite WASM binary + translations.db
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return Promise.allSettled(
        PRECACHE_ASSETS.map((asset) =>
          cache.add(asset).catch((e) => console.warn(`[SW] Precache notice for ${asset}:`, e))
        )
      );
    }).then(() => self.skipWaiting())
  );
});

// Activate event: clean outdated caches safely and take control
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME)
          .map((name) => {
            console.log(`[SW] Purging outdated cache: ${name}`);
            return caches.delete(name);
          })
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch event: Cache-First for critical offline binary assets & JS/CSS chunks, Stale-While-Revalidate for others
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  const url = new URL(event.request.url);

  // Skip Vite dev server internal live-reload & HMR requests
  if (
    url.pathname.startsWith('/@vite') ||
    url.pathname.startsWith('/@fs') ||
    url.pathname.startsWith('/@id') ||
    url.pathname.includes('__vite_ping')
  ) {
    return;
  }

  // 1. Navigation requests: Network-First with cache fallback to /index.html (SPA offline routing)
  if (event.request.mode === 'navigate' || url.pathname === '/' || url.pathname === '/index.html') {
    event.respondWith(
      fetch(event.request)
        .then((networkRes) => {
          if (networkRes && networkRes.status === 200) {
            const clone = networkRes.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
          }
          return networkRes;
        })
        .catch(() => {
          return caches.match('/index.html').then((cached) => {
            return cached || caches.match('/');
          });
        })
    );
    return;
  }

  // 2. High-priority offline binary & data assets (.wasm, .db, .json manifests): Cache-first
  if (
    url.pathname.endsWith('.wasm') ||
    url.pathname.includes('translations.db') ||
    url.pathname.includes('model_manifest.json')
  ) {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        if (cached) return cached;
        return fetch(event.request).then((networkRes) => {
          if (networkRes && networkRes.status === 200) {
            const clone = networkRes.clone();
            caches.open(CACHE_NAME).then((c) => c.put(event.request, clone));
          }
          return networkRes;
        });
      })
    );
    return;
  }

  // 3. Static scripts & styles (/assets/*, fonts, images): Cache-first with background revalidation
  if (url.pathname.startsWith('/assets/')) {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        const fetchPromise = fetch(event.request)
          .then((networkRes) => {
            if (networkRes && networkRes.status === 200) {
              const clone = networkRes.clone();
              caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
            }
            return networkRes;
          })
          .catch(() => cached);

        return cached || fetchPromise;
      })
    );
    return;
  }

  // 4. General static assets: Stale-while-revalidate
  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      const fetchPromise = fetch(event.request)
        .then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200) {
            const responseToCache = networkResponse.clone();
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(event.request, responseToCache);
            });
          }
          return networkResponse;
        })
        .catch(() => {
          if (event.request.destination === 'image') {
            return caches.match('/favicon.svg');
          }
        });

      return cachedResponse || fetchPromise;
    })
  );
});

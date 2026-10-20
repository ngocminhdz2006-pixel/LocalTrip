// LocalTrip PWA - Service Worker
// Version: 1.4.0 (Network-First Itinerary Offline Support)

const CACHE_NAME = 'localtrip-static-v5';
const OFFLINE_FALLBACK = '/LocalTrip/offline.html';

// 1. Install event: pre-cache offline page & core branding
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return Promise.allSettled([
                cache.add(new Request('/LocalTrip/offline.html', { cache: 'reload' })),
                cache.add(new Request('/LocalTrip/manifest.json', { cache: 'reload' })),
                cache.add(new Request('/LocalTrip/css/mobile-user.css?v=2', { cache: 'reload' })),
                cache.add(new Request('/LocalTrip/css/localtrip.css?v=2', { cache: 'reload' })),
                cache.add(new Request('/LocalTrip/js/image-compressor.js', { cache: 'reload' })),
                cache.add(new Request('/LocalTrip/images/icon-192.png', { cache: 'reload' }))
            ]);
        }).then(() => self.skipWaiting())
    );
});

// 2. Activate event: claim clients immediately & delete old caches
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((keys) => {
            return Promise.all(
                keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
            );
        }).then(() => self.clients.claim())
    );
});

// 3. Fetch event
self.addEventListener('fetch', (event) => {
    const request = event.request;

    // Only handle GET requests
    if (request.method !== 'GET') {
        return;
    }

    // A. Page Navigation (User clicking links, opening app, reloading)
    // Strategy: Network-First with Fallback to Cached Schedule Pages, then offline.html
    if (request.mode === 'navigate') {
        const url = new URL(request.url);
        const isOfflineScheduleRoute = (
            url.pathname.includes('/trips') ||
            url.pathname.includes('/trip/detail') ||
            url.pathname.includes('/itinerary')
        );

        event.respondWith(
            fetch(request).then(async (networkResponse) => {
                if (networkResponse && networkResponse.status === 200) {
                    if (isOfflineScheduleRoute) {
                        try {
                            const copy = networkResponse.clone();
                            const cache = await caches.open(CACHE_NAME);
                            await cache.put(request, copy);
                        } catch (cacheErr) {
                            console.warn('[SW] Caching itinerary page failed:', cacheErr);
                        }
                    }
                }
                return networkResponse;
            }).catch(async () => {
                // When offline: Check if user visited this trip or itinerary page before
                const cache = await caches.open(CACHE_NAME);

                if (isOfflineScheduleRoute) {
                    const cachedPage = await cache.match(request);
                    if (cachedPage) {
                        return cachedPage;
                    }
                    const cachedByUrl = await cache.match(request.url);
                    if (cachedByUrl) {
                        return cachedByUrl;
                    }
                }

                // If not in cache, fallback to friendly offline screen
                const cachedOffline = await cache.match(OFFLINE_FALLBACK);
                if (cachedOffline) {
                    return cachedOffline;
                }
                return (await caches.match('/LocalTrip/offline.html')) || (await caches.match('offline.html'));
            })
        );
        return;
    }

    const url = new URL(request.url);

    // B. Static Assets (CSS, JS, Images, Icons)
    const isStaticAsset = (
        url.pathname.endsWith('.css') ||
        url.pathname.endsWith('.js') ||
        url.pathname.endsWith('.png') ||
        url.pathname.endsWith('.jpg') ||
        url.pathname.endsWith('.svg') ||
        url.pathname.endsWith('.woff2') ||
        url.pathname.endsWith('manifest.json')
    );

    if (isStaticAsset) {
        event.respondWith(
            caches.match(request).then((cachedResponse) => {
                const fetchPromise = fetch(request).then((networkResponse) => {
                    if (networkResponse && networkResponse.status === 200) {
                        const copy = networkResponse.clone();
                        caches.open(CACHE_NAME).then((cache) => cache.put(request, copy));
                    }
                    return networkResponse;
                }).catch(() => {/* ignore while offline */});

                return cachedResponse || fetchPromise;
            })
        );
        return;
    }

    // C. Default: Network only
    event.respondWith(fetch(request));
});

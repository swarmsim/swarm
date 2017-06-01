// A simple, no-op service worker that takes immediate control.
// https://stackoverflow.com/a/38980776

self.addEventListener('install', () => {
  // Skip over the "waiting" lifecycle state, to ensure that our
  // new service worker is activated immediately, even if there's
  // another tab open controlled by our older service worker code.
  self.skipWaiting();

  // Clear the cache from that broken version.
  caches.keys().then(function (cachesNames) {
    //console.log('delete caches'+cachesNames)
    return Promise.all(cachesNames.map(function (cacheName) {
      console.log('delete cache'+cacheName)
      return caches.delete(cacheName)//.then(function () {
    }))
  })
  //.then(function(){console.log('all caches deleted')})
  .catch(function(e){console.warn('cache delete failed', e)})
})

{{flutter_js}}
{{flutter_build_config}}
// Fresh builds use versioned entry files; no offline worker can pin old routes.
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then((registrations) => {
    for (const registration of registrations) {
      if (registration.scope === new URL('./', document.baseURI).href) {
        registration.unregister();
      }
    }
  }).catch(console.warn);
}
_flutter.loader.load();

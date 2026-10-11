import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from './App';
import './index.css';

// Handle dynamic Vite chunk loading errors automatically (prevents blank screen on new builds/restarts)
window.addEventListener('vite:preloadError', (event) => {
  console.warn('Vite preload error detected, reloading page...', event);
  window.location.reload();
});

// PWA Service Worker management for offline capabilities
if ('serviceWorker' in navigator) {
  // Register service worker in production builds, previews, or when offline mode is enabled
  if (import.meta.env.PROD || window.location.search.includes('offline=true') || window.location.search.includes('pwa=true')) {
    window.addEventListener('load', () => {
      navigator.serviceWorker
        .register('/sw.js')
        .then((reg) => {
          console.info('✅ Bhasha Setu PWA Service Worker active (100% Offline Capable):', reg.scope);
        })
        .catch((err) => {
          console.warn('PWA Service Worker registration note:', err);
        });
    });
  }
}

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>
);

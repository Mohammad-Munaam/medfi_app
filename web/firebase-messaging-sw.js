/* eslint-disable no-undef */
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCdeROgteunu0Da4YvH56icDDurySnNndw',
  authDomain: 'medfi-a4f89.firebaseapp.com',
  projectId: 'medfi-a4f89',
  storageBucket: 'medfi-a4f89.firebasestorage.app',
  messagingSenderId: '680176477106',
  appId: '1:680176477106:web:034c54353fccd4512ff7bf',
  measurementId: 'G-H0KC18F7WG',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notificationTitle = payload?.notification?.title || 'MEDFI';
  const notificationOptions = {
    body: payload?.notification?.body || 'New emergency update received.',
    icon: '/icons/Icon-192.png',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

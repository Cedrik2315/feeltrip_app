const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Inicializamos la App de Admin para tener acceso a Firestore y Messaging
admin.initializeApp();

/**
 * FUNCIÓN 1: BIENVENIDA AL CREAR PERFIL
 * Se dispara cuando se crea un documento en la colección 'users'.
 */
exports.onNewUserWelcome = functions.firestore
    .document('users/{userId}')
    .onCreate(async (snap, context) => {
        const userData = snap.data();
        const fcmToken = userData.fcmToken;
        const firstName = userData.name || 'Explorador';

        // Si el usuario no tiene token aún, no podemos enviar la notificación
        if (!fcmToken) {
            console.log(`Usuario ${context.params.userId} creado sin FCM Token.`);
            return null;
        }

        const message = {
            token: fcmToken,
            notification: {
                title: `¡Bienvenido a la Tribu, ${firstName}! 🌍`,
                body: 'Tu racha ha comenzado. Tienes 1,000 XP esperándote en tu perfil.',
            },
            // Datos extra que Flutter puede leer incluso con la app en segundo plano
            data: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                type: 'WELCOME_BONUS',
                points: '1000'
            },
            // Configuración específica para Android (prioridad alta y sonido)
            android: {
                priority: 'high',
                notification: {
                    sound: 'default',
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                },
            },
            // Configuración específica para iOS (sonido y badge)
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                    },
                },
            },
        };

        try {
            const response = await admin.messaging().send(message);
            console.log('Notificación de bienvenida enviada:', response);
            return response;
        } catch (error) {
            console.error('Error al enviar bienvenida:', error);
            return null;
        }
    });

/**
 * FUNCIÓN 2: NOTIFICACIÓN DE LOGRO (Opcional pero recomendada)
 * Puedes llamar a esta función cuando actualices un logro en Firestore
 */
exports.onAchievementUnlocked = functions.firestore
    .document('users/{userId}/achievements/{achievementId}')
    .onCreate(async (snap, context) => {
        const achievement = snap.data();
        const userId = context.params.userId;

        // Obtenemos el token del documento del usuario padre
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const fcmToken = userDoc.data().fcmToken;

        if (!fcmToken) return null;

        const message = {
            token: fcmToken,
            notification: {
                title: '¡Nuevo Logro Desbloqueado! 🏆',
                body: `Has obtenido el trofeo: ${achievement.name}. ¡Sigue explorando!`,
            },
            data: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                type: 'ACHIEVEMENT',
            }
        };

        return admin.messaging().send(message);
    });
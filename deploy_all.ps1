# Script de despliegue automatizado para FeelTrip
Write-Host "🚀 Iniciando despliegue de FeelTrip..." -ForegroundColor Cyan

Write-Host "1. Desplegando reglas y índices de Firestore..."
firebase deploy --only firestore

Write-Host "2. Desplegando Cloud Functions..."
firebase deploy --only functions

Write-Host "3. Desplegando reglas de Storage..."
firebase deploy --only storage

Write-Host "✅ Despliegue completado con éxito." -ForegroundColor Green
Write-Host "Recuerda configurar las variables de entorno de Mercado Pago si no lo has hecho:"
Write-Host "firebase functions:config:set mercadopago.token='TU_TOKEN'"
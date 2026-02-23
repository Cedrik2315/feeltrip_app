# 🔧 SOLUCIONAR PROBLEMA DE FACTURACIÓN EN GCP

## PROBLEMA

```
Google Cloud piensa que eres EMPRESA
Pero eres PERSONA NATURAL
→ Por eso no te deja crear la BD gratuita
```

## SOLUCIÓN: CAMBIAR ESTADO FISCAL

### PASO 1: Ir a Google Cloud Console
```
https://console.cloud.google.com/
```

### PASO 2: Ir a Facturación
```
Panel izquierdo:
  Facturación  ← CLICK
```

### PASO 3: Seleccionar Cuenta de Facturación
```
Si tienes varias cuentas, selecciona la del proyecto feeltrip_app
```

### PASO 4: Editar Perfil de Facturación
```
Configuración de cuentas de facturación
  → Haz click en tu cuenta
  → Click en: "Editar perfil de facturación" (o botón similar)
```

### PASO 5: Cambiar Tipo de Contribuyente
```
Busca: "Tipo de contribuyente" o "Estado fiscal"
  → Cambia de: EMPRESA
  → A: PERSONA NATURAL o INDIVIDUAL

En RUT:
  → Ingresa: 15138868-K (con guión)
  → O: 15138868K

Otras opciones a revisar:
  ✓ Exento de Impuesto Adicional: Sí (cambiar)
  ✓ Registrado en Chile como contribuyente del IVA: No (cambiar)

Click: GUARDAR
```

### PASO 6: Esperar 5-10 minutos
```
Google Cloud actualiza la información
```

### PASO 7: Volver a Firebase
```
Vuelve a: https://console.firebase.google.com/
Proyecto: feeltrip_app
Firestore Database → Agregar base de datos

Ahora debería funcionár sin pedir facturación
```

---

## SI AÚN NO FUNCIONA

Alternativa: **Usar Modo Test de Firestore**

```
Algunos proyectos permiten Firestore en "Test mode"
sin requerir facturación

En "Agregar base de datos":
  → Busca opción: "Test mode" o "Modo prueba"
  → Eso SÍ debería ser gratis
```

---

## RESUMEN

1. Ve a Google Cloud Console
2. Facturación → Editar perfil
3. Cambia de EMPRESA a PERSONA NATURAL
4. Guarda
5. Espera 10 min
6. Vuelve a Firebase a crear la BD

Avísame cuando hayas hecho estos cambios.

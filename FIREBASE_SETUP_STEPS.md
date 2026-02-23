# 🔥 FIREBASE SETUP - PASO A PASO

## PASO 1: Crear Collection "stories"

### En Firebase Console:
```
1. Haz click en: + Create Collection
2. Nombre: stories
3. Haz click: Auto ID (genera automático)
```

### Luego completa estos campos (COPIA Y PEGA):

```
Field: id              Type: String    Value: story_001
Field: title           Type: String    Value: Mi aventura en Patagonia
Field: story           Type: String    Value: Fue increíble caminar entre los glaciares. La naturaleza es majestuosa.
Field: author          Type: String    Value: Juan Pérez
Field: userId          Type: String    Value: user123
Field: rating          Type: Number    Value: 4.8
Field: likes           Type: Number    Value: 25
Field: emotionalHighlights  Type: Array    Value: ["aventura"]
Field: createdAt       Type: Timestamp Value: (Timestamp automático)
```

**Haz click: SAVE**

---

## PASO 2: Crear Collection "agencies"

### En Firebase Console:
```
1. Vuelve a Collections (arriba)
2. Haz click en: + Create Collection
3. Nombre: agencies
4. Haz click: Auto ID
```

### Luego completa estos campos (COPIA Y PEGA):

```
Field: id              Type: String    Value: agency_001
Field: name            Type: String    Value: FeelTrip Adventures
Field: description     Type: String    Value: Agencia especializada en aventuras de naturaleza
Field: logo            Type: String    Value: https://via.placeholder.com/200
Field: city            Type: String    Value: Buenos Aires
Field: country         Type: String    Value: Argentina
Field: latitude        Type: Number    Value: -34.603
Field: longitude       Type: Number    Value: -58.381
Field: specialties     Type: Array     Value: ["adventure"]
Field: rating          Type: Number    Value: 4.8
Field: reviewCount     Type: Number    Value: 45
Field: followers       Type: Number    Value: 250
Field: verified        Type: Boolean   Value: true
Field: phoneNumber     Type: String    Value: +54 11 1234 5678
Field: email           Type: String    Value: info@feeltrip.com
Field: website         Type: String    Value: www.feeltrip.com
Field: createdAt       Type: Timestamp Value: (Timestamp automático)
```

**Haz click: SAVE**

---

## PASO 3: Verificar que existan ambas collections

```
En Firestore Database → Collections:
✅ stories (1 documento)
✅ agencies (1 documento)
```

---

## ✅ LISTO

Avísame cuando hayas creado ambas collections.

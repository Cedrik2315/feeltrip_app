# Dia 2 - Hardening de Seguridad Firebase

Fecha: 2026-03-03

## Archivos actualizados

- `firestore-rules.txt`
- `storage.rules`
- `firebase.json` (agregado bloque `storage.rules`)

## Principios aplicados

- Zero-trust por defecto: cualquier ruta no declarada queda denegada.
- Aislamiento estricto por usuario en `/users/{uid}/...`.
- Escrituras publicas reducidas a lo minimo necesario para MVP.

## Firestore - Matriz de acceso

### Permitido

- `users/{uid}`:
  - `read/create/update/delete` solo por el mismo `uid`.
- `users/{uid}/diaryEntries/{entryId}`:
  - CRUD solo por el mismo `uid`.
- `users/{uid}/stories/{storyId}`:
  - CRUD solo por el mismo `uid`.
- `users/{uid}/private/{docId}`:
  - CRUD solo por el mismo `uid`.
- `users/{uid}/cartItems/{itemId}`:
  - CRUD solo por el mismo `uid`.
- `stories/{storyId}`:
  - `read` publico.
  - `create` autenticado con `request.resource.data.userId == request.auth.uid`.
  - `update` solo autor o mutacion limitada de `likes`.
  - `delete` solo autor.
- `stories/{storyId}/comments/{commentId}`:
  - `read` publico.
  - `create` autenticado y propietario de `userId`.
  - `update` solo autor o mutacion limitada a `likes/reactions`.
  - `delete` solo autor.

### Denegado

- Escrituras en `agencies/*` y `experiences/*` (por ahora read-only en MVP).
- Cualquier otra ruta no explicitamente declarada.

## Cloud Storage - Matriz de acceso

### Permitido

- `users/{uid}/diarios/{fileName}`:
  - `read/write` solo el mismo `uid`.

### Denegado

- Cualquier otro path de Storage.

## Checklist de verificacion recomendado

1. Usuario A puede leer/escribir su perfil, diario y carrito.
2. Usuario A NO puede leer/escribir datos de Usuario B.
3. Usuario autenticado puede crear historia publica con su `userId`.
4. Usuario no autenticado NO puede crear historias/comentarios.
5. Solo autor puede borrar su comentario.
6. Subida de foto de diario funciona en `users/{uid}/diarios/*`.
7. Subida a cualquier otro path de Storage falla.

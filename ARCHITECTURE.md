# 🏗️ ARQUITECTURA - FeelTrip Nueva Features

## Diagrama General de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                     FEELTRIP APP (FLUTTER)                      │
│                                                                  │
│  ┌───────────────┐  ┌──────────────┐  ┌────────────────────┐   │
│  │  USER SCREENS │  │  CONTROLLERS │  │   SERVICES         │   │
│  │               │  │              │  │                    │   │
│  │ • Main        │  │ Experience   │  │ • StoryService     │   │
│  │ • Stories     │  │ Controller   │  │ • DiaryService     │   │
│  │ • Diary       │  │ (GetX)       │  │ • CommentService   │   │
│  │ • Reels       │  │              │  │ • SharingService   │   │
│  │ • Comments ✨ │  │ • GetX Put   │  │ • AgencyService    │   │
│  │ • AgencyProfile│ │ • Reactive   │  │ • StorageService   │   │
│  │   Screen ✨   │  │   State      │  │ • ApiService       │   │
│  └───────────────┘  └──────────────┘  └────────────────────┘   │
│         │                  │                    │                │
│         └──────────────────┼────────────────────┘                │
│                            │                                      │
│                    ┌───────▼──────────┐                          │
│                    │   MODELS         │                          │
│                    │                  │                          │
│                    │ • Experience     │                          │
│                    │ • TravelerStory  │                          │
│                    │ • DiaryEntry     │                          │
│                    │ • Comment ✨     │                          │
│                    │ • TravelAgency ✨│                          │
│                    └──────────────────┘                          │
│                                                                  │
└──────────────────────────────────────┬───────────────────────────┘
                                       │
        ┌──────────────────────────────┼──────────────────────────┐
        │                              │                          │
   ┌────▼─────┐              ┌────────▼────────┐      ┌──────────▼──┐
   │ FIRESTORE│              │  FIREBASE AUTH  │      │   EXTERNAL  │
   │ DATABASE │              │                 │      │   SERVICES  │
   │          │              │ • User Login    │      │             │
   │ Collections:            │ • User Profile  │      │ • Share+    │
   │ • users  │              │                 │      │ • URL       │
   │ • stories├─┐            └─────────────────┘      │   Launcher  │
   │   └comments│                                     └─────────────┘
   │ • agencies│
   │ • diary   │
   │ • feed    │
   └──────────┘
```

## Flujo de Datos - Comentarios

```
USER INTERACTION
        │
        ▼
   CommentsScreen
   (Flutter Widget)
        │
        ├─► Input: "Gran viaje!"
        │
        ▼
   CommentService.addComment()
        │
        ├─► Create Comment object
        │   • id: UUID
        │   • storyId: story.id
        │   • userId: auth.uid
        │   • content: "Gran viaje!"
        │   • createdAt: now()
        │
        ▼
   Firestore Write
        │
        ├─► Path: stories/{storyId}/comments/{commentId}
        │   └─► Collection: subcollection
        │
        ▼
   Firestore Triggers
   (Cloud Function - opcional)
        │
        ├─► Update story.commentCount
        ├─► Create notification
        │
        ▼
   Real-time Stream
        │
        └─► CommentsScreen listener
            ├─► getComments(storyId)
            │   └─► OrderBy createdAt DESC
            │
            ▼
        UI Update
        ├─► Show new comment
        ├─► Animate entry
        └─► Play sound (optional)
```

## Flujo de Datos - Compartir

```
USER TAPS SHARE BUTTON
        │
        ▼
   StoriesScreen
   _shareStory(story)
        │
        ├─► Generate deep link:
        │   "https://feeltrip.app/story/story_abc123"
        │
        ├─► SharingService.generateStoryDeepLink()
        │   └─► Return formatted URL
        │
        ▼
   SharingService.shareGeneral()
        │
        ├─► Build message:
        │   "🌍 [Story Title]"
        │   "[Story Description]"
        │   "[Deep Link]"
        │
        ▼
   share_plus.Share.share()
        │
        ├─► Native Share Sheet
        │   ├─ WhatsApp
        │   ├─ Instagram
        │   ├─ Facebook
        │   ├─ Email
        │   └─ etc...
        │
        ▼
   SOCIAL NETWORK
        │
        └─► User selects: WhatsApp
            │
            ├─► Opens WhatsApp
            ├─► Pre-fills message with link
            └─► User sends to contact
                │
                ▼
            CONTACT RECEIVES LINK
                │
                ├─► Clicks link
                │   "https://feeltrip.app/story/story_abc123"
                │
                ▼
            ANALYTICS TRACKING
                ├─► Log referral source
                ├─► Track user origin (WhatsApp)
                ├─► Update story view count
                └─► Credit agency/author
```

## Flujo de Datos - Agencias

```
USER WANTS TO VIEW AGENCY
        │
        ▼
   Get.to(AgencyProfileScreen(agencyId))
        │
        ▼
   AgencyProfileScreen
   FutureBuilder<TravelAgency>
        │
        ├─► agencyService.getAgencyById(agencyId)
        │
        ▼
   Firestore Read
        │
        ├─► Query: agencies/{agencyId}
        │   └─► Document fields:
        │       • name
        │       • rating
        │       • followers
        │       • specialties
        │       • contactInfo
        │       └─► etc...
        │
        ▼
   TravelAgency Object
   (Model Deserialization)
        │
        ├─► Comment.fromFirestore(doc)
        │   └─► Map Firestore fields to Dart
        │
        ▼
   UI Rendering
        │
        ├─► Header: logo + gradient
        ├─► Stats: ⭐ rating, 👥 followers
        ├─► Info: about, specialties
        ├─► Contact: phone, email, web
        ├─► Social: Instagram, Facebook
        └─► Follow button
        
USER INTERACTIONS:
        │
        ├─► Click phone → url_launcher.launch('tel:+5411...')
        ├─► Click email → url_launcher.launch('mailto:...')
        ├─► Click web → url_launcher.launch('https://...')
        ├─► Click follow → agencyService.followAgency(id)
        └─► Click share → SharingService.generateAgencyDeepLink()
```

## Estructura de Datos en Firestore

```
FIRESTORE DATABASE
│
├─ stories/{storyId}
│  ├─ id: "story_001"
│  ├─ title: "Aventura en Patagonia"
│  ├─ story: "Fue increíble..."
│  ├─ userId: "user123"
│  ├─ rating: 4.5
│  ├─ likes: 42
│  ├─ createdAt: Timestamp
│  │
│  └─ comments/{commentId}
│     ├─ id: "comment_001" ✨ NEW
│     ├─ storyId: "story_001"
│     ├─ userId: "user456"
│     ├─ userName: "Maria"
│     ├─ userAvatar: "https://..."
│     ├─ content: "Qué hermoso!"
│     ├─ reactions: ["❤️", "❤️", "😂"]
│     ├─ likes: 5
│     └─ createdAt: Timestamp
│
├─ agencies/{agencyId} ✨ NEW
│  ├─ id: "agency_001"
│  ├─ name: "FeelTrip Tours"
│  ├─ description: "Experiencias vivenciales..."
│  ├─ logo: "https://..."
│  ├─ city: "Buenos Aires"
│  ├─ country: "Argentina"
│  ├─ latitude: -34.603
│  ├─ longitude: -58.381
│  ├─ specialties: ["adventure", "cultural"]
│  ├─ rating: 4.8
│  ├─ reviewCount: 25
│  ├─ followers: 150
│  ├─ verified: true
│  ├─ experiences: ["exp_001", "exp_002"]
│  ├─ phoneNumber: "+54 11 1234 5678"
│  ├─ email: "info@feeltrip.com"
│  ├─ website: "www.feeltrip.com"
│  ├─ socialMedia: ["instagram.com/feeltrip", "facebook.com/feeltrip"]
│  └─ createdAt: Timestamp
│
├─ experiences/{experienceId}
│  └─ ... (existing structure)
│
├─ diary_entries/{entryId}
│  └─ ... (existing structure)
│
└─ users/{userId}
   └─ ... (existing structure)
```

## Matriz de Permisos - Firestore Rules

```
┌──────────────────┬─────────┬───────────┬────────────┬──────────┐
│ Acción           │ Anónimo │ Usuario   │ Propietario│ Admin    │
├──────────────────┼─────────┼───────────┼────────────┼──────────┤
│ Leer historias   │ ✅      │ ✅        │ ✅         │ ✅       │
│ Escribir historia│ ❌      │ ✅        │ ✅         │ ✅       │
│ Leer comentarios │ ✅      │ ✅        │ ✅         │ ✅       │
│ Crear comentario │ ❌      │ ✅        │ ✅         │ ✅       │
│ Editar comentario│ ❌      │ ❌        │ ✅ (propio)│ ✅       │
│ Leer agencias    │ ✅      │ ✅        │ ✅         │ ✅       │
│ Crear agencia    │ ❌      │ ✅        │ ✅         │ ✅       │
│ Editar agencia   │ ❌      │ ❌        │ ✅ (propia)│ ✅       │
│ Eliminar agencia │ ❌      │ ❌        │ ❌         │ ✅       │
│ Ver diary propio │ ❌      │ ✅        │ ✅ (propio)│ ✅       │
│ Ver diary otros  │ ❌      │ ❌        │ ❌         │ ❌       │
└──────────────────┴─────────┴───────────┴────────────┴──────────┘
```

## Ciclo de Vida - Comentario

```
1. CREATION
   └─ User types + sends
      └─ CommentService.addComment()
         └─ Generate UUID
            └─ Create Comment object
               └─ Write to Firestore

2. REAL-TIME SYNC
   └─ Cloud Firestore listener
      └─ getComments() Stream
         └─ StreamBuilder updates UI
            └─ Comment appears on screen

3. INTERACTIONS
   ├─ User adds reaction
   │  └─ CommentService.addReaction()
   │     └─ Add emoji to reactions array
   │
   ├─ User likes comment
   │  └─ CommentService.likeComment()
   │     └─ Increment likes count
   │
   └─ User replies/mentions
      └─ Creates new comment (chain)

4. DELETION
   └─ Only comment owner can delete
      └─ CommentService.deleteComment()
         └─ Remove from Firestore
            └─ Stream updates UI

5. EXPIRATION (optional)
   └─ Cloud Function (future)
      └─ Delete old comments after 30 days
         └─ Archive to BigQuery
```

## Ciclo de Vida - Agencia

```
1. REGISTRATION
   └─ Agency signs up
      └─ AgencyService.createAgency()
         └─ Generate UUID
            └─ Create TravelAgency object
               └─ Write to agencies/{id}

2. PROFILE BUILDING
   └─ Agency updates info
      └─ AgencyService.updateAgency()
         └─ Update name, description, logo
            └─ Add specialties
               └─ Connect social media links

3. EXPERIENCES LINKING
   └─ Agency adds experiences
      └─ AgencyService.addExperienceToAgency()
         └─ Add experienceId to experiences array
            └─ Cross-reference in experiences/{id}

4. RATING ACCUMULATION
   └─ Travelers rate agency
      └─ AgencyService.updateAgencyRating()
         └─ Calculate new average
            └─ Update rating field
               └─ Update reviewCount

5. FOLLOWER GROWTH
   └─ Users follow agency
      └─ AgencyService.followAgency()
         └─ Increment followers count
            └─ Create follower record

6. DISCOVERY
   └─ Users view profile
      └─ AgencyProfileScreen
         └─ Show all info
            └─ Travelers can:
               ├─ Follow
               ├─ Contact (phone/email/web)
               ├─ View experiences
               └─ See reviews/ratings
```

## Integración con GetX

```
┌─────────────────────────────────────────┐
│    GETX CONTROLLER PATTERN              │
│    (ExperienceController)               │
└─────────────────────────────────────────┘
         │
         ├─► Observable variables
         │   ├─ stories
         │   ├─ experiences
         │   └─ selectedStory
         │
         ├─► Methods
         │   ├─ loadAllData()
         │   ├─ createStory()
         │   ├─ likeStory()
         │   ├─ deleteStory()
         │   └─ updateUI()
         │
         └─► Lifecycle
             ├─ onInit()
             └─ onClose()

USAGE IN UI:
    Obx(() => Text(controller.stories.length))
    │
    └─► Auto-rebuilds when stories changes
```

---

## 📊 Resumen de Componentes

| Capa | Componente | Líneas | Dependencias |
|------|-----------|--------|--------------|
| **Models** | CommentModel | 200 | Firebase |
| | AgencyModel | 180 | Firebase |
| **Services** | CommentService | 120 | Firestore |
| | SharingService | 85 | share_plus |
| | AgencyService | 170 | Firestore |
| **Screens** | CommentsScreen | 310 | GetX |
| | AgencyProfileScreen | 340 | url_launcher |
| **Controllers** | ExperienceController | 427 | (existing) |
| **Total** | | **1,832** | |

---

**Arquitectura escalable, mantenible y lista para producción ✅**

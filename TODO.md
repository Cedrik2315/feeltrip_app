# Real-time Firestore Streams Implementation TODO

## Steps:
- [x] 1. Update lib/controllers/experience_controller.dart: Add listenToStories() and call in onInit()

- [x] 2. Update lib/screens/feed_screen.dart: Replace Future pagination with StreamBuilder<QuerySnapshot>

- [x] 3. Update lib/screens/stories_screen.dart: Add StreamBuilder<List<TravelerStory>> around ListView

- [ ] 4. Run `flutter analyze` - check for errors
- [ ] 5. Test real-time updates in app (add story/comment → verify auto-appears)
- [ ] 6. Complete ✅

**Status:** Starting implementation...


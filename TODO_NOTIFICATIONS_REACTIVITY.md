# TODO: Full Reactivity Notifications Implementation

## Approved Plan Steps (Total: 10)

### [x] 3. Add lib/services/notification_service.dart: sendCommentNotification(String targetId, String title, String storyId)\n### [x] 4. Update lib/services/comment_service.dart addComment(): after save, fetch story.agencyId, if exists sendCommentNotification(agencyOwnerUid)
### [ ] 5. lib/core/router/route_names.dart: add static const String commentsDetail = '/comments/:storyId';
### [ ] 6. lib/core/router/app_router.dart: add GoRoute(path: RouteNames.commentsDetail, builder: (context, state) => CommentsScreen(storyId: state.pathParameters['storyId']!))
### [x] 7. lib/screens/comments_screen.dart: add didChangeDependencies or initState to check/request FCM permission if first time/denied
### [x] 8. lib/main.dart: listen NotificationService().navigationStream, use GoRouter.go based on type/id (e.g. if 'story_comments' -> '/comments/$id')
### [x] 9. Update providers.dart if needed (commentProvider), TODO_COMMENTS.md, TODO_deep_links.md
### [x] 10. Test: dart analyze, flutter run, manual test comment notification + deep link

**Current Progress: Starting Step 1**
**Dependencies: AgencyService, assume story has agencyId, agency has ownerUid after step1**

Run `dart analyze` after each major step.


import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Service to handle incoming deep links for the app.
///
/// This enables:
/// - Deep links that work even when app is not installed
/// - Preview cards on WhatsApp and social media
/// - Proper attribution tracking
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  final _linkController = StreamController<Uri>.broadcast();

  /// Callback for navigation from deep links
  void Function(Uri uri)? onDeepLinkReceived;

  /// Stream of incoming deep links
  Stream<Uri> get linkStream => _linkController.stream;

  /// Initialize the deep link service
  Future<void> initialize() async {
    try {
      // Handle initial link when app is launched from terminated state
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }

      // Listen for links when app is already running
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) => _handleUri(uri),
        onError: (Object error, StackTrace st) {
          _log('DeepLink error: $error', isError: true);
          debugPrint('Stack trace: $st');
        },
      );

      _log('DeepLinkService initialized');
    } catch (e, st) {
      _log('Failed to initialize DeepLinkService: $e', isError: true);
      debugPrint('Stack trace: $st');
    }
  }

  /// Handle incoming deep link
  void _handleUri(Uri uri) {
    _log('Deep link received: $uri');
    _linkController.add(uri);

    // Also notify the navigation system via callback
    if (onDeepLinkReceived != null) {
      onDeepLinkReceived!(uri);
    }
  }

  /// Navigate to appropriate screen based on deep link
  /// Returns the route path and arguments for navigation
  Map<String, dynamic>? parseDeepLink(Uri uri) {
    final isWebScheme = uri.scheme == 'http' || uri.scheme == 'https';
    final pathSegments =
        uri.pathSegments.where((segment) => segment.isNotEmpty).toList();

    // Supports both:
    // - https://feeltrip.app/story/123  -> pathSegments ["story","123"]
    // - feeltrip://story/123            -> host "story", pathSegments ["123"]
    final String firstSegment;
    final List<String> restSegments;

    if (!isWebScheme && uri.host.isNotEmpty) {
      firstSegment = uri.host;
      restSegments = pathSegments;
    } else if (pathSegments.isNotEmpty) {
      firstSegment = pathSegments.first;
      restSegments = pathSegments.skip(1).toList();
    } else {
      return null;
    }

    // Build navigation arguments
    Map<String, dynamic>? arguments;

    switch (firstSegment) {
      case 'story':
        // Format: /story/{storyId}
        if (restSegments.isNotEmpty) {
          arguments = {'storyId': restSegments.first};
        }
        break;
      case 'agency':
        // Format: /agency/{agencyId}
        if (restSegments.isNotEmpty) {
          arguments = {'agencyId': restSegments.first};
        }
        break;
      case 'trip':
        // Format: /trip/{tripId}
        if (restSegments.isNotEmpty) {
          arguments = {'tripId': restSegments.first};
        }
        break;
      case 'join':
        // Format: /join/{referralCode} - for referrals
        if (restSegments.isNotEmpty) {
          arguments = {'referralCode': restSegments.first};
        }
        break;
      case 'experience':
        // Format: /experience/{experienceId}
        if (restSegments.isNotEmpty) {
          arguments = {'experienceId': restSegments.first};
        }
        break;
      default:
        _log('Unknown deep link path: ${uri.path}');
    }

    // Return the navigation data
    if (arguments != null) {
      return {
        'path': '/$firstSegment',
        'arguments': arguments,
      };
    }
    return null;
  }

  /// Store pending navigation to be consumed by the app
  Map<String, dynamic>? _pendingNavigation;

  /// Get and clear pending navigation
  Map<String, dynamic>? consumePendingNavigation() {
    final nav = _pendingNavigation;
    _pendingNavigation = null;
    return nav;
  }

  /// Create a share link for a story
  Future<String> createStoryLink(String storyId) async {
    return 'https://feeltrip.app/story/$storyId';
  }

  /// Create a share link for an agency
  Future<String> createAgencyLink(String agencyId) async {
    return 'https://feeltrip.app/agency/$agencyId';
  }

  /// Create a share link for a trip/experience
  Future<String> createTripLink(String tripId) async {
    return 'https://feeltrip.app/trip/$tripId';
  }

  /// Create a share link for referrals
  Future<String> createReferralLink(String referralCode) async {
    return 'https://feeltrip.app/join/$referralCode';
  }

  /// Create a share link for an experience
  Future<String> createExperienceLink(String experienceId) async {
    return 'https://feeltrip.app/experience/$experienceId';
  }

  /// Internal logging helper
  void _log(String message, {bool isError = false}) {
    if (!kReleaseMode) {
      if (isError) {
        debugPrint('[DeepLinkService ERROR] $message');
      } else {
        debugPrint('[DeepLinkService] $message');
      }
    }
  }

  /// Dispose the service
  void dispose() {
    _linkSubscription?.cancel();
    _linkController.close();
  }
}

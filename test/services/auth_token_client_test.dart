import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:feeltrip_app/services/api_service.dart';

class _CapturingClient extends http.BaseClient {
  http.BaseRequest? lastRequest;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    return http.StreamedResponse(
      Stream.value(utf8.encode('{}')),
      200,
      headers: const {'content-type': 'application/json'},
    );
  }
}

void main() {
  group('AuthTokenClient', () {
    test('agrega Authorization cuando hay token', () async {
      final inner = _CapturingClient();
      final client = AuthTokenClient(
        inner,
        tokenProvider: () async => 'abc123',
      );

      await client.get(Uri.parse('https://example.com/resource'));

      expect(inner.lastRequest, isNotNull);
      expect(inner.lastRequest!.headers['Authorization'], 'Bearer abc123');
    });

    test('no agrega Authorization cuando no hay token', () async {
      final inner = _CapturingClient();
      final client = AuthTokenClient(
        inner,
        tokenProvider: () async => null,
      );

      await client.get(Uri.parse('https://example.com/resource'));

      expect(inner.lastRequest, isNotNull);
      expect(inner.lastRequest!.headers.containsKey('Authorization'), isFalse);
    });

    test('conserva otros headers de la request', () async {
      final inner = _CapturingClient();
      final client = AuthTokenClient(
        inner,
        tokenProvider: () async => 'token-x',
      );

      await client.post(
        Uri.parse('https://example.com/resource'),
        headers: const {'Content-Type': 'application/json'},
        body: '{}',
      );

      expect(inner.lastRequest, isNotNull);
      expect(inner.lastRequest!.headers['Content-Type'], 'application/json');
      expect(inner.lastRequest!.headers['Authorization'], 'Bearer token-x');
    });
  });
}

import 'package:sakinah_daily/core/services/remote_content_api_client.dart';

class FakeContentHttpRequest {
  const FakeContentHttpRequest({
    required this.uri,
    required this.headers,
    this.method = 'GET',
    this.body,
  });

  final Uri uri;
  final Map<String, String> headers;
  final String method;
  final Object? body;
}

class FakeContentHttpClient implements ContentHttpClient {
  FakeContentHttpClient(this.routes);

  final Map<String, ContentHttpResponse> routes;
  final List<FakeContentHttpRequest> requests = [];

  @override
  Future<ContentHttpResponse> get(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    requests.add(FakeContentHttpRequest(
      uri: uri,
      headers: Map<String, String>.unmodifiable(headers),
    ));
    return routes[uri.toString()] ??
        const ContentHttpResponse(
          statusCode: 404,
          body: '{"error":"not_found"}',
        );
  }

  @override
  Future<ContentHttpResponse> postJson(
    Uri uri, {
    required Object body,
    Map<String, String> headers = const {},
  }) async {
    requests.add(FakeContentHttpRequest(
      uri: uri,
      headers: Map<String, String>.unmodifiable(headers),
      method: 'POST',
      body: body,
    ));
    return routes[uri.toString()] ??
        const ContentHttpResponse(
          statusCode: 404,
          body: '{"error":"not_found"}',
        );
  }
}

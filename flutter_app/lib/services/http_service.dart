import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../utils/logger.dart';

class HttpService {
  static const String baseUrl = 'http://localhost:8081';

  // Get headers with authentication
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    // Add Firebase auth token if user is signed in
    if (AuthService.isSignedIn()) {
      final token = await AuthService.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request with authentication
  static Future<http.Response> get(String endpoint) async {
    final stopwatch = Stopwatch()..start();
    final userId = AuthService.getUserId();
    
    try {
      MixologistLogger.debug('🌐 HTTP GET $endpoint', extra: {
        'user_id': userId,
        'endpoint': endpoint,
        'method': 'GET'
      });
      
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await http.get(uri, headers: headers);
      stopwatch.stop();
      
      MixologistLogger.logHttpRequest('GET', endpoint,
        userId: userId,
        statusCode: response.statusCode,
        responseTimeMs: stopwatch.elapsedMilliseconds
      );
      
      return response;
    } catch (e) {
      stopwatch.stop();
      MixologistLogger.error('❌ HTTP GET $endpoint failed', error: e, extra: {
        'user_id': userId,
        'endpoint': endpoint,
        'method': 'GET',
        'response_time_ms': stopwatch.elapsedMilliseconds
      });
      rethrow;
    }
  }

  // POST request with authentication
  static Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');
    
    return await http.post(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  // POST request with form data and authentication
  static Future<http.Response> postForm(String endpoint, Map<String, String> fields) async {
    final stopwatch = Stopwatch()..start();
    final userId = AuthService.getUserId();
    
    try {
      MixologistLogger.debug('📤 HTTP POST FORM $endpoint', extra: {
        'user_id': userId,
        'endpoint': endpoint,
        'method': 'POST',
        'field_count': fields.length
      });
      
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add Firebase auth token if user is signed in
      if (AuthService.isSignedIn()) {
        final token = await AuthService.getIdToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      request.fields.addAll(fields);
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();
      
      MixologistLogger.logHttpRequest('POST', endpoint,
        userId: userId,
        statusCode: response.statusCode,
        responseTimeMs: stopwatch.elapsedMilliseconds,
        extra: {'type': 'form', 'field_count': fields.length}
      );
      
      return response;
    } catch (e) {
      stopwatch.stop();
      MixologistLogger.error('❌ HTTP POST FORM $endpoint failed', error: e, extra: {
        'user_id': userId,
        'endpoint': endpoint,
        'method': 'POST',
        'response_time_ms': stopwatch.elapsedMilliseconds
      });
      rethrow;
    }
  }

  // PUT request with authentication
  static Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');
    
    return await http.put(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  // DELETE request with authentication
  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');
    
    return await http.delete(uri, headers: headers);
  }

  // Upload file with authentication
  static Future<http.Response> uploadFile(String endpoint, String filePath, List<int> fileBytes) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    // Add Firebase auth token if user is signed in
    if (AuthService.isSignedIn()) {
      final token = await AuthService.getIdToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: filePath.split('/').last,
    ));

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
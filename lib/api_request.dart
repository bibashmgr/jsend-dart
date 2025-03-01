import 'dart:convert';

import 'package:http/http.dart' as http;

class APIRequest {
  static String? base;

  static final Map<String, Function> _acceptedMethods = {
    'GET': http.get,
    'POST': http.post,
    'PUT': http.put,
    'DELETE': http.delete,
    'PATCH': http.patch,
  };
  late String _url;
  late String _method;
  Map<String, String> _headers = {};
  Map<String, String> get headers {
    return _headers;
  }

  set headers(Map<String, String> h) {
    _headers.addAll(h);
  }

  Map<String, dynamic>? _payload = {};
  // ignore: prefer_final_fields
  static Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json'
  };

  // ignore: always_declare_return_types
  static addDefaultHeaders(Map<String, String> h) {
    _defaultHeaders.addAll(h);
  }

  // ignore: always_declare_return_types
  static removeDefaultHeaders(Map<String, String> h) {
    h.forEach((key, value) {
      _defaultHeaders.remove(key);
    });
  }

  APIRequest(
      {String? url,
      String? path,
      Map<String, String>? headers,
      Map<String, dynamic>? payload,
      String method = 'GET'}) {
    _headers = {..._defaultHeaders};
    if (headers != null) {
      _headers = {...headers};
    }
    if (url != null && path != null) {
      throw Exception('Only url or path is accepted.');
    }
    if (url == null && path == null) {
      throw Exception('one of url or path is required.');
    } else {
      if (base == null && path != null) {
        throw Exception(
            'Cannot proceed to request uri when base is not set. Please set base first in order to request using uri.');
      }
    }
    if (path != null) {
      _url = base! + ((path[0] == '/') ? path.substring(1) : path);
    }
    if (url != null) _url = url;
    if (!_acceptedMethods.containsKey(method)) {
      throw Exception("Unsupported method '$method'.");
    }
    _method = method;
    _payload = payload;
  }
  void clearHeaders() {
    _headers = {};
  }

  void removeHeader(key) {
    if (_headers.containsKey(key)) {
      _headers.remove(key);
    }
  }

  Future<http.Response> send() {
    switch (_method) {
      case 'GET':
      case 'DELETE':
        return _acceptedMethods[_method]!(Uri.parse(_url), headers: _headers);
      default:
        return _acceptedMethods[_method]!(Uri.parse(_url),
            headers: _headers, body: jsonEncode(_payload));
    }
  }
}

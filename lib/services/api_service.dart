class ApiService {
  static const String baseUrl = 'http://localhost:5278/api';

  static Map<String, String> getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null){
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
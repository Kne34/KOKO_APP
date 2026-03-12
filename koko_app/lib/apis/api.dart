import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String urlPath = "http://10.0.2.2:3000";

Future<(bool, String)> login(String email, password) async {
  String url = "$urlPath/api/auth/login";
  var response = await post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email, "password": password}),
  );

  var data = json.decode(response.body);
  if (response.statusCode == 200 && data['success'] == true) {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("token", data['data']['token']);
    prefs.setString("username", data['data']['username']);
    prefs.setString('theme', data['data']['theme']);
    prefs.setInt('userId', data['data']['id']);
    return (true, data["message"].toString());
  }

  return (false, data["message"].toString());
}

Future<(bool, String)> logout() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  try {
    var response = await post(
      Uri.parse('$urlPath/api/auth/logout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );
    var data = jsonDecode(response.body);
    return (data['success'] == true, data['message'].toString());
  } finally {
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('theme');
    await prefs.remove('userId');
  }
}

Future<(bool, String)> register(
  String username,
  String email,
  String password,
) async {
  var response = await post(
    Uri.parse('$urlPath/api/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': username,
      'email': email,
      'password': password,
    }),
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 201 && data['success'] == true) {
    return (true, data['message'].toString());
  }

  return (false, data['message'].toString());
}

Future<void> updateTheme(bool isDark) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final userId = prefs.getInt('userId') ?? 0;
  final theme = isDark ? 'dark' : 'light';
  await put(
    Uri.parse('$urlPath/api/users/$userId/theme'),
    headers: {'Content-Type': 'application/json', 'Authorization': token},
    body: jsonEncode({'theme': theme}),
  );
  prefs.setString('theme', theme);
}

Future<(bool, dynamic)> getProducts() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  var response = await get(
    Uri.parse('$urlPath/api/products'),
    headers: {'Content-Type': 'application/json', 'Authorization': token},
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 201 && data['success'] == true) {
    return (true, data['data']);
  }

  return (false, data['message'].toString());
}

Future<(bool, dynamic)> getProductById(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  var response = await get(
    Uri.parse('$urlPath/api/products/$id'),
    headers: {'Content-Type': 'application/json', 'Authorization': token},
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success'] == true) {
    return (true, data['data']);
  }

  return (false, data['message'].toString());
}

Future<(bool, dynamic)> getReviews(int productId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  var response = await get(
    Uri.parse('$urlPath/api/products/$productId/reviews'),
    headers: {'Content-Type': 'application/json', 'Authorization': token},
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success'] == true) {
    return (true, data['data']);
  }

  return (false, data['message'].toString());
}

Future<(bool, String)> postReview(
  int productId,
  int rating,
  String comment,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final username = prefs.getString('username') ?? '';

  var response = await post(
    Uri.parse('$urlPath/api/products/$productId/reviews'),
    headers: {'Content-Type': 'application/json', 'Authorization': token},
    body: jsonEncode({
      'username': username,
      'rating': rating,
      'comment': comment,
    }),
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 201 && data['success'] == true) {
    return (true, data['message'].toString());
  }

  return (false, data['message'].toString());
}

Future<(bool, String)> deleteReview(int productId, int reviewId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  var response = await delete(
    Uri.parse('$urlPath/api/products/$productId/reviews/$reviewId'),
    headers: {'Content-Type': 'application/json', 'Authorization': token},
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success'] == true) {
    return (true, data['message'].toString());
  }

  return (false, data['message'].toString());
}

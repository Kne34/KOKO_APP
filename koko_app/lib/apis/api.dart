import 'dart:convert';
import 'dart:io';
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
    await prefs.clear();
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
    headers: {'Content-Type': 'application/json', 'token': token},
    body: jsonEncode({'theme': theme}),
  );
  prefs.setString('theme', theme);
}

Future<(bool, dynamic)> getProducts() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  var response = await get(
    Uri.parse('$urlPath/api/products'),
    headers: {'Content-Type': 'application/json', 'token': token},
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success'] == true) {
    return (true, data['data']);
  }

  return (false, data['message'].toString());
}

Future<(bool, dynamic)> getProductById(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  var response = await get(
    Uri.parse('$urlPath/api/products/$id'),
    headers: {'Content-Type': 'application/json', 'token': token},
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
    headers: {'Content-Type': 'application/json', 'token': token},
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
    headers: {'Content-Type': 'application/json', 'token': token},
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
    headers: {'Content-Type': 'application/json', 'token': token},
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success'] == true) {
    return (true, data['message'].toString());
  }

  return (false, data['message'].toString());
}

Future<(bool, String)> updateAccount(
  String? username,
  String? email,
  String? password,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final userId = prefs.getInt('userId') ?? 0;

  var response = await put(
    Uri.parse('$urlPath/api/users/$userId'),
    headers: {'Content-Type': 'application/json', 'token': token},
    body: jsonEncode({
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
    }),
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success'] == true) {
    if (username != null) prefs.setString('username', username);
    return (true, data['message'].toString());
  }

  return (false, data['message'].toString());
}

Future<(bool, String)> deleteAccount() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final userId = prefs.getInt('userId') ?? 0;

  var response = await delete(
    Uri.parse('$urlPath/api/users/$userId'),
    headers: {'Content-Type': 'application/json', 'token': token},
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success'] == true) {
    await prefs.clear();
    return (true, data['message'].toString());
  }

  return (false, data['message'].toString());
}

Future<(bool, dynamic)> addProduct(
  String name,
  String description,
  int price,
  String category,
  int stock,
  File? imageFile,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  var request = MultipartRequest('POST', Uri.parse('$urlPath/api/products'));

  request.headers['token'] = token;
  request.fields['name'] = name;
  request.fields['description'] = description;
  request.fields['price'] = price.toString();
  request.fields['category'] = category;
  request.fields['stock'] = stock.toString();

  if (imageFile != null) {
    final extension = imageFile.path.split('.').last.toLowerCase();
    final mimeType =
        {
          'jpg': 'image/jpeg',
          'jpeg': 'image/jpeg',
          'png': 'image/png',
          'webp': 'image/webp',
        }[extension] ??
        'image/jpeg';

    request.files.add(
      await MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ),
    );
  }

  var streamedResponse = await request.send();
  var response = await Response.fromStream(streamedResponse);
  var data = jsonDecode(response.body);

  if (response.statusCode == 201 && data['success'] == true) {
    return (true, data['data']);
  }

  return (false, data['message'].toString());
}

Future<(bool, dynamic)> updateProduct(
  int id,
  String? name,
  String? description,
  int? price,
  String? category,
  int? stock,
  File? imageFile,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  var request = MultipartRequest('PUT', Uri.parse('$urlPath/api/products/$id'));

  request.headers['token'] = token;
  if (name != null) request.fields['name'] = name;
  if (description != null) request.fields['description'] = description;
  if (price != null) request.fields['price'] = price.toString();
  if (category != null) request.fields['category'] = category;
  if (stock != null) request.fields['stock'] = stock.toString();

  if (imageFile != null) {
    final extension = imageFile.path.split('.').last.toLowerCase();
    final mimeType =
        {
          'jpg': 'image/jpeg',
          'jpeg': 'image/jpeg',
          'png': 'image/png',
          'webp': 'image/webp',
        }[extension] ??
        'image/jpeg';

    request.files.add(
      await MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ),
    );
  }

  var streamedResponse = await request.send();
  var response = await Response.fromStream(streamedResponse);
  var data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success'] == true) {
    return (true, data['data']);
  }

  return (false, data['message'].toString());
}

Future<(bool, String)> deleteProduct(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  var response = await delete(
    Uri.parse('$urlPath/api/products/$id'),
    headers: {'Content-Type': 'application/json', 'token': token},
  );

  var data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success'] == true) {
    return (true, data['message'].toString());
  }

  return (false, data['message'].toString());
}

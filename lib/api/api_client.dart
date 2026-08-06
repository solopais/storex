import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'auth_service.dart';

/// StoreX 后端 API 客户端
/// 接口基址：https://storex.solopai.cn/api.php?route=xxx
class ApiClient {
  static const String base = 'https://storex.solopai.cn/api.php?route=';
  static final ApiClient instance = ApiClient._();

  ApiClient._();

  final http.Client _client = http.Client();

  Map<String, String> get _headers {
    final h = <String, String>{'Accept': 'application/json'};
    final t = AuthService.instance.token;
    if (t != null && t.isNotEmpty) h['Authorization'] = 'Bearer $t';
    return h;
  }

  Future<Map<String, dynamic>> _get(String route,
      [Map<String, String>? params]) async {
    final uri = Uri.parse(base + route);
    final url = params == null
        ? uri
        : uri.replace(queryParameters: {...uri.queryParameters, ...params});
    final res = await _client.get(url, headers: _headers);
    return _decode(res);
  }

  Future<Map<String, dynamic>> _post(
      String route, Map<String, dynamic> body) async {
    final url = Uri.parse(base + route);
    final res = await _client.post(
      url,
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    final charset = res.headers['content-type']?.contains('utf-8') ?? false;
    final raw = charset ? res.body : utf8.decode(res.bodyBytes);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    throw Exception('请求失败 (HTTP ${res.statusCode})');
  }

  // ---------- 公开接口 ----------

  Future<SiteConfig> getConfig() async {
    final j = await _get('config');
    return SiteConfig.fromJson(j['data'] ?? {});
  }

  Future<List<Category>> getCategories() async {
    final j = await _get('categories');
    final list = (j['data'] as List?) ?? [];
    return list.map((e) => Category.fromJson(e)).toList();
  }

  Future<List<Slide>> getSlides() async {
    final j = await _get('slides');
    final list = (j['data'] as List?) ?? [];
    return list.map((e) => Slide.fromJson(e)).toList();
  }

  Future<List<App>> getApps({
    int categoryId = 0,
    int page = 1,
    String sort = 'new',
    int perPage = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'sort': sort,
    };
    if (categoryId > 0) params['cat'] = categoryId.toString();
    final j = await _get('apps', params);
    final list = (j['data'] as List?) ?? [];
    return list.map((e) => App.fromJson(e)).toList();
  }

  Future<App> getApp(int id) async {
    final j = await _get('app/$id');
    if (j['ok'] != true) throw Exception(j['msg'] ?? '应用不存在');
    return App.fromJson(j['data'] ?? {});
  }

  Future<List<App>> search(String q, {int perPage = 20}) async {
    final j = await _get('search', {'q': q, 'per_page': perPage.toString()});
    final list = (j['data'] as List?) ?? [];
    return list.map((e) => App.fromJson(e)).toList();
  }

  // ---------- 鉴权接口 ----------

  Future<User> login(String username, String password) async {
    final j = await _post('login', {
      'username': username,
      'password': password,
    });
    if (j['ok'] != true) throw Exception(j['msg'] ?? '登录失败');
    await AuthService.instance.setToken(j['token']);
    return User.fromJson(j['user'] ?? {});
  }

  Future<User> me() async {
    final j = await _get('me');
    if (j['ok'] != true) throw Exception(j['msg'] ?? '未登录');
    return User.fromJson(j['data'] ?? {});
  }

  Future<bool> toggleFavorite(int appId) async {
    final j = await _post('favorite', {'app_id': appId});
    if (j['ok'] != true) throw Exception(j['msg'] ?? '操作失败');
    return j['is_favorite'] ?? false;
  }

  Future<List<App>> getFavorites({int page = 1, int perPage = 20}) async {
    final j = await _get('favorites', {
      'page': page.toString(),
      'per_page': perPage.toString(),
    });
    final list = (j['data'] as List?) ?? [];
    return list.map((e) => App.fromJson(e)).toList();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'auth_service.dart';

/// StoreX 后端 API 客户端
/// 主接口：https://storex.solopai.cn/api.php?route=xxx
/// 移动端既有接口：https://storex.solopai.cn/mobile/ajax/xxx
class ApiClient {
  static const String base = 'https://storex.solopai.cn/api.php?route=';
  static const String ajaxBase = 'https://storex.solopai.cn/mobile/ajax/';
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
    return _decode(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(
      String route, Map<String, dynamic> body) async {
    final url = Uri.parse(base + route);
    final res = await _client.post(
      url,
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(res) as Map<String, dynamic>;
  }

  Future<dynamic> _ajax(String path,
      {Map<String, String>? params,
      String method = 'GET',
      Map<String, String>? form,
      Map<String, dynamic>? jsonBody}) async {
    final uri = Uri.parse(ajaxBase + path);
    final url = params == null
        ? uri
        : uri.replace(queryParameters: {...uri.queryParameters, ...params});
    late final http.Response res;
    if (method == 'POST') {
      if (form != null) {
        res = await _client.post(
          url,
          headers: {
            ..._headers,
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          body: form,
        );
      } else {
        res = await _client.post(
          url,
          headers: {..._headers, 'Content-Type': 'application/json'},
          body: jsonEncode(jsonBody ?? {}),
        );
      }
    } else {
      res = await _client.get(url, headers: _headers);
    }
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    final charset = res.headers['content-type']?.contains('utf-8') ?? false;
    final raw = charset ? res.body : utf8.decode(res.bodyBytes);
    if (res.statusCode >= 200 && res.statusCode < 300) return jsonDecode(raw);
    throw Exception('请求失败 (HTTP ${res.statusCode})');
  }

  // ---------- 公开接口 ----------

  Future<SiteConfig> getConfig() async =>
      SiteConfig.fromJson((await _get('config'))['data'] ?? {});

  Future<List<Category>> getCategories() async =>
      ((await _get('categories'))['data'] as List? ?? [])
          .map((e) => Category.fromJson(e))
          .toList();

  Future<List<Slide>> getSlides() async =>
      ((await _get('slides'))['data'] as List? ?? [])
          .map((e) => Slide.fromJson(e))
          .toList();

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
    return ((j['data'] as List?) ?? []).map((e) => App.fromJson(e)).toList();
  }

  /// 带分页信息的应用列表（首页「全部应用」/ 热门排行 / VIP专属 二级页用）
  /// vip: null=不过滤，true=仅VIP，false=仅免费
  Future<AppsPage> getAppsPaged({
    int categoryId = 0,
    int page = 1,
    String sort = 'new',
    int perPage = 12,
    bool? vip,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'sort': sort,
    };
    if (categoryId > 0) params['cat'] = categoryId.toString();
    if (vip != null) params['vip'] = vip ? '1' : '0';
    return AppsPage.fromJson(await _get('apps', params));
  }

  Future<App> getApp(int id) async {
    final j = await _get('app/$id');
    if (j['ok'] != true) throw Exception(j['msg'] ?? '应用不存在');
    return App.fromJson(j['data'] ?? {});
  }

  Future<List<App>> search(String q, {int perPage = 20}) async =>
      ((await _get('search', {'q': q, 'per_page': perPage.toString()}))
                  ['data'] as List? ??
              [])
          .map((e) => App.fromJson(e))
          .toList();

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

  Future<List<App>> getFavorites({int page = 1, int perPage = 20}) async =>
      ((await _get('favorites',
                  {'page': page.toString(), 'per_page': perPage.toString()}))
              ['data'] as List? ??
          [])
          .map((e) => App.fromJson(e))
          .toList();

  // ---------- 用户 / 关注 ----------

  Future<UserProfile> getUser(int id) async {
    final j = await _get('user/$id');
    if (j['ok'] != true) throw Exception(j['msg'] ?? '用户不存在');
    return UserProfile.fromJson(j['data'] ?? {});
  }

  Future<Map<String, dynamic>> toggleFollow(int id) async {
    final j = await _post('follow', {'user_id': id});
    if (j['ok'] != true) throw Exception(j['msg'] ?? '操作失败');
    return j;
  }

  Future<List<FollowListUser>> getFollowers(int id, {int page = 1}) async =>
      ((await _ajax('followers_list.php',
                  params: {'id': id.toString(), 'page': page.toString()}))
              as List? ??
          [])
          .map((e) => FollowListUser.fromJson(e))
          .toList();

  Future<List<FollowListUser>> getFollowing(int id, {int page = 1}) async =>
      ((await _ajax('following_list.php',
                  params: {'id': id.toString(), 'page': page.toString()}))
              as List? ??
          [])
          .map((e) => FollowListUser.fromJson(e))
          .toList();

  // ---------- 文章 / 评论 ----------

  /// 全部文章（每页 10 条，与 mobile/ajax/articles.php 一致）
  Future<ArticlesPage> getArticlesPage({int page = 1}) async =>
      ArticlesPage.fromJson(await _get('articles', {'page': page.toString()}));

  Future<List<Article>> getArticles({int page = 1}) async =>
      (await getArticlesPage(page: page)).items;

  Future<ArticleDetail> getArticle(int id) async {
    final j = await _get('article/$id');
    if (j['ok'] != true) throw Exception(j['msg'] ?? '文章不存在');
    return ArticleDetail.fromJson(j);
  }

  /// 评论分页（带 has_more / is_admin / me_id，走 api.php token 鉴权）
  Future<CommentsPage> getCommentsPage(String type, int id,
          {int page = 1}) async =>
      CommentsPage.fromJson(await _get('comments', {
        'target_type': type,
        'target_id': id.toString(),
        'page': page.toString(),
      }));

  Future<List<Comment>> getComments(String type, int id,
          {int page = 1}) async =>
      (await getCommentsPage(type, id, page: page)).comments;

  Future<void> postComment(String type, int id, String content,
      {int? parentId}) async {
    final body = <String, dynamic>{
      'target_type': type,
      'target_id': id,
      'content': content,
    };
    if (parentId != null) body['parent_id'] = parentId;
    final j = await _post('comments', body);
    if (j['ok'] != true) throw Exception(j['msg'] ?? '评论失败');
  }

  Future<void> deleteComment(int id) async {
    final res = await _client.delete(
      Uri.parse('${base}comments'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    final j = _decode(res);
    if (j is Map && j['ok'] != true) throw Exception(j['msg'] ?? '删除失败');
  }

  // ---------- 发现朋友 ----------

  Future<List<DiscoverUser>> getDiscoverUsers() async {
    final d = await _ajax('discover_users.php');
    final list = (d is Map && d['users'] is List) ? d['users'] : [];
    return (list as List).map((e) => DiscoverUser.fromJson(e)).toList();
  }

  Future<void> toggleDiscoverFollow(int uid) async {
    final d = await _ajax('discover_users.php',
        method: 'POST', form: {'toggle_follow': uid.toString()});
    if (d is Map && d['ok'] == false) throw Exception(d['msg'] ?? '操作失败');
  }

  // ---------- Epic ----------

  Future<List<EpicGame>> getEpic() async {
    final d = await _ajax('epic_free.php');
    if (d is Map && d['ok'] == true) {
      return (d['games'] as List? ?? [])
          .map((e) => EpicGame.fromJson(e))
          .toList();
    }
    return [];
  }

  // ---------- 消息 ----------

  Future<NotifResult> getNotifications({int page = 1}) async {
    final d =
        await _ajax('notifications.php', params: {'page': page.toString()});
    return NotifResult.fromJson(d is Map ? d : {});
  }

  Future<void> markNotificationsRead() async {
    await _ajax('notifications.php',
        method: 'POST', form: {'mark_read': 'notifications'});
  }

  Future<UnreadCount> getUnread() async {
    final d = await _ajax('unread.php');
    return UnreadCount.fromJson(d is Map ? d : {});
  }

  Future<Map<String, dynamic>> getMessagesSummary() async => await _get('messages');

  // ---------- 聊天 ----------

  Future<List<ChatMessage>> getGroupMessages(int gid) async {
    final d =
        await _ajax('group_messages.php', params: {'gid': gid.toString()});
    return (d is List ? d : []).map((e) => ChatMessage.fromJson(e)).toList();
  }

  Future<List<ChatMessage>> getConversation(int uid) async {
    final d =
        await _ajax('conversation.php', params: {'uid': uid.toString()});
    return (d is List ? d : []).map((e) => ChatMessage.fromJson(e)).toList();
  }

  Future<void> sendGroupMessage(int gid, String text) async {
    final d = await _ajax('send_group_message.php',
        method: 'POST', form: {'gid': gid.toString(), 'content': text});
    if (d is Map && d['ok'] == false) throw Exception(d['msg'] ?? '发送失败');
  }

  Future<void> sendMessage(int uid, String text) async {
    final d = await _ajax('send_message.php',
        method: 'POST', form: {'uid': uid.toString(), 'content': text});
    if (d is Map && d['ok'] == false) throw Exception(d['msg'] ?? '发送失败');
  }

  Future<void> joinGroup(int gid) async {
    final d = await _ajax('join_group.php',
        method: 'POST', jsonBody: {'gid': gid});
    if (d is Map && d['ok'] == false) throw Exception(d['msg'] ?? '加入失败');
  }

  // ---------- VIP 激活 ----------

  Future<Map<String, dynamic>> activateVip(String code) async {
    final url =
        Uri.parse('https://storex.solopai.cn/user.html?action=activate_card');
    final res = await _client.post(
      url,
      headers: {
        ..._headers,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'card_code=${Uri.encodeComponent(code)}',
    );
    return _decode(res) as Map<String, dynamic>;
  }
}

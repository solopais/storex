// StoreX 数据模型

class SiteConfig {
  final String siteTitle;
  final String siteLogo;
  final String siteDescription;
  final String aboutQq;
  final String aboutQqGroup;
  final String aboutWechat;
  final bool musicEnabled;
  final bool videoEnabled;
  final bool weatherEnabled;
  final bool epicEnabled;
  final String musicApi;
  final String videoApi;

  SiteConfig({
    required this.siteTitle,
    required this.siteLogo,
    required this.siteDescription,
    required this.aboutQq,
    required this.aboutQqGroup,
    required this.aboutWechat,
    required this.musicEnabled,
    required this.videoEnabled,
    required this.weatherEnabled,
    required this.epicEnabled,
    required this.musicApi,
    required this.videoApi,
  });

  factory SiteConfig.fromJson(Map<String, dynamic> j) => SiteConfig(
        siteTitle: j['site_title'] ?? 'StoreX',
        siteLogo: j['site_logo'] ?? '',
        siteDescription: j['site_description'] ?? '',
        aboutQq: j['about_qq'] ?? '',
        aboutQqGroup: j['about_qq_group'] ?? '',
        aboutWechat: j['about_wechat'] ?? '',
        musicEnabled: j['music_enabled'] ?? false,
        videoEnabled: j['video_enabled'] ?? false,
        weatherEnabled: j['weather_enabled'] ?? false,
        epicEnabled: j['epic_enabled'] ?? false,
        musicApi: j['music_api'] ??
            'https://node.api.xfabe.com/api/wangyi/randomMusic?type=json',
        videoApi: j['video_api'] ?? 'https://www.cunshao.com/666666/api/pc.php',
      );
}

class Category {
  final int id;
  final String name;
  final String slug;
  final String icon;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j['id'] ?? 0,
        name: j['name'] ?? '',
        slug: j['slug'] ?? '',
        icon: j['icon'] ?? '',
        description: j['description'] ?? '',
      );
}

class Slide {
  final int id;
  final String title;
  final String imageUrl;
  final String linkUrl;

  Slide({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkUrl,
  });

  factory Slide.fromJson(Map<String, dynamic> j) => Slide(
        id: j['id'] ?? 0,
        title: j['title'] ?? '',
        imageUrl: j['image_url'] ?? '',
        linkUrl: j['link_url'] ?? '',
      );
}

class App {
  final int id;
  final String title;
  final String shortDesc;
  final String icon;
  final int fileSize;
  final String fileSizeText;
  final String version;
  final bool isVip;
  final int downloads;
  final String developer;
  final int categoryId;
  final String categoryName;
  final String fileUrl;
  final String? description;
  final bool isFavorite;

  App({
    required this.id,
    required this.title,
    required this.shortDesc,
    required this.icon,
    required this.fileSize,
    required this.fileSizeText,
    required this.version,
    required this.isVip,
    required this.downloads,
    required this.developer,
    required this.categoryId,
    required this.categoryName,
    required this.fileUrl,
    this.description,
    required this.isFavorite,
  });

  factory App.fromJson(Map<String, dynamic> j) => App(
        id: j['id'] ?? 0,
        title: j['title'] ?? '',
        shortDesc: j['short_desc'] ?? '',
        icon: j['icon'] ?? '',
        fileSize: j['file_size'] ?? 0,
        fileSizeText: j['file_size_text'] ?? '',
        version: j['version'] ?? '',
        isVip: j['is_vip'] ?? false,
        downloads: j['downloads'] ?? 0,
        developer: j['developer'] ?? '',
        categoryId: j['category_id'] ?? 0,
        categoryName: j['category_name'] ?? '',
        fileUrl: j['file_url'] ?? '',
        description: j['description'],
        isFavorite: j['is_favorite'] ?? false,
      );
}

/// api.php ?route=apps 的完整分页响应
class AppsPage {
  final List<App> items;
  final int page;
  final int total;
  final int totalPages;

  AppsPage({
    required this.items,
    required this.page,
    required this.total,
    required this.totalPages,
  });

  factory AppsPage.fromJson(Map<String, dynamic> j) => AppsPage(
        items: (j['data'] as List? ?? []).map((e) => App.fromJson(e)).toList(),
        page: j['page'] ?? 1,
        total: j['total'] ?? 0,
        totalPages: (j['total_pages'] is num)
            ? (j['total_pages'] as num).toInt()
            : int.tryParse('${j['total_pages'] ?? 1}') ?? 1,
      );
}

class User {
  final int id;
  final String username;
  final String avatar;
  final bool isVip;
  final String? vipExpireAt;
  final int vipDays;

  User({
    required this.id,
    required this.username,
    required this.avatar,
    required this.isVip,
    this.vipExpireAt,
    required this.vipDays,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] ?? 0,
        username: j['username'] ?? '',
        avatar: j['avatar'] ?? '',
        isVip: j['is_vip'] ?? false,
        vipExpireAt: j['vip_expire_at'],
        vipDays: j['vip_days'] ?? 0,
      );
}

// ---------- 新增：移动端模块 ----------

class Article {
  final int id;
  final String title;
  final String thumbnail;
  final String summary;
  final int views;
  final bool isTop;
  final int comments;
  final String createdAt;

  Article({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.summary,
    required this.views,
    required this.isTop,
    required this.comments,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> j) => Article(
        id: j['id'] ?? 0,
        title: j['title'] ?? '',
        thumbnail: j['thumbnail'] ?? '',
        summary: j['summary'] ?? '',
        views: j['views'] ?? 0,
        isTop: (j['is_top'] ?? 0) == 1,
        comments: j['comments'] ?? 0,
        createdAt: j['created_at'] ?? '',
      );
}

/// api.php?route=articles 的完整分页响应（每页 10 条，与 mobile/ajax/articles.php 一致）
class ArticlesPage {
  final List<Article> items;
  final int total;
  final int page;
  final bool hasMore;

  ArticlesPage({
    required this.items,
    required this.total,
    required this.page,
    required this.hasMore,
  });

  factory ArticlesPage.fromJson(Map<String, dynamic> j) => ArticlesPage(
        items: (j['articles'] as List? ?? [])
            .map((e) => Article.fromJson(e))
            .toList(),
        total: j['total'] ?? 0,
        page: j['page'] ?? 1,
        hasMore: j['has_more'] == true,
      );
}

class DiscoverUser {
  final int id;
  final String username;
  final String avatar;
  final String bio;
  final bool isVip;
  final bool isAdmin;
  final String avatarFrame;
  final String followStatus;

  DiscoverUser({
    required this.id,
    required this.username,
    required this.avatar,
    required this.bio,
    required this.isVip,
    required this.isAdmin,
    required this.avatarFrame,
    required this.followStatus,
  });

  factory DiscoverUser.fromJson(Map<String, dynamic> j) => DiscoverUser(
        id: j['id'] ?? 0,
        username: j['username'] ?? '',
        avatar: j['avatar'] ?? '',
        bio: j['bio'] ?? '',
        isVip: j['is_vip'] ?? false,
        isAdmin: j['is_admin'] ?? false,
        avatarFrame: j['avatar_frame'] ?? '',
        followStatus: j['follow_status'] ?? 'none',
      );
}

class EpicGame {
  final String id;
  final String title;
  final String cover;
  final dynamic originalPrice;
  final String priceDesc;
  final String description;
  final String seller;
  final String freeEnd;
  final int freeEndAt;
  final String link;

  EpicGame({
    required this.id,
    required this.title,
    required this.cover,
    required this.originalPrice,
    required this.priceDesc,
    required this.description,
    required this.seller,
    required this.freeEnd,
    required this.freeEndAt,
    required this.link,
  });

  factory EpicGame.fromJson(Map<String, dynamic> j) => EpicGame(
        id: j['id']?.toString() ?? '',
        title: j['title'] ?? '',
        cover: j['cover'] ?? '',
        originalPrice: j['original_price'] ?? 0,
        priceDesc: j['price_desc'] ?? '',
        description: j['description'] ?? '',
        seller: j['seller'] ?? '',
        freeEnd: j['free_end'] ?? '',
        freeEndAt: j['free_end_at'] ?? 0,
        link: j['link'] ?? '',
      );
}

class RelatedUser {
  final int id;
  final String username;
  final String avatar;
  final bool isVip;
  final bool isAdmin;
  final String avatarFrame;

  RelatedUser({
    required this.id,
    required this.username,
    required this.avatar,
    required this.isVip,
    required this.isAdmin,
    required this.avatarFrame,
  });

  factory RelatedUser.fromJson(Map<String, dynamic> j) => RelatedUser(
        id: j['id'] ?? 0,
        username: j['username'] ?? '',
        avatar: j['avatar'] ?? '',
        isVip: j['is_vip'] ?? false,
        isAdmin: j['is_admin'] ?? false,
        avatarFrame: j['avatar_frame'] ?? '',
      );
}

class AppNotification {
  final int id;
  final String type;
  final String content;
  final bool isRead;
  final String createdAt;
  final int? relatedId;
  final Map<String, dynamic>? target;
  final RelatedUser? relatedUser;

  AppNotification({
    required this.id,
    required this.type,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
    this.target,
    this.relatedUser,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] ?? 0,
        type: j['type'] ?? '',
        content: j['content'] ?? '',
        isRead: j['is_read'] ?? false,
        createdAt: j['created_at'] ?? '',
        relatedId: j['related_id'],
        target: j['target'] is Map ? Map<String, dynamic>.from(j['target']) : null,
        relatedUser: j['related_user'] != null
            ? RelatedUser.fromJson(j['related_user'])
            : null,
      );
}

class GroupChat {
  final int id;
  final String name;
  final String avatar;
  final int memberCount;
  final String announcement;
  final bool isMember;
  final int unread;

  GroupChat({
    required this.id,
    required this.name,
    required this.avatar,
    required this.memberCount,
    required this.announcement,
    required this.isMember,
    required this.unread,
  });

  factory GroupChat.fromJson(Map<String, dynamic> j) => GroupChat(
        id: j['id'] ?? 0,
        name: j['name'] ?? '',
        avatar: j['avatar'] ?? '',
        memberCount: j['member_count'] ?? 0,
        announcement: j['announcement'] ?? '',
        isMember: j['is_member'] ?? false,
        unread: j['unread'] ?? 0,
      );
}

class Conversation {
  final int userId;
  final String username;
  final String avatar;
  final String content;
  final String createdAt;
  final bool isUnread;

  Conversation({
    required this.userId,
    required this.username,
    required this.avatar,
    required this.content,
    required this.createdAt,
    required this.isUnread,
  });

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
        userId: j['user_id'] ?? 0,
        username: j['username'] ?? '',
        avatar: j['avatar'] ?? '',
        content: j['content'] ?? '',
        createdAt: j['created_at'] ?? '',
        isUnread: j['is_unread'] ?? false,
      );
}

class ChatMessage {
  final int userId;
  final String username;
  final String avatar;
  final bool isMine;
  final bool isVip;
  final String content;
  final String createdAt;

  ChatMessage({
    required this.userId,
    required this.username,
    required this.avatar,
    required this.isMine,
    required this.isVip,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        userId: j['user_id'] ?? 0,
        username: j['username'] ?? '',
        avatar: j['avatar'] ?? '',
        isMine: j['is_mine'] ?? false,
        isVip: j['is_vip'] ?? false,
        content: j['content'] ?? '',
        createdAt: j['created_at'] ?? '',
      );
}

class UserProfile {
  final int id;
  final String username;
  final String avatar;
  final String avatarFrame;
  final String bio;
  final bool isVip;
  final String? vipExpireAt;
  final bool isAdmin;
  final bool isMe;
  final bool isFollowing;
  final int favoritesCount;
  final int followingCount;
  final int followersCount;

  UserProfile({
    required this.id,
    required this.username,
    required this.avatar,
    required this.avatarFrame,
    required this.bio,
    required this.isVip,
    this.vipExpireAt,
    required this.isAdmin,
    required this.isMe,
    required this.isFollowing,
    required this.favoritesCount,
    required this.followingCount,
    required this.followersCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] ?? 0,
        username: j['username'] ?? '',
        avatar: j['avatar'] ?? '',
        avatarFrame: j['avatar_frame'] ?? '',
        bio: j['bio'] ?? '',
        isVip: j['is_vip'] ?? false,
        vipExpireAt: j['vip_expire_at'],
        isAdmin: j['is_admin'] ?? false,
        isMe: j['is_me'] ?? false,
        isFollowing: j['is_following'] ?? false,
        favoritesCount: j['favorites_count'] ?? 0,
        followingCount: j['following_count'] ?? 0,
        followersCount: j['followers_count'] ?? 0,
      );
}

class FollowListUser {
  final int id;
  final String username;
  final String avatar;
  final String bio;
  final bool isVip;

  FollowListUser({
    required this.id,
    required this.username,
    required this.avatar,
    required this.bio,
    required this.isVip,
  });

  factory FollowListUser.fromJson(Map<String, dynamic> j) => FollowListUser(
        id: j['id'] ?? 0,
        username: j['username'] ?? '',
        avatar: j['avatar'] ?? '',
        bio: j['bio'] ?? '',
        isVip: j['is_vip'] ?? false,
      );
}

class ArticleDetail {
  final int id;
  final String title;
  final String summary;
  final String content;
  final String thumbnail;
  final int views;
  final bool isTop;
  final String createdAt;
  final String updatedAt;
  final List<Article> related;

  ArticleDetail({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.thumbnail,
    required this.views,
    required this.isTop,
    required this.createdAt,
    required this.updatedAt,
    required this.related,
  });

  factory ArticleDetail.fromJson(Map<String, dynamic> j) => ArticleDetail(
        id: j['id'] ?? 0,
        title: j['title'] ?? '',
        summary: j['summary'] ?? '',
        content: j['content'] ?? '',
        thumbnail: j['thumbnail'] ?? '',
        views: j['views'] ?? 0,
        isTop: (j['is_top'] ?? 0) == 1,
        createdAt: j['created_at'] ?? '',
        updatedAt: j['updated_at'] ?? '',
        related: (j['related'] as List? ?? [])
            .map((e) => Article.fromJson(e))
            .toList(),
      );
}

class Comment {
  final int id;
  final String content;
  final String createdAt;
  final int level;
  final int? parentId;
  final int userId;
  final String username;
  final String avatar;
  final bool isVip;
  final bool isAdmin;
  final String avatarFrame;
  final String location;
  final String? replyToName;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.level,
    this.parentId,
    required this.userId,
    required this.username,
    required this.avatar,
    required this.isVip,
    required this.isAdmin,
    required this.avatarFrame,
    required this.location,
    this.replyToName,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
        id: j['id'] ?? 0,
        content: j['content'] ?? '',
        createdAt: j['created_at'] ?? '',
        level: j['level'] ?? 0,
        parentId: j['parent_id'],
        userId: j['user_id'] ?? 0,
        username: j['username'] ?? '游客',
        avatar: j['avatar'] ?? '',
        isVip: j['is_vip'] ?? false,
        isAdmin: j['is_admin'] ?? false,
        avatarFrame: j['avatar_frame'] ?? '',
        location: j['location'] ?? '',
        replyToName: j['reply_to_name'],
        replies: (j['replies'] as List? ?? [])
            .map((e) => Comment.fromJson(e))
            .toList(),
      );
}

/// api.php?route=comments 的完整分页响应
class CommentsPage {
  final List<Comment> comments;
  final int total;
  final bool hasMore;
  final int page;
  final bool isAdmin;
  final int meId;

  CommentsPage({
    required this.comments,
    required this.total,
    required this.hasMore,
    required this.page,
    required this.isAdmin,
    required this.meId,
  });

  factory CommentsPage.fromJson(Map<String, dynamic> j) => CommentsPage(
        comments: (j['comments'] as List? ?? [])
            .map((e) => Comment.fromJson(e))
            .toList(),
        total: j['total'] ?? 0,
        hasMore: j['has_more'] == true,
        page: j['page'] ?? 1,
        isAdmin: j['is_admin'] == true,
        meId: j['me_id'] ?? 0,
      );
}

class NotifResult {
  final List<AppNotification> items;
  final bool hasMore;
  final int unreadNotif;
  final int unreadMsg;
  final int unreadGroup;

  NotifResult({
    required this.items,
    required this.hasMore,
    required this.unreadNotif,
    required this.unreadMsg,
    required this.unreadGroup,
  });

  factory NotifResult.fromJson(Map<String, dynamic> j) => NotifResult(
        items: (j['items'] as List? ?? [])
            .map((e) => AppNotification.fromJson(e))
            .toList(),
        hasMore: j['has_more'] ?? false,
        unreadNotif: j['unread_notif'] ?? 0,
        unreadMsg: j['unread_msg'] ?? 0,
        unreadGroup: j['unread_group'] ?? 0,
      );
}

class UnreadCount {
  final int total;
  final int notif;
  final int msg;
  final int group;

  UnreadCount({
    required this.total,
    required this.notif,
    required this.msg,
    required this.group,
  });

  factory UnreadCount.fromJson(Map<String, dynamic> j) => UnreadCount(
        total: j['total'] ?? 0,
        notif: j['notif'] ?? 0,
        msg: j['msg'] ?? 0,
        group: j['group'] ?? 0,
      );
}

class SiteConfig {
  final String siteTitle;
  final String siteLogo;
  final String siteDescription;
  final String aboutQq;
  final String aboutQqGroup;
  final bool musicEnabled;
  final bool videoEnabled;

  SiteConfig({
    required this.siteTitle,
    required this.siteLogo,
    required this.siteDescription,
    required this.aboutQq,
    required this.aboutQqGroup,
    required this.musicEnabled,
    required this.videoEnabled,
  });

  factory SiteConfig.fromJson(Map<String, dynamic> j) => SiteConfig(
        siteTitle: j['site_title'] ?? 'StoreX',
        siteLogo: j['site_logo'] ?? '',
        siteDescription: j['site_description'] ?? '',
        aboutQq: j['about_qq'] ?? '',
        aboutQqGroup: j['about_qq_group'] ?? '',
        musicEnabled: j['music_enabled'] ?? false,
        videoEnabled: j['video_enabled'] ?? false,
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

import 'package:flutter/material.dart';
import '../api/models.dart';
import '../theme.dart';
import 'common.dart';

/// 一比一对应 mobile.css `.article-list-m` 中的站内公告行（移动端无缩略图）
/// .article-list-m .ni{display:flex;gap:12px;padding:14px 16px;background:#fff;
///   border-radius:12px;align-items:center;position:relative;box-shadow:0 1px 3px rgba(0,0,0,.04)}
/// .ni-thumb{width:42px;height:42px;border-radius:8px;background:pri;display:flex;
///   align-items:center;justify-content:center;color:#fff;font-weight:800;font-size:18px}
/// .ni-body{flex:1;min-width:0}
/// .ni-title{font-size:14px;font-weight:600;color:#102B50;line-height:1.4;
///   display:-webkit-box;-webkit-line-clamp:2;...overflow:hidden}
/// .ni-meta{display:flex;align-items:center;gap:12px;margin-top:4px;
///   font-size:11px;color:#9CA3AF}
/// .ni-top{position:absolute;top:0;left:0;background:linear-gradient(135deg,#F59E0B,#D97706);
///   color:#fff;font-size:9px;padding:1px 6px;border-radius:8px 0 8px 0;font-weight:700}
class NoticeRow extends StatelessWidget {
  final int id;
  final String title;
  final String summary;
  final int views;
  final int comments;
  final bool isTop;
  final VoidCallback? onTap;

  const NoticeRow({
    super.key,
    required this.id,
    required this.title,
    required this.summary,
    required this.views,
    required this.comments,
    required this.isTop,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sum = summary.trim();
    return Material(
      color: cardWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 3,
                  offset: Offset(0, 1)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 紫色 S 字母占位（与 App Icon 风格一致）
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [pri, purple],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF102B50),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.visibility_outlined,
                            size: 11, color: t3),
                        const SizedBox(width: 3),
                        Text(nfmt(views),
                            style: const TextStyle(
                                fontSize: 11, color: t3)),
                        const SizedBox(width: 12),
                        const Icon(Icons.chat_bubble_outline,
                            size: 11, color: t3),
                        const SizedBox(width: 3),
                        Text(nfmt(comments),
                            style: const TextStyle(
                                fontSize: 11, color: t3)),
                      ],
                    ),
                  ],
                ),
              ),
              if (isTop)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 9, color: Colors.white),
                      SizedBox(width: 3),
                      Text('置顶',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 分类列表项（音乐播放器下方「热门排行」中显示的 Article 类型）
articleListItemMap(Article article) => {
      'id': article.id,
      'title': article.title,
      'summary': article.summary,
      'views': article.views,
      'comments': article.comments,
      'isTop': article.isTop,
    };

import 'dart:ui';
import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../api/auth_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/html_view.dart';
import '../widgets/toast.dart';
import 'login_screen.dart';

/// ============================================================
/// 一比一还原移动端文章详情页（mobile.css `.article-hero` / `.detail-card` / `.article-rel-*` / `.comment-*`）
///
/// 关键数值（均来自 assets/css/mobile.css，勿随意改动）：
/// .article-hero  green gradient #0f766e→#14b8a6→#5eead4→#a7f3d0→#fff
///   padding:calc(st+110px) 16px 100px
/// .article-hero::after  radial glow @bottom
/// .article-hero-card  gap12 bg rgba(255,255,255,.18) bd rgba(255,255,255,.28)
///   blur(14px) radius22 pad12 shadow 0 10px 28px rgba(0,0,0,.14) min-height108
/// .article-hero-thumb  120x72 radius12  placeholder #334155→#1e293b 32/800 #fff
/// .article-hero-title  17/700 #fff line1.35 2行截 min-height2.7em
/// .article-hero-summary 12.5 rgba(255,255,255,.78) 单行截
/// .article-hero-meta  10.5 rgba(255,255,255,.72) gap6
/// .article-hero-top   rgba(255,255,255,.22) #fff pad2 8 radius20 11/600 星标
/// .detail-mode .app-header  transparent → scrolled rgba(123,51,230,.92)
/// .detail-card:first-of-type  margin-top:-60px z-index1；.detail-card bg #fff radius0 pad18 16
/// .detail-card-title  16/700 #102B50 gap10；.dc-icon 22x22 radius50 #EEF0FF #6E6CF6 11px
/// .article-rel-item  gap12 pad10 radius12 bg #F2F3F7；.ari-thumb 52x52 r10；.ari-title .9/600 #102B50；.ari-sum .76 #94a3b8
/// .comment-item  gap10 pad12 0 .5px bd；.cm-avatar 36x36 圆；.cm-name 13/600 txt；.cm-vip-name 金渐变 #C5A43E→#8B6914
/// .cm-vip 11 #F59E0B；.cm-text 14 t1 line1.6；.cm-reply-to 13 t2；.cm-reply-btn 12 pri
/// .comment-input-wrap gap8 mb14 pb14 .5px bd；.comment-input radius20 bg pad10/14 14；.comment-submit 36x36 圆 pri #fff 15
/// .comment-more 13 pri；.comment-more-end t3
/// .af-overlay  inset:-35% z3 img 100%
/// ============================================================

const Color _hero0 = Color(0xFF0F766E);
const Color _hero1 = Color(0xFF14B8A6);
const Color _hero2 = Color(0xFF5EEAD4);
const Color _hero3 = Color(0xFFA7F3D0);
const Color _hero4 = Color(0xFFFFFFFF);
const Color _topBar = Color(0xEB7B33E6); // rgba(123,51,230,.92)
const Color _vipG1 = Color(0xFFC5A43E);
const Color _vipG2 = Color(0xFF8B6914);
const Color _cmTitle = Color(0xFF102B50);
const Color _cmText = Color(0xFF1F2937); // --t1
const Color _thumbPh1 = Color(0xFF334155);
const Color _thumbPh2 = Color(0xFF1E293B);

class ArticleDetailScreen extends StatefulWidget {
  final int articleId;
  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ApiClient _api = ApiClient.instance;
  final ScrollController _ctl = ScrollController();

  ArticleDetail? _detail;
  bool _loading = true;
  String? _error;

  final List<Comment> _comments = [];
  int _cPage = 1;
  int _cTotal = 0;
  bool _cHasMore = false;
  bool _cLoading = false;
  bool _cLoaded = false;
  bool _isAdmin = false;
  int _meId = 0;

  int? _replyingTo;
  final TextEditingController _commentCtl = TextEditingController();
  final TextEditingController _replyCtl = TextEditingController();

  double _titleAlpha = 0.0;
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _ctl.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _ctl.removeListener(_onScroll);
    _ctl.dispose();
    _commentCtl.dispose();
    _replyCtl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final y = _ctl.position.pixels;
    final sc = y > 120;
    final a = (((y - 140) / 60).clamp(0.0, 1.0));
    if (sc != _scrolled || (a - _titleAlpha).abs() > 0.02) {
      setState(() {
        _scrolled = sc;
        _titleAlpha = a;
      });
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await _api.getArticle(widget.articleId);
      if (!mounted) return;
      setState(() {
        _detail = d;
        _loading = false;
      });
      _loadComments(1, reset: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadComments(int pg, {bool reset = false}) async {
    if (_cLoading) return;
    if (reset) {
      setState(() {
        _cLoading = true;
        _cLoaded = false;
      });
    } else {
      setState(() => _cLoading = true);
    }
    try {
      final page = await _api.getCommentsPage('article', widget.articleId,
          page: pg);
      if (!mounted) return;
      setState(() {
        if (reset) {
          _comments.clear();
          _cPage = 1;
          _cTotal = page.total;
          _isAdmin = page.isAdmin;
          _meId = page.meId;
        }
        _comments.addAll(page.comments);
        _cPage = pg;
        _cHasMore = page.hasMore;
        _cLoading = false;
        _cLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cLoading = false;
        _cLoaded = true;
      });
      if (mounted) Toast.show(context, '评论加载失败');
    }
  }

  bool _canDelete(Comment c) =>
      _isAdmin || (_meId != 0 && _meId == c.userId);

  Future<void> _sendComment() async {
    final text = _commentCtl.text.trim();
    if (text.isEmpty) return;
    try {
      await _api.postComment('article', widget.articleId, text);
      _commentCtl.clear();
      if (mounted) Toast.show(context, '评论成功');
      _loadComments(1, reset: true);
    } catch (e) {
      if (mounted) {
        Toast.show(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _sendReply(Comment parent) async {
    final text = _replyCtl.text.trim();
    if (text.isEmpty) return;
    try {
      await _api.postComment('article', widget.articleId, text,
          parentId: parent.id);
      _replyCtl.clear();
      setState(() => _replyingTo = null);
      if (mounted) Toast.show(context, '回复成功');
      _loadComments(1, reset: true);
    } catch (e) {
      if (mounted) {
        Toast.show(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _del(Comment c) async {
    try {
      await _api.deleteComment(c.id);
      if (mounted) Toast.show(context, '已删除');
      _loadComments(1, reset: true);
    } catch (e) {
      if (mounted) {
        Toast.show(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardWhite,
      body: Stack(
        children: [
          if (_detail != null) _scrollView(),
          _header(),
          if (_loading && _detail == null) _loadingOverlay(),
          if (_error != null && _detail == null) _errorOverlay(),
        ],
      ),
    );
  }

  Widget _scrollView() {
    final d = _detail!;
    return SingleChildScrollView(
      controller: _ctl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _hero(d),
          _contentCard(d),
          if (d.related.isNotEmpty) _relatedCard(d),
          _commentCard(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ---------------- 浮动头部 ----------------

  Widget _header() {
    final top = MediaQuery.of(context).padding.top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.only(top: top),
        decoration: BoxDecoration(
          color: _scrolled ? _topBar : Colors.transparent,
          boxShadow: _scrolled
              ? [
                  const BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 6,
                      offset: Offset(0, 2)),
                ]
              : null,
        ),
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              const SizedBox(width: 16),
              _backBtn(),
              const SizedBox(width: 12),
              Expanded(
                child: Opacity(
                  opacity: _titleAlpha,
                  child: Text(
                    _detail?.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backBtn() {
    return Material(
      color: Colors.white.withOpacity(0.28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).maybePop(),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.chevron_left, size: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- 星空 Hero ----------------

  Widget _hero(ArticleDetail d) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      clipBehavior: Clip.none,
      padding: EdgeInsets.fromLTRB(16, top + 110, 16, 100),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.25, 0.6, 0.9, 1.0],
          colors: [_hero0, _hero1, _hero2, _hero3, _hero4],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // .article-hero::after 底部光晕
          Positioned(
            left: -40,
            right: -40,
            bottom: -40,
            height: 140,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.75,
                    colors: const [
                      Color(0xF2FFFFFF),
                      Color(0xB3D7FAF0),
                      Color(0x4DD7FAF0),
                      Color(0x00D7FAF0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _heroCard(d),
        ],
      ),
    );
  }

  Widget _heroCard(ArticleDetail d) {
    final thumb = d.thumbnail.trim().isNotEmpty
        ? NetImg(
            url: d.thumbnail,
            width: 120,
            height: 72,
            radius: 12,
            placeholder: _thumbPh(d.title),
          )
        : _thumbPh(d.title);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x24000000), blurRadius: 28, offset: Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 120,
                  height: 72,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: thumb,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (d.isTop)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,
                                  size: 11, color: Colors.white),
                              SizedBox(width: 3),
                              Text('置顶',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      Container(
                        constraints: const BoxConstraints(minHeight: 46),
                        child: Text(
                          d.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.35,
                            shadows: [
                              Shadow(
                                  color: Color(0x1F000000),
                                  blurRadius: 2,
                                  offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                      ),
                      if (d.summary.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            d.summary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xC8FFFFFF),
                              height: 1.45,
                            ),
                          ),
                        ),
                      const Spacer(),
                      _heroMeta(d),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroMeta(ArticleDetail d) {
    final date = d.createdAt.length >= 10 ? d.createdAt.substring(0, 10) : d.createdAt;
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 11, color: Color(0xB8FFFFFF)),
        const SizedBox(width: 2),
        Text(date,
            style: const TextStyle(fontSize: 10.5, color: Color(0xB8FFFFFF))),
        const SizedBox(width: 6),
        const Icon(Icons.visibility_outlined,
            size: 11, color: Color(0xB8FFFFFF)),
        const SizedBox(width: 2),
        Text(nfmt(d.views),
            style: const TextStyle(fontSize: 10.5, color: Color(0xB8FFFFFF))),
      ],
    );
  }

  Widget _thumbPh(String title) => Container(
        width: 120,
        height: 72,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_thumbPh1, _thumbPh2],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title.isEmpty ? '?' : title.characters.first,
          style: const TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
        ),
      );

  // ---------------- 正文卡片 ----------------

  Widget _contentCard(ArticleDetail d) {
    return Container(
      margin: const EdgeInsets.only(top: -60),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      color: cardWhite,
      child: HtmlView(html: d.content),
    );
  }

  Widget _dcIcon(IconData icon) => Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Color(0xFFEEF0FF),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 11, color: Color(0xFF6E6CF6)),
      );

  // ---------------- 相关文章 ----------------

  Widget _relatedCard(ArticleDetail d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      color: cardWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _dcIcon(Icons.menu_book_outlined),
              const SizedBox(width: 10),
              const Text('相关阅读',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _cmTitle)),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < d.related.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _relItem(d.related[i]),
          ],
        ],
      ),
    );
  }

  Widget _relItem(Article a) {
    final thumb = a.thumbnail.trim().isNotEmpty
        ? NetImg(
            url: a.thumbnail,
            width: 52,
            height: 52,
            radius: 10,
            placeholder: _ariPh(a.title),
          )
        : _ariPh(a.title);
    return Material(
      color: const Color(0xFFF2F3F7),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ArticleDetailScreen(articleId: a.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(10), child: thumb),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.4,
                          fontWeight: FontWeight.w600,
                          color: _cmTitle),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.summary.trim().isEmpty ? '查看详情' : a.summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.16, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ariPh(String title) => Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        alignment: Alignment.center,
        child: Text(
          title.isEmpty ? '?' : title.characters.first,
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
        ),
      );

  // ---------------- 评论区 ----------------

  Widget _commentCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      color: cardWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _dcIcon(Icons.chat_bubble_outline),
              const SizedBox(width: 10),
              Text('评论${_cTotal > 0 ? ' $_cTotal' : ''}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _cmTitle)),
            ],
          ),
          const SizedBox(height: 14),
          _commentInput(),
          if (!_cLoaded)
            const LoadingView(text: '加载评论...')
          else if (_comments.isEmpty)
            const EmptyView(
                icon: Icons.chat_bubble_outline, text: '还没有评论，快来抢沙发')
          else
            ..._commentList(),
        ],
      ),
    );
  }

  Widget _commentInput() {
    if (!AuthService.instance.isLoggedIn) {
      // .comment-input-locked
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: appBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 13, color: t3),
              SizedBox(width: 6),
              Text('登录后可评论',
                  style: TextStyle(fontSize: 13, color: t3)),
            ],
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.only(bottom: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: bd, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: appBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _commentCtl,
                maxLines: null,
                style: const TextStyle(fontSize: 14, color: txt),
                decoration: const InputDecoration.collapsed(
                  hintText: '说点什么...',
                  hintStyle: TextStyle(fontSize: 14, color: t3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendComment,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: pri,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x1F6366F1),
                      blurRadius: 6,
                      offset: Offset(0, 2)),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.send, size: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _commentList() {
    final out = <Widget>[];
    for (int i = 0; i < _comments.length; i++) {
      out.add(_commentItem(_comments[i]));
      if (i < _comments.length - 1) {
        out.add(const Divider(height: 0.5, thickness: 0.5, color: bd));
      }
    }
    if (_cHasMore) {
      out.add(GestureDetector(
        onTap: _cLoading ? null : () => _loadComments(_cPage + 1),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: _cLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: pri),
                )
              : const Text('加载更多',
                  style: TextStyle(
                      fontSize: 13,
                      color: pri,
                      fontWeight: FontWeight.w500)),
        ),
      ));
    } else if (_comments.isNotEmpty) {
      out.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('没有更多了',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: t3)),
      ));
    }
    return out;
  }

  Widget _commentItem(Comment c, {bool reply = false}) {
    final kids = <Widget>[
      _commentRow(c),
      if (c.replies.isNotEmpty)
        for (final r in c.replies) _commentItem(r, reply: true),
      if (_replyingTo == c.id) _replyForm(c),
    ];
    return Container(
      padding: EdgeInsets.only(left: reply ? 44 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: kids,
      ),
    );
  }

  Widget _commentRow(Comment c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(c),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _name(c),
                    if (c.isVip)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('VIP',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF59E0B))),
                      ),
                    if (c.isAdmin)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: redB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('管理员',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: red)),
                      ),
                    const Spacer(),
                    if (_canDelete(c))
                      GestureDetector(
                        onTap: () => _del(c),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.delete_outline,
                              size: 16, color: t3),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                if (c.replyToName != null && c.replyToName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('回复 @${c.replyToName}',
                        style: const TextStyle(
                            fontSize: 13, color: t2)),
                  ),
                Text(
                  c.content,
                  style: const TextStyle(
                      fontSize: 14,
                      color: _cmText,
                      height: 1.6,
                      wordSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(_fmtTime(c.createdAt),
                        style: const TextStyle(fontSize: 11, color: t3)),
                    if (c.location.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: t3),
                      const SizedBox(width: 2),
                      Text(c.location,
                          style: const TextStyle(fontSize: 11, color: t3)),
                    ],
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        if (!AuthService.instance.isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                          return;
                        }
                        setState(() => _replyingTo =
                            _replyingTo == c.id ? null : c.id);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.reply, size: 12, color: pri),
                            SizedBox(width: 3),
                            Text('回复',
                                style: TextStyle(
                                    fontSize: 12, color: pri)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _name(Comment c) {
    if (c.isVip) {
      return ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_vipG1, _vipG2, _vipG1],
        ).createShader(r),
        child: Text(c.username,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      );
    }
    return Text(c.username,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: txt));
  }

  Widget _avatar(Comment c) {
    final inner = c.avatar.trim().isNotEmpty
        ? NetImg(
            url: c.avatar,
            width: 36,
            height: 36,
            radius: 18,
            placeholder: _avatarPh(c.username),
          )
        : _avatarPh(c.username);
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        children: [
          ClipOval(child: SizedBox(width: 36, height: 36, child: inner)),
          if (c.avatarFrame.trim().isNotEmpty)
            Positioned(
              left: -12,
              top: -12,
              right: -12,
              bottom: -12,
              child: IgnorePointer(
                child: Image.network(
                  c.avatarFrame,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _avatarPh(String name) => Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [pri, purple],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          name.isEmpty ? '?' : name.characters.first,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      );

  Widget _replyForm(Comment parent) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: appBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _replyCtl,
                autofocus: true,
                maxLines: null,
                style: const TextStyle(fontSize: 13, color: txt),
                decoration: InputDecoration.collapsed(
                  hintText: '回复 @${parent.username}',
                  hintStyle: const TextStyle(fontSize: 13, color: t3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _replyingTo = null),
            child: const Text('取消',
                style: TextStyle(fontSize: 11, color: t3)),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _sendReply(parent),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: pri,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.send, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtTime(String s) {
    if (s.isEmpty) return '';
    // "2026-08-01 12:00:00" -> "2026-08-01 12:00"
    if (s.length >= 16) return s.substring(0, 16);
    return s;
  }

  // ---------------- 加载 / 错误 ----------------

  Widget _loadingOverlay() {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 110, 16, 100),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.25, 0.6, 0.9, 1.0],
          colors: [_hero0, _hero1, _hero2, _hero3, _hero4],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
            strokeWidth: 3, color: Colors.white),
      ),
    );
  }

  Widget _errorOverlay() {
    return Container(
      color: cardWhite,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 52, color: t3),
            const SizedBox(height: 12),
            Text(_error ?? '加载失败',
                style: const TextStyle(fontSize: 13, color: t3)),
            const SizedBox(height: 16),
            Material(
              color: pri,
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: _load,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  child: Text('重试',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

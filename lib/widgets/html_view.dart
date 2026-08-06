import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import 'image_lightbox.dart';

/// ============================================================
/// 富文本正文渲染（一比一对应 mobile.css `.article-content`）
///
/// .article-content{font-size:.95rem;line-height:1.85;color:#334155}
/// img{max-width:100%;border-radius:8px;margin:12px 0}
/// a{color:var(--pri)}
/// h1~h4{font-weight:700;margin:22px 0 12px;color:#1e293b;line-height:1.4}
///   h1 1.3rem / h2 1.18rem / h3 1.05rem / h4 .98rem
/// p{margin-bottom:14px}
/// blockquote{border-left:3px solid pri;padding:10px 14px;margin:16px 0;
///            background:#f8fafc;border-radius:0 8px 8px 0;color:t2;font-size:.9rem}
/// ul,ol{padding-left:20px;margin-bottom:14px}  li{margin-bottom:6px}
/// table{width:100%;margin:16px 0;font-size:.82rem}  td,th{border:1px solid #e5e7eb;padding:8px 10px}
/// code{background:#f1f5f9;padding:2px 6px;border-radius:4px;font-size:.85em}
/// pre{background:#0f172a;color:#e2e8f0;padding:14px;border-radius:8px;
///     overflow-x:auto;font-size:.82rem;line-height:1.6;margin:16px 0}
/// hr{border-top:1px solid #e5e7eb;margin:20px 0}
///
/// 说明：1rem = 16px（移动端未改 html 根字号）
/// ============================================================

const double _rem = 16.0;
const Color _acText = Color(0xFF334155);
const Color _acHead = Color(0xFF1E293B);
const Color _acBorder = Color(0xFFE5E7EB);
const Color _acQuoteBg = Color(0xFFF8FAFC);
const Color _acCodeBg = Color(0xFFF1F5F9);
const Color _acPreBg = Color(0xFF0F172A);
const Color _acPreFg = Color(0xFFE2E8F0);

class HtmlView extends StatelessWidget {
  final String html;

  const HtmlView({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    final nodes = _parseHtml(html);
    const base = TextStyle(
      fontSize: 0.95 * _rem, // 15.2
      height: 1.85,
      color: _acText,
      fontWeight: FontWeight.w400,
    );
    final children = _renderBlocks(context, nodes, base);
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

// ============================================================
// 渲染
// ============================================================

const Set<String> _blockTags = {
  'p', 'div', 'section', 'article', 'header', 'footer', 'main', 'aside',
  'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
  'blockquote', 'ul', 'ol', 'li', 'pre', 'table', 'thead', 'tbody', 'tr',
  'hr', 'figure', 'figcaption', 'iframe', 'video',
};

List<Widget> _renderBlocks(
    BuildContext ctx, List<_Node> nodes, TextStyle base) {
  final out = <Widget>[];
  final inlineBuf = <_Node>[];

  void flush() {
    if (inlineBuf.isEmpty) return;
    final spans = <InlineSpan>[];
    for (final n in inlineBuf) {
      _inlineSpans(ctx, n, base, spans);
    }
    inlineBuf.clear();
    if (_spansEmpty(spans)) return;
    out.add(Text.rich(TextSpan(children: spans, style: base)));
  }

  for (final n in nodes) {
    if (n is _Text) {
      if (n.text.trim().isEmpty) continue;
      inlineBuf.add(n);
      continue;
    }
    final el = n as _Elem;
    if (el.tag == 'img') {
      flush();
      out.add(_image(ctx, el));
      continue;
    }
    if (!_blockTags.contains(el.tag)) {
      inlineBuf.add(el);
      continue;
    }
    flush();
    final w = _blockWidget(ctx, el, base);
    if (w != null) out.add(w);
  }
  flush();
  return out;
}

Widget? _blockWidget(BuildContext ctx, _Elem el, TextStyle base) {
  switch (el.tag) {
    case 'p':
      final spans = _childSpans(ctx, el, base);
      // 段落里只有图片时，走块级图片
      final imgs = el.children.whereType<_Elem>().where((e) => e.tag == 'img');
      if (_spansEmpty(spans) && imgs.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: imgs.map((e) => _image(ctx, e)).toList(),
        );
      }
      if (_spansEmpty(spans) && imgs.isEmpty) return null;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text.rich(
          TextSpan(children: spans, style: base),
          textAlign: _align(el),
        ),
      );

    case 'h1':
    case 'h2':
    case 'h3':
    case 'h4':
    case 'h5':
    case 'h6':
      const sizes = {
        'h1': 1.30, 'h2': 1.18, 'h3': 1.05,
        'h4': 0.98, 'h5': 0.98, 'h6': 0.98,
      };
      final st = base.copyWith(
        fontSize: (sizes[el.tag] ?? 0.98) * _rem,
        fontWeight: FontWeight.w700,
        color: _acHead,
        height: 1.4,
      );
      return Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 12),
        child: Text.rich(
          TextSpan(children: _childSpans(ctx, el, st), style: st),
          textAlign: _align(el),
        ),
      );

    case 'blockquote':
      final st = base.copyWith(fontSize: 0.9 * _rem, color: t2);
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: const BoxDecoration(
          color: _acQuoteBg,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          border: Border(left: BorderSide(color: pri, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _renderBlocks(ctx, el.children, st),
        ),
      );

    case 'ul':
    case 'ol':
      final items =
          el.children.whereType<_Elem>().where((e) => e.tag == 'li').toList();
      if (items.isEmpty) return null;
      return Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < items.length; i++)
              Padding(
                padding: EdgeInsets.only(
                    bottom: i == items.length - 1 ? 0 : 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: el.tag == 'ol' ? 22 : 14,
                      child: Text(
                        el.tag == 'ol' ? '${i + 1}.' : '•',
                        style: base,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _renderBlocks(ctx, items[i].children, base),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );

    case 'pre':
      final code = _plainText(el).replaceAll(RegExp(r'\n$'), '');
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _acPreBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            code,
            style: const TextStyle(
              color: _acPreFg,
              fontSize: 0.82 * _rem, // 13.12
              height: 1.6,
              fontFamily: 'monospace',
            ),
          ),
        ),
      );

    case 'hr':
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Divider(height: 1, thickness: 1, color: _acBorder),
      );

    case 'table':
      return _table(ctx, el, base);

    default:
      final kids = _renderBlocks(ctx, el.children, base);
      if (kids.isEmpty) return null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: kids,
      );
  }
}

Widget _table(BuildContext ctx, _Elem el, TextStyle base) {
  final rows = <_Elem>[];
  void collect(_Elem e) {
    for (final c in e.children.whereType<_Elem>()) {
      if (c.tag == 'tr') {
        rows.add(c);
      } else if (c.tag == 'thead' || c.tag == 'tbody' || c.tag == 'tfoot') {
        collect(c);
      }
    }
  }

  collect(el);
  if (rows.isEmpty) return const SizedBox.shrink();
  final st = base.copyWith(fontSize: 0.82 * _rem, height: 1.5);
  int maxCols = 0;
  final cells = <List<_Elem>>[];
  for (final r in rows) {
    final cs = r.children
        .whereType<_Elem>()
        .where((c) => c.tag == 'td' || c.tag == 'th')
        .toList();
    cells.add(cs);
    if (cs.length > maxCols) maxCols = cs.length;
  }
  if (maxCols == 0) return const SizedBox.shrink();

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 16),
    child: Table(
      border: TableBorder.all(color: _acBorder, width: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final cs in cells)
          TableRow(
            children: [
              for (int i = 0; i < maxCols; i++)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: i < cs.length
                      ? Text.rich(
                          TextSpan(
                            children: _childSpans(
                              ctx,
                              cs[i],
                              cs[i].tag == 'th'
                                  ? st.copyWith(fontWeight: FontWeight.w700)
                                  : st,
                            ),
                            style: cs[i].tag == 'th'
                                ? st.copyWith(fontWeight: FontWeight.w700)
                                : st,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
      ],
    ),
  );
}

Widget _image(BuildContext ctx, _Elem el) {
  final src = el.attrs['src'] ?? '';
  if (src.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: GestureDetector(
      onTap: () => showImageLightbox(ctx, src),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          src,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          errorBuilder: (_, __, ___) => Container(
            height: 120,
            color: const Color(0xFFEEF2F7),
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined,
                size: 28, color: t3),
          ),
          loadingBuilder: (c, w, p) => p == null
              ? w
              : Container(
                  height: 160,
                  color: const Color(0xFFEEF2F7),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: t3),
                  ),
                ),
        ),
      ),
    ),
  );
}

// ---------- 行内 ----------

List<InlineSpan> _childSpans(BuildContext ctx, _Elem el, TextStyle st) {
  final spans = <InlineSpan>[];
  for (final c in el.children) {
    _inlineSpans(ctx, c, st, spans);
  }
  return spans;
}

void _inlineSpans(
    BuildContext ctx, _Node n, TextStyle st, List<InlineSpan> out) {
  if (n is _Text) {
    if (n.text.isEmpty) return;
    out.add(TextSpan(text: n.text, style: st));
    return;
  }
  final el = n as _Elem;
  switch (el.tag) {
    case 'br':
      out.add(const TextSpan(text: '\n'));
      return;
    case 'img':
      // 行内图片：转为可点击的小图标提示（正文中的图片一般已被块级分支接管）
      final src = el.attrs['src'] ?? '';
      if (src.isEmpty) return;
      out.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: GestureDetector(
            onTap: () => showImageLightbox(ctx, src),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(src, fit: BoxFit.fitWidth),
            ),
          ),
        ),
      ));
      return;
    case 'strong':
    case 'b':
      _pushChildren(ctx, el, st.copyWith(fontWeight: FontWeight.w700), out);
      return;
    case 'em':
    case 'i':
      _pushChildren(ctx, el, st.copyWith(fontStyle: FontStyle.italic), out);
      return;
    case 'u':
      _pushChildren(
          ctx, el, st.copyWith(decoration: TextDecoration.underline), out);
      return;
    case 's':
    case 'del':
    case 'strike':
      _pushChildren(
          ctx, el, st.copyWith(decoration: TextDecoration.lineThrough), out);
      return;
    case 'code':
      _pushChildren(
        ctx,
        el,
        st.copyWith(
          fontSize: (st.fontSize ?? 15.2) * 0.85,
          fontFamily: 'monospace',
          background: Paint()..color = _acCodeBg,
        ),
        out,
      );
      return;
    case 'a':
      final href = el.attrs['href'] ?? '';
      final linkStyle = _applyStyleAttr(el, st.copyWith(color: pri));
      final recognizer = TapGestureRecognizer()
        ..onTap = () {
          if (href.isEmpty || href.startsWith('javascript')) return;
          final uri = Uri.tryParse(href);
          if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
        };
      for (final c in el.children) {
        _inlineSpans(ctx, c, linkStyle, out);
      }
      // 给纯文本链接附加点击
      if (out.isNotEmpty && out.last is TextSpan) {
        final last = out.removeLast() as TextSpan;
        out.add(TextSpan(
            text: last.text,
            children: last.children,
            style: last.style,
            recognizer: recognizer));
      }
      return;
    default:
      _pushChildren(ctx, el, _applyStyleAttr(el, st), out);
      return;
  }
}

void _pushChildren(
    BuildContext ctx, _Elem el, TextStyle st, List<InlineSpan> out) {
  for (final c in el.children) {
    _inlineSpans(ctx, c, st, out);
  }
}

/// 解析 style="color:#xxx;background-color:#xxx;font-size:20px;font-weight:bold"
TextStyle _applyStyleAttr(_Elem el, TextStyle st) {
  final raw = el.attrs['style'];
  if (raw == null || raw.isEmpty) return st;
  var s = st;
  for (final part in raw.split(';')) {
    final kv = part.split(':');
    if (kv.length < 2) continue;
    final k = kv[0].trim().toLowerCase();
    final v = kv.sublist(1).join(':').trim();
    switch (k) {
      case 'color':
        final c = _parseColor(v);
        if (c != null) s = s.copyWith(color: c);
        break;
      case 'background-color':
        final c = _parseColor(v);
        if (c != null) s = s.copyWith(background: Paint()..color = c);
        break;
      case 'font-size':
        final m = RegExp(r'([\d.]+)\s*(px|rem|em)?').firstMatch(v);
        if (m != null) {
          final num0 = double.tryParse(m.group(1)!) ?? 0;
          final unit = m.group(2) ?? 'px';
          final px = unit == 'px'
              ? num0
              : unit == 'rem'
                  ? num0 * _rem
                  : num0 * (st.fontSize ?? _rem);
          if (px > 0) s = s.copyWith(fontSize: px);
        }
        break;
      case 'font-weight':
        if (v == 'bold' || (int.tryParse(v) ?? 0) >= 600) {
          s = s.copyWith(fontWeight: FontWeight.w700);
        }
        break;
    }
  }
  return s;
}

Color? _parseColor(String v) {
  v = v.trim().toLowerCase();
  if (v.startsWith('#')) {
    var h = v.substring(1);
    if (h.length == 3) {
      h = h.split('').map((c) => '$c$c').join();
    }
    if (h.length == 6) {
      final n = int.tryParse(h, radix: 16);
      if (n != null) return Color(0xFF000000 | n);
    }
    if (h.length == 8) {
      final n = int.tryParse(h, radix: 16);
      if (n != null) return Color(n);
    }
    return null;
  }
  final m = RegExp(r'rgba?\(([^)]+)\)').firstMatch(v);
  if (m != null) {
    final ps = m.group(1)!.split(',').map((e) => e.trim()).toList();
    if (ps.length >= 3) {
      final r = int.tryParse(ps[0]) ?? 0;
      final g = int.tryParse(ps[1]) ?? 0;
      final b = int.tryParse(ps[2]) ?? 0;
      final a = ps.length > 3 ? (double.tryParse(ps[3]) ?? 1) : 1.0;
      return Color.fromARGB((a * 255).round(), r, g, b);
    }
  }
  return null;
}

TextAlign? _align(_Elem el) {
  final raw = el.attrs['style'] ?? '';
  if (raw.contains('text-align')) {
    if (raw.contains('center')) return TextAlign.center;
    if (raw.contains('right')) return TextAlign.right;
    if (raw.contains('justify')) return TextAlign.justify;
  }
  return null;
}

bool _spansEmpty(List<InlineSpan> spans) {
  for (final s in spans) {
    if (s is WidgetSpan) return false;
    if (s is TextSpan && (s.text ?? '').trim().isNotEmpty) return false;
    if (s is TextSpan && (s.children?.isNotEmpty ?? false)) return false;
  }
  return true;
}

String _plainText(_Node n) {
  if (n is _Text) return n.text;
  final el = n as _Elem;
  if (el.tag == 'br') return '\n';
  return el.children.map(_plainText).join();
}

// ============================================================
// 极简 HTML 解析
// ============================================================

abstract class _Node {}

class _Text extends _Node {
  final String text;
  _Text(this.text);
}

class _Elem extends _Node {
  final String tag;
  final Map<String, String> attrs;
  final List<_Node> children = [];
  _Elem(this.tag, this.attrs);
}

const Set<String> _voidTags = {
  'br', 'img', 'hr', 'input', 'meta', 'link', 'source', 'area', 'base',
  'col', 'embed', 'param', 'track', 'wbr',
};

List<_Node> _parseHtml(String html) {
  final root = _Elem('root', const {});
  final stack = <_Elem>[root];
  int i = 0;
  final n = html.length;

  void addText(String raw) {
    if (raw.isEmpty) return;
    // HTML 空白折叠
    var t = raw.replaceAll(RegExp(r'[\r\n\t]+'), ' ');
    t = t.replaceAll(RegExp(r' {2,}'), ' ');
    if (t.trim().isEmpty && !t.contains(' ')) return;
    stack.last.children.add(_Text(_decodeEntities(t)));
  }

  while (i < n) {
    final lt = html.indexOf('<', i);
    if (lt < 0) {
      addText(html.substring(i));
      break;
    }
    if (lt > i) addText(html.substring(i, lt));

    if (html.startsWith('<!--', lt)) {
      final end = html.indexOf('-->', lt + 4);
      i = end < 0 ? n : end + 3;
      continue;
    }
    if (html.startsWith('<!', lt)) {
      final end = html.indexOf('>', lt);
      i = end < 0 ? n : end + 1;
      continue;
    }

    final gt = _findTagEnd(html, lt);
    if (gt < 0) {
      addText(html.substring(lt));
      break;
    }
    final inner = html.substring(lt + 1, gt).trim();
    i = gt + 1;
    if (inner.isEmpty) continue;

    if (inner.startsWith('/')) {
      final tag = inner.substring(1).trim().toLowerCase();
      for (int k = stack.length - 1; k > 0; k--) {
        if (stack[k].tag == tag) {
          stack.removeRange(k, stack.length);
          break;
        }
      }
      continue;
    }

    final selfClose = inner.endsWith('/');
    final body = selfClose ? inner.substring(0, inner.length - 1) : inner;
    final sp = body.indexOf(RegExp(r'[\s]'));
    final tag = (sp < 0 ? body : body.substring(0, sp)).toLowerCase();
    if (tag.isEmpty) continue;
    final attrs =
        sp < 0 ? <String, String>{} : _parseAttrs(body.substring(sp + 1));

    // script / style 直接跳过其内容
    if (tag == 'script' || tag == 'style') {
      final closeIdx = html.toLowerCase().indexOf('</$tag', i);
      if (closeIdx < 0) break;
      final closeEnd = html.indexOf('>', closeIdx);
      i = closeEnd < 0 ? n : closeEnd + 1;
      continue;
    }

    final el = _Elem(tag, attrs);
    // <p> 内遇到新块级：先隐式闭合 p / li
    if ((tag == 'p' || _blockTags.contains(tag)) &&
        (stack.last.tag == 'p' ||
            (stack.last.tag == 'li' && (tag == 'li')))) {
      stack.removeLast();
    }
    stack.last.children.add(el);
    if (!selfClose && !_voidTags.contains(tag)) stack.add(el);
  }
  return root.children;
}

int _findTagEnd(String s, int start) {
  bool inS = false, inD = false;
  for (int i = start + 1; i < s.length; i++) {
    final c = s[i];
    if (c == '"' && !inS) {
      inD = !inD;
    } else if (c == "'" && !inD) {
      inS = !inS;
    } else if (c == '>' && !inS && !inD) {
      return i;
    }
  }
  return -1;
}

final RegExp _attrRe = RegExp(
    '''([a-zA-Z_:][-a-zA-Z0-9_:.]*)\\s*(?:=\\s*(?:"([^"]*)"|'([^']*)'|([^\\s"'>]+)))?''');

Map<String, String> _parseAttrs(String s) {
  final map = <String, String>{};
  for (final m in _attrRe.allMatches(s)) {
    final k = m.group(1)!.toLowerCase();
    final v = m.group(2) ?? m.group(3) ?? m.group(4) ?? '';
    map[k] = _decodeEntities(v);
  }
  return map;
}

const Map<String, String> _entities = {
  'amp': '&', 'lt': '<', 'gt': '>', 'quot': '"', 'apos': "'",
  'nbsp': '\u00A0', 'ldquo': '\u201C', 'rdquo': '\u201D',
  'lsquo': '\u2018', 'rsquo': '\u2019', 'hellip': '\u2026',
  'mdash': '\u2014', 'ndash': '\u2013', 'middot': '\u00B7',
  'times': '\u00D7', 'copy': '\u00A9', 'reg': '\u00AE',
  'laquo': '\u00AB', 'raquo': '\u00BB', 'deg': '\u00B0',
};

final RegExp _entityRe = RegExp(r'&(#x?[0-9a-fA-F]+|[a-zA-Z]+);');

String _decodeEntities(String s) {
  if (!s.contains('&')) return s;
  return s.replaceAllMapped(_entityRe, (m) {
    final e = m.group(1)!;
    if (e.startsWith('#')) {
      final isHex = e.length > 1 && (e[1] == 'x' || e[1] == 'X');
      final code = isHex
          ? int.tryParse(e.substring(2), radix: 16)
          : int.tryParse(e.substring(1));
      if (code != null && code > 0 && code < 0x10FFFF) {
        return String.fromCharCode(code);
      }
      return m.group(0)!;
    }
    return _entities[e.toLowerCase()] ?? m.group(0)!;
  });
}

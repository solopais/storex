import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme.dart';

/// 内嵌 WebView 壳：App 直接加载移动端网页（storex.solopai.cn/mobile.php）
/// 所有功能（音乐/聊天/视频/VIP/公告/收藏/登录）随移动端 100% 同步，
/// 后端更新 App 自动更新，永不脱节。
class WebShell extends StatefulWidget {
  const WebShell({super.key});

  static const String homeUrl = 'https://storex.solopai.cn/mobile.php';

  @override
  State<WebShell> createState() => _WebShellState();
}

class _WebShellState extends State<WebShell> {
  late final WebViewController _ctl;
  bool _loading = true;
  bool _failed = false;
  String _failMsg = '';

  @override
  void initState() {
    super.initState();
    // 页面浅色底，状态栏深色图标
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    _ctl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF2F3F7))
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) {
            setState(() {
              _loading = true;
              _failed = false;
            });
          }
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
        // 关键：子资源（视频/图片/字体）加载失败不要覆盖主页面错误页
        onWebResourceError: (e) {
          if (e.isForMainFrame != true) return; // 只处理主框架本身失败
          if (mounted) {
            setState(() {
              _loading = false;
              _failed = true;
              _failMsg =
                  'code=${e.errorCode}  ${e.description}\n${e.url}';
            });
          }
        },
        // HTTP 层错误也只认主站域名，外链子资源失败一律忽略
        onHttpError: (e) {
          final u = e.request?.uri.toString() ?? '';
          if (!u.startsWith(WebShell.homeUrl)) return;
          if (mounted) {
            setState(() {
              _loading = false;
              _failed = true;
              _failMsg =
                  'HTTP ${e.response?.statusCode} ${e.response?.reasonPhrase}\n$u';
            });
          }
        },
        // 外链（非本站）用系统浏览器打开，不在壳内跳走
        onNavigationRequest: (req) async {
          final u = req.url;
          if (u.startsWith('https://storex.solopai.cn') ||
              u.startsWith('http://storex.solopai.cn') ||
              u.startsWith('about:') ||
              u.startsWith('file:')) {
            return NavigationDecision.navigate;
          }
          final uri = Uri.tryParse(u);
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
          return NavigationDecision.prevent;
        },
      ))
      ..loadRequest(Uri.parse(WebShell.homeUrl));
  }

  void _retry() {
    setState(() {
      _loading = true;
      _failed = false;
    });
    _ctl.loadRequest(Uri.parse(WebShell.homeUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _ctl.canGoBack()) {
          await _ctl.goBack();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: appBg,
        body: Stack(
          children: [
            Positioned.fill(child: WebViewWidget(controller: _ctl)),
            // 顶部细进度条
            if (_loading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: pri,
                  backgroundColor: Colors.transparent,
                ),
              ),
            // 首屏加载遮罩（白屏时不闪烁）
            if (_loading && !_failed)
              Positioned.fill(
                child: Container(
                  color: appBg,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: pri),
                        ),
                        SizedBox(height: 12),
                        Text('加载中...',
                            style: TextStyle(fontSize: 13, color: t3)),
                      ],
                    ),
                  ),
                ),
              ),
            // 错误页
            if (_failed)
              Positioned.fill(
                child: Container(
                  color: appBg,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            size: 52, color: t3),
                        const SizedBox(height: 12),
                        Text(_failMsg,
                            style: const TextStyle(fontSize: 13, color: t3)),
                        const SizedBox(height: 16),
                        Material(
                          color: pri,
                          borderRadius: BorderRadius.circular(22),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: _retry,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 10),
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}

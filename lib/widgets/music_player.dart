import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../globals.dart';
import '../theme.dart';
import 'common.dart';

/// 一比一对应 mobile.css 的 .music-player
/// .music-player{margin:0 16px 16px;radius16;padding:14px 16px;gap:14;shadow 0 2px 8px rgba(0,0,0,.05)}
/// .music-cover{52x52;radius12;渐变 pri→#7C3AED;font-size:22;shadow rgba(99,102,241,.25)}
/// .music-name{14/700;line-height:1.3}  .music-artist{12;t3;margin-top:2}
/// .music-controls{gap:6}
/// .music-play-btn{40x40;圆;bg pri;18px;shadow rgba(99,102,241,.35)}
/// .music-ctrl-btn{32x32;圆;透明;t2;16px}
class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  bool _loading = true;
  bool _has = false;
  String _name = '加载中...';
  String _artist = '--';
  String _pic = '';

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) => _fetch(true));
    _fetch(false); // 与 mobile.js 一致：首次只加载不自动播放
  }

  Future<void> _fetch(bool autoplay) async {
    final api = appConfig?.musicApi ??
        'https://node.api.xfabe.com/api/wangyi/randomMusic?type=json';
    if (!mounted) return;
    setState(() {
      _loading = true;
      _playing = false;
    });
    try {
      final res = await http
          .get(Uri.parse(api))
          .timeout(const Duration(seconds: 10)); // 与移动端 10s 超时一致
      final d = jsonDecode(utf8.decode(res.bodyBytes));
      final data = (d is Map) ? d['data'] : null;
      if (data == null || data['url'] == null) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _has = false;
          _name = '加载失败，点击重试';
          _artist = '--';
          _pic = '';
        });
        return;
      }
      await _player.stop();
      await _player.setSourceUrl(data['url'].toString());
      if (!mounted) return;
      setState(() {
        _name = data['name']?.toString() ?? '未知歌曲';
        _artist = data['artistsname']?.toString() ?? '未知歌手';
        _pic = data['picurl']?.toString() ?? '';
        _has = true;
        _loading = false;
      });
      if (autoplay) _play();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _has = false;
        _name = '加载失败，点击重试';
        _artist = '--';
      });
    }
  }

  Future<void> _play() async {
    try {
      await _player.resume();
      if (mounted) setState(() => _playing = true);
    } catch (_) {}
  }

  Future<void> _pause() async {
    try {
      await _player.pause();
      if (mounted) setState(() => _playing = false);
    } catch (_) {}
  }

  void _toggle() {
    if (!_has) {
      _fetch(true);
      return;
    }
    _playing ? _pause() : _play();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _cover(),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: _has ? null : () => _fetch(true),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: txt,
                          height: 1.3)),
                  const SizedBox(height: 2),
                  Text(_artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: t3)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ctrlBtn(Icons.skip_previous_rounded, () => _fetch(true)),
              const SizedBox(width: 6),
              _playBtn(),
              const SizedBox(width: 6),
              _ctrlBtn(Icons.skip_next_rounded, () => _fetch(true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cover() {
    const grad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [pri, purple],
    );
    final ph = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: grad,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x406366F1), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: _loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.music_note, size: 22, color: Colors.white),
    );
    return NetImg(
        url: _pic, width: 52, height: 52, radius: 12, placeholder: ph);
  }

  /// .music-play-btn 40x40 圆 pri
  Widget _playBtn() {
    return Opacity(
      opacity: _loading ? 0.5 : 1,
      child: Material(
        color: pri,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _loading ? null : _toggle,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              _playing ? Icons.pause : Icons.play_arrow,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// .music-ctrl-btn 32x32 圆 透明 t2
  Widget _ctrlBtn(IconData ic, VoidCallback on) {
    return Opacity(
      opacity: _loading ? 0.4 : 1,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _loading ? null : on,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(ic, size: 16, color: t2),
          ),
        ),
      ),
    );
  }
}

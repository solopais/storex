import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme.dart';
import 'toast.dart';

/// 仿移动端 .vip-modal：卡密激活弹窗
class VipModal extends StatefulWidget {
  final String? purchaseUrl;
  const VipModal({super.key, this.purchaseUrl});

  @override
  State<VipModal> createState() => _VipModalState();
}

class _VipModalState extends State<VipModal> {
  final _code = TextEditingController();
  bool _loading = false;

  Future<void> _activate() async {
    final code = _code.text.trim();
    if (code.isEmpty) {
      Toast.show(context, '请输入卡密');
      return;
    }
    setState(() => _loading = true);
    try {
      final j = await ApiClient.instance.activateVip(code);
      if (j['ok'] == true) {
        Toast.show(context, '激活成功');
        if (mounted) Navigator.pop(context, true);
      } else {
        Toast.show(context, j['msg'] ?? '激活失败');
      }
    } catch (e) {
      Toast.show(context, '激活失败，请重试');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black.withOpacity(0.45),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width - 48,
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('开通VIP会员',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _code,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '请输入VIP卡密',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: bd),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: pri),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _activate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vipDark1,
                        foregroundColor: goldL,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: goldL),
                            )
                          : const Text('立即激活',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  if (widget.purchaseUrl != null &&
                      widget.purchaseUrl!.isNotEmpty &&
                      widget.purchaseUrl != '#')
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: GestureDetector(
                        onTap: () {},
                        child: Text('去购买卡密',
                            style: TextStyle(
                                color: pri,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

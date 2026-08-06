import 'package:flutter/material.dart';
import '../api/models.dart';
import '../theme.dart';

class AppCard extends StatelessWidget {
  final App app;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.app, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _icon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          app.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: inkBlack,
                          ),
                        ),
                      ),
                      if (app.isVip)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          color: kleinBlue,
                          child: const Text('VIP',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app.shortDesc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: softGrey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${app.fileSizeText} · ${app.downloads} 下载',
                    style: const TextStyle(fontSize: 11, color: softGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _icon() {
    const placeholder = Icon(Icons.android, size: 52, color: kleinBlue);
    if (app.icon.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: Image.network(
        app.icon,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}

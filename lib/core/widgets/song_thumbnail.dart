import 'package:flutter/material.dart';

class SongThumbnail extends StatelessWidget {
  final String thumbnailUrl;
  final double width;
  final double height;
  final double borderRadius;

  const SongThumbnail({
    super.key,
    required this.thumbnailUrl,
    this.width = 56,
    this.height = 56,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasThumb = thumbnailUrl.isNotEmpty;
    final bool isNetwork = hasThumb && (thumbnailUrl.startsWith('http://') || thumbnailUrl.startsWith('https://'));

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF2A233D),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: hasThumb
            ? (isNetwork
                ? Image.network(
                    thumbnailUrl,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                  )
                : Image.asset(
                    thumbnailUrl,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                  ))
            : _buildPlaceholderIcon(),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(
        Icons.music_note_rounded,
        color: Color(0xFFAD57E6),
        size: 26,
      ),
    );
  }
}

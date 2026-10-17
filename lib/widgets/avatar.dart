import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    required this.url,
    required this.name,
    this.radius = 16,
  });

  final String url;
  final String name;
  final double radius;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  var _failed = false;

  @override
  Widget build(BuildContext context) {
    final letter = widget.name.isEmpty ? '?' : widget.name.substring(0, 1);
    final showImage = widget.url.isNotEmpty && !_failed;
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: AppColors.violet,
      backgroundImage: showImage ? NetworkImage(widget.url) : null,
      onBackgroundImageError: showImage
          ? (error, stackTrace) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _failed = true);
              });
            }
          : null,
      child: showImage
          ? null
          : Text(
              letter,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.radius * 0.9,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

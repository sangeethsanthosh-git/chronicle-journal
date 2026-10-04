import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/widgets/washi_tape.dart';
import 'package:chronicle/features/scrapbook/domain/models/scrapbook_item.dart';

class CanvasItemWidget extends StatelessWidget {
  final ScrapbookItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onBringToFront;

  const CanvasItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onBringToFront,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: item.rotation,
      child: Transform.scale(
        scale: item.scale,
        child: GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isSelected ? 0.35 : 0.18,
                      ),
                      blurRadius: isSelected ? 16 : 8,
                      offset: const Offset(2, 6),
                    ),
                  ],
                ),
                child: _buildItemContent(context),
              ),

              // Selected Action Overlay
              if (isSelected)
                Positioned(
                  top: -14,
                  right: -14,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionButton(
                        icon: Icons.flip_to_front,
                        tooltip: 'Bring to Front',
                        color: const Color(0xFFC5A059),
                        onPressed: onBringToFront,
                      ),
                      const SizedBox(width: 4),
                      _ActionButton(
                        icon: Icons.delete_outline,
                        tooltip: 'Remove',
                        color: const Color(0xFFE57373),
                        onPressed: onDelete,
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

  Widget _buildItemContent(BuildContext context) {
    switch (item.type) {
      case ScrapbookItemType.photo:
        return _buildPolaroidCard();
      case ScrapbookItemType.note:
        return _buildTornNote();
      case ScrapbookItemType.stamp:
        return _buildPostalStamp();
      case ScrapbookItemType.botanical:
        return _buildBotanicalItem();
      case ScrapbookItemType.waxSeal:
        return _buildWaxSeal();
    }
  }

  Widget _buildPolaroidCard() {
    return Container(
      width: 140,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2DACB), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Washi Tape
          Transform.translate(
            offset: const Offset(0, -14),
            child: const WashiTape(
              width: 55,
              height: 14,
              color: AppColors.washiTapeKraft,
            ),
          ),
          Container(
            height: 100,
            width: double.infinity,
            color: const Color(0xFFEEEAE0),
            child:
                item.content.startsWith('/') && File(item.content).existsSync()
                ? Image.file(File(item.content), fit: BoxFit.cover)
                : const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF837B72),
                    size: 36,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            item.styleMeta ?? 'Memory',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Color(0xFF4A3B32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTornNote() {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6E9),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFDACBB5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Washi Tape corner
          const Align(
            alignment: Alignment.topRight,
            child: WashiTape(
              width: 42,
              height: 12,
              color: AppColors.washiTapeSage,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.content,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF2C2621),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostalStamp() {
    return Container(
      width: 75,
      height: 90,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: const Color(0xFF4A6B82), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.markunread_mailbox_outlined,
            size: 26,
            color: Color(0xFF4A6B82),
          ),
          const SizedBox(height: 4),
          Text(
            item.content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF4A6B82),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotanicalItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xEEF4EDE2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFA3B899), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_rounded, color: Color(0xFF4E853C), size: 20),
          const SizedBox(width: 6),
          Text(
            item.content,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Color(0xFF384E34),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaxSeal() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF8B2525),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.shield_outlined, color: Color(0xFFE2B068), size: 24),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/colors.dart';

Future<String?> showCampaignCompleteDialog({
  required BuildContext context,
  required String campaignId,
}) async {
  final (title, iconAsset, message, achievementId, cosmeticId) = _dataFor(campaignId);
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF3B2F77),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      'Campaign Complete',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Image.asset(
                        iconAsset,
                        height: 96,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.dialogFieldBg.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, color: AppColors.brandGold),
                          const SizedBox(width: 8),
                          Text(
                            achievementId,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop('equip'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandGold,
                            foregroundColor: const Color(0xFF2B221D),
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
                          ),
                          child: const Text('Equip Reward'),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop('close'),
                          child: const Text('Close', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

(String, String, String, String, String) _dataFor(String id) {
  switch (id) {
    case 'buddha':
      return (
        'Buddha Campaign',
        'assets/icons/campaigns/buddha.gif',
        'Master of Calm and Balance. You kept control to the very end.',
        'ACH_BUDDHA',
        'frame_buddha',
      );
    case 'ganesha':
      return (
        'Ganesha Campaign',
        'assets/icons/campaigns/ganesha.png',
        'Solver of Impossible Paths. Your foresight opened the way.',
        'ACH_GANESHA',
        'frame_ganesha',
      );
    case 'shiva':
    default:
      return (
        'Shiva Campaign',
        'assets/icons/campaigns/shiva.png',
        'Bringer of Destruction. You thrived under relentless pressure.',
        'ACH_SHIVA',
        'frame_shiva',
      );
  }
}

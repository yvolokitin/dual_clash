import 'package:flutter/material.dart';
import '../../core/colors.dart';

Future<void> showCampaignIntroDialog({
  required BuildContext context,
  required String campaignId,
}) async {
  final (title, iconAsset, description) = _introDataFor(campaignId);
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
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
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Image.asset(
                        iconAsset,
                        height: 96,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandGold,
                            foregroundColor: const Color(0xFF2B221D),
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
                          ),
                          child: const Text("Let's Go"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Close',
              ),
            ),
          ],
        ),
      );
    },
  );
}

(String, String, String) _introDataFor(String id) {
  switch (id) {
    case 'buddha':
      return (
        'Buddha — Calm Control',
        'assets/icons/campaigns/buddha.gif',
        'Calm, balance, precision. Gray cells buffer infections; no diagonals.\nBe patient, read the board, and steer the flow.',
      );
    case 'ganesha':
      return (
        'Ganesha — Clever Paths',
        'assets/icons/campaigns/ganesha.png',
        'Obstacles and asymmetric layouts demand foresight.\nBombs are tools to unlock paths — plan 2–3 moves ahead.',
      );
    case 'shiva':
    default:
      return (
        'Shiva — Destruction & Pressure',
        'assets/icons/campaigns/shiva.png',
        'Direct capture, no gray cells. Bombs are core and the AI is ruthless.\nStrike decisively and manage the chaos.',
      );
  }
}

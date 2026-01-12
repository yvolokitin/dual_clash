import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/ui/widgets/dialog_header.dart';
import 'package:dual_clash/ui/widgets/responsive_dialog.dart';
import 'package:flutter/material.dart';

/// A reusable, game-agnostic dialog card for saving a game/session.
///
/// It renders a styled dialog with a title, a single text field for the save
/// name, and Cancel/Save actions. The widget itself does not perform any
/// persistence and does not depend on any game controller, making it
/// universal across different game types.
class SaveGameCard extends StatefulWidget {
  final String title;
  final String initialName;
  final ValueChanged<String> onSave;
  final VoidCallback? onCancel;
  final String nameLabel;
  final String saveButtonLabel;
  final String cancelButtonLabel;
  final String nameHint;

  const SaveGameCard({
    super.key,
    required this.title,
    required this.initialName,
    required this.onSave,
    this.onCancel,
    required this.nameLabel,
    required this.saveButtonLabel,
    required this.cancelButtonLabel,
    required this.nameHint,
  });

  @override
  State<SaveGameCard> createState() => _SaveGameCardState();
}

class _SaveGameCardState extends State<SaveGameCard> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _textCtrl.text.trim().isEmpty
        ? widget.initialName
        : _textCtrl.text.trim();
    widget.onSave(name);
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bg;
    final scale = dialogTextScale(context);

    return ResponsiveDialog(
      insetPadding: scaleInsets(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24), scale),
      scrollable: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bg, bg]),
          boxShadow: const [
            BoxShadow(
                color: AppColors.dialogShadow,
                blurRadius: 24,
                offset: Offset(0, 12))
          ],
          border: Border.all(color: AppColors.dialogOutline, width: 1),
        ),
        child: Padding(
          padding: scaleInsets(const EdgeInsets.all(18), scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DialogHeader(
                title: widget.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
                onClose: () {
                  widget.onCancel?.call();
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 12 * scale),
              Text(widget.nameLabel,
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.w700)),
              SizedBox(height: 8 * scale),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1)),
                child: TextField(
                  controller: _textCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12 * scale, vertical: 12 * scale),
                    border: InputBorder.none,
                    hintText: widget.nameHint,
                    hintStyle: const TextStyle(color: Colors.white54),
                  ),
                  onSubmitted: (_) => _handleSave(),
                ),
              ),
              SizedBox(height: 14 * scale),
              Wrap(
                spacing: 12 * scale,
                runSpacing: 8 * scale,
                children: [
                  SizedBox(
                    width: 160,
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onCancel?.call();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24)),
                      child: Text(widget.cancelButtonLabel),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: const Icon(Icons.save),
                      label: Text(widget.saveButtonLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

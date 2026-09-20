import 'dart:async';

import 'package:flutter/material.dart';

import '../services/install_service.dart';
import '../theme/app_colors.dart';

/// Home-screen "Add to Home Screen" card. Three real states, not one:
///
/// - Already installed (standalone): shows nothing, there's nothing to
///   offer someone already using it that way.
/// - iOS Safari: shows instructions only. Apple gives no website a way
///   to trigger "Add to Home Screen" programmatically - only the user's
///   own Share -> Add to Home Screen action works, so a "button" here
///   would just be a lie.
/// - Everyone else (Chrome/Edge/Android, once the browser has actually
///   offered installability): a real one-tap button that triggers the
///   browser's own native install prompt.
class InstallPromptCard extends StatefulWidget {
  const InstallPromptCard({super.key});

  @override
  State<InstallPromptCard> createState() => _InstallPromptCardState();
}

class _InstallPromptCardState extends State<InstallPromptCard> {
  Timer? _pollTimer;
  bool _canAutoInstall = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _canAutoInstall = InstallService.canAutoInstall;
    // Chrome fires `beforeinstallprompt` asynchronously, sometimes a
    // moment after the page first paints - poll briefly rather than only
    // checking once at startup and potentially never showing the button
    // even though the browser did end up offering it.
    if (!_canAutoInstall && !InstallService.isIOS && !InstallService.isStandalone) {
      _pollTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final canInstall = InstallService.canAutoInstall;
        if (canInstall) {
          timer.cancel();
          if (mounted) setState(() => _canAutoInstall = canInstall);
        } else if (timer.tick > 20) {
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _install() async {
    final outcome = await InstallService.promptInstall();
    if (!mounted) return;
    if (outcome == 'accepted') {
      setState(() => _canAutoInstall = false);
    } else if (outcome == 'unavailable') {
      // The captured prompt can only ever be used once; if it's gone by
      // the time the user taps, there's nothing left to offer.
      setState(() => _canAutoInstall = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed || InstallService.isStandalone) return const SizedBox.shrink();

    if (InstallService.isIOS) {
      return _Card(
        icon: Icons.ios_share,
        iconColor: AppColors.primary,
        title: 'Add to Home Screen',
        onDismiss: () => setState(() => _dismissed = true),
        child: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Tap the Share icon in Safari, then "Add to Home Screen" - '
            'iOS only allows this as a manual step, there is no automatic button here.',
          ),
        ),
      );
    }

    if (!_canAutoInstall) return const SizedBox.shrink();

    return _Card(
      icon: Icons.add_to_home_screen,
      iconColor: AppColors.success,
      title: 'Add to Home Screen',
      onDismiss: () => setState(() => _dismissed = true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 12),
            child: Text('Install this as an app icon on your home screen, one tap.'),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _install,
              child: const Text('Add to Home Screen'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    required this.onDismiss,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onDismiss,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close, size: 18, color: AppColors.lightText),
                      ),
                    ),
                  ],
                ),
                DefaultTextStyle(
                  style: TextStyle(fontSize: 14, color: AppColors.lightText, height: 1.4),
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

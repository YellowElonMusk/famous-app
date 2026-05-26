import 'package:flutter/material.dart';
import 'instagram_live_screen.dart';
import 'tiktok_live_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'FakeLive',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose your live platform',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 64),
              _PlatformButton(
                gradient: const LinearGradient(
                  colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                ),
                icon: Icons.camera_alt,
                label: 'Instagram Live',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InstagramLiveScreen()),
                ),
              ),
              const SizedBox(height: 24),
              _PlatformButton(
                gradient: const LinearGradient(
                  colors: [Color(0xFF010101), Color(0xFF69C9D0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.music_note,
                label: 'TikTok Live',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TikTokLiveScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformButton extends StatelessWidget {
  final Gradient gradient;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PlatformButton({
    required this.gradient,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

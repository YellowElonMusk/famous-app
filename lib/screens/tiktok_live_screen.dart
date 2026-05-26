import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/fake_data.dart';
import '../widgets/floating_hearts.dart';
import '../widgets/comment_feed.dart';

class TikTokLiveScreen extends StatefulWidget {
  const TikTokLiveScreen({super.key});

  @override
  State<TikTokLiveScreen> createState() => _TikTokLiveScreenState();
}

class _TikTokLiveScreenState extends State<TikTokLiveScreen> {
  CameraController? _camera;
  bool _cameraReady = false;
  bool _isLive = false;

  final List<FakeComment> _comments = [];
  int _viewers = 12800;
  Timer? _commentTimer;
  Timer? _viewerTimer;
  Timer? _heartTimer;

  final _scrollController = ScrollController();
  final _heartsKey = GlobalKey<FloatingHeartsOverlayState>();
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    CameraDescription? front;
    for (final c in cameras) {
      if (c.lensDirection == CameraLensDirection.front) {
        front = c;
        break;
      }
    }
    final selected = front ?? (cameras.isNotEmpty ? cameras.first : null);
    if (selected == null) return;

    _camera = CameraController(selected, ResolutionPreset.high, enableAudio: false);
    await _camera!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  void _startLive() {
    setState(() {
      _isLive = true;
      _viewers = 12800;
    });

    _commentTimer = Timer.periodic(
      Duration(milliseconds: 700 + _rng.nextInt(1000)),
      (_) => _addComment(),
    );
    _viewerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _viewers = fakeViewerCount(12800));
    });
    _heartTimer = Timer.periodic(
      Duration(milliseconds: 1200 + _rng.nextInt(1500)),
      (_) => _heartsKey.currentState?.addHeart(),
    );

    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 150), _addComment);
    }
  }

  void _stopLive() {
    _commentTimer?.cancel();
    _viewerTimer?.cancel();
    _heartTimer?.cancel();
    setState(() => _isLive = false);
  }

  void _addComment() {
    setState(() {
      _comments.add(randomComment());
      if (_comments.length > 50) _comments.removeAt(0);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _commentTimer?.cancel();
    _viewerTimer?.cancel();
    _heartTimer?.cancel();
    _camera?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_cameraReady && _camera != null)
            CameraPreview(_camera!)
          else
            Container(color: Colors.black87),

          // Top gradient overlay
          Positioned(
            top: 0, left: 0, right: 0, height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.65), Colors.transparent],
                ),
              ),
            ),
          ),

          // Bottom gradient overlay
          Positioned(
            bottom: 0, left: 0, right: 0, height: 360,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                ),
              ),
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  // Avatar
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF69C9D0), width: 2),
                      color: Colors.grey[800],
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'your_username',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        if (_isLive)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'LIVE',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Row(
                                children: [
                                  const Icon(Icons.remove_red_eye, color: Colors.white70, size: 12),
                                  const SizedBox(width: 3),
                                  Text(
                                    formatViewers(_viewers),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Follow button (decorative)
                  if (_isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF69C9D0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Following',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ),

          // Right-side action buttons (TikTok style)
          if (_isLive)
            Positioned(
              right: 12,
              bottom: 130,
              child: Column(
                children: [
                  _SideButton(
                    icon: Icons.person_add,
                    label: 'Invite',
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _SideButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _heartsKey.currentState?.addHeart(),
                    child: Column(
                      children: const [
                        Icon(Icons.favorite, color: Colors.red, size: 32),
                        SizedBox(height: 4),
                        Text('Like', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Floating hearts overlay
          FloatingHeartsOverlay(key: _heartsKey),

          // Comments + bottom bar
          Positioned(
            bottom: 0, left: 0, right: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLive)
                  SizedBox(
                    height: 230,
                    child: CommentFeed(
                      comments: _comments,
                      usernameColor: const Color(0xFF69C9D0),
                    ),
                  ),
                _TikTokBottomBar(
                  isLive: _isLive,
                  onStart: _startLive,
                  onStop: _stopLive,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SideButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white12,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _TikTokBottomBar extends StatelessWidget {
  final bool isLive;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const _TikTokBottomBar({
    required this.isLive,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: isLive
            ? Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(color: Colors.white24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Add a comment...',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onStop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'End Live',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: GestureDetector(
                  onTap: onStart,
                  child: Container(
                    width: 180,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF004F), Color(0xFF69C9D0)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Go LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

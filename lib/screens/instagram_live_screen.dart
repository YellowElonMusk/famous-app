import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/fake_data.dart';
import '../widgets/floating_hearts.dart';
import '../widgets/comment_feed.dart';

class InstagramLiveScreen extends StatefulWidget {
  const InstagramLiveScreen({super.key});

  @override
  State<InstagramLiveScreen> createState() => _InstagramLiveScreenState();
}

class _InstagramLiveScreenState extends State<InstagramLiveScreen> {
  CameraController? _camera;
  bool _cameraReady = false;
  bool _isLive = false;

  final List<FakeComment> _comments = [];
  int _viewers = 12400;
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
      _viewers = 12400;
    });

    _commentTimer = Timer.periodic(
      Duration(milliseconds: 800 + _rng.nextInt(1200)),
      (_) => _addComment(),
    );
    _viewerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _viewers = fakeViewerCount(12400));
    });
    _heartTimer = Timer.periodic(
      Duration(milliseconds: 1500 + _rng.nextInt(2000)),
      (_) => _heartsKey.currentState?.addHeart(),
    );

    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 200), _addComment);
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
          duration: const Duration(milliseconds: 300),
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

          // Dark gradient overlays
          Positioned(
            top: 0, left: 0, right: 0,
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 10),
                  // Profile pic placeholder
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                      ),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'your_username',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (_isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_isLive) ...[
                    // Viewer count
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.remove_red_eye, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            formatViewers(_viewers),
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Close
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white, size: 26),
                  ),
                ],
              ),
            ),
          ),

          // Floating hearts overlay
          FloatingHeartsOverlay(key: _heartsKey),

          // Comments + bottom bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLive)
                  SizedBox(
                    height: 220,
                    child: CommentFeed(
                      comments: _comments,
                      usernameColor: const Color(0xFFC13584),
                    ),
                  ),
                _BottomBar(
                  isLive: _isLive,
                  onStart: _startLive,
                  onStop: _stopLive,
                  onHeart: () => _heartsKey.currentState?.addHeart(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool isLive;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onHeart;

  const _BottomBar({
    required this.isLive,
    required this.onStart,
    required this.onStop,
    required this.onHeart,
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
                  // Comment box (decorative)
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Say something...',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Heart button
                  GestureDetector(
                    onTap: onHeart,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white12,
                      ),
                      child: const Icon(Icons.favorite, color: Colors.red, size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // End live
                  GestureDetector(
                    onTap: onStop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'End',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: GestureDetector(
                  onTap: onStart,
                  child: Container(
                    width: 160,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                      ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Go Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

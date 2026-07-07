import 'package:flutter/material.dart';
import '../models/fake_data.dart';

enum FeedStyle { bubble, twitch }

class CommentFeed extends StatelessWidget {
  final List<FakeComment> comments;
  final Color usernameColor;
  final ScrollController? scrollController;
  final FeedStyle style;
  final Color giftAccent;

  const CommentFeed({
    super.key,
    required this.comments,
    this.usernameColor = Colors.white,
    this.scrollController,
    this.style = FeedStyle.bubble,
    this.giftAccent = const Color(0xFFFFC107),
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black, Colors.black],
        stops: [0.0, 0.15, 1.0],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: comments.length,
        itemBuilder: (_, i) => style == FeedStyle.twitch
            ? _TwitchRow(comment: comments[i], giftAccent: giftAccent)
            : _BubbleRow(
                comment: comments[i],
                usernameColor: usernameColor,
                giftAccent: giftAccent,
              ),
      ),
    );
  }
}

// ── Instagram / TikTok bubble style ───────────────────────────────

class _BubbleRow extends StatelessWidget {
  final FakeComment comment;
  final Color usernameColor;
  final Color giftAccent;

  const _BubbleRow({
    required this.comment,
    required this.usernameColor,
    required this.giftAccent,
  });

  @override
  Widget build(BuildContext context) {
    final c = comment;

    if (c.kind == CommentKind.join) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${c.username} joined',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isGift = c.kind == CommentKind.gift;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: c.color,
            child: Text(
              c.username[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isGift
                    ? giftAccent.withOpacity(0.28)
                    : Colors.black38,
                borderRadius: BorderRadius.circular(12),
                border: isGift
                    ? Border.all(color: giftAccent.withOpacity(0.6))
                    : null,
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${c.username} ',
                      style: TextStyle(
                        color: isGift ? Colors.white : usernameColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: c.text,
                      style: TextStyle(
                        color: isGift ? Colors.white : Colors.white,
                        fontSize: 13,
                        fontWeight:
                            isGift ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Twitch dense chat style ───────────────────────────────────────

class _TwitchRow extends StatelessWidget {
  final FakeComment comment;
  final Color giftAccent;

  const _TwitchRow({required this.comment, required this.giftAccent});

  @override
  Widget build(BuildContext context) {
    final c = comment;

    if (c.kind == CommentKind.join) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          '${c.username} joined the chat',
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    if (c.kind == CommentKind.gift) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF9146FF).withOpacity(0.25),
          border: const Border(
            left: BorderSide(color: Color(0xFF9146FF), width: 3),
          ),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${c.username} ',
                style: TextStyle(
                  color: c.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              TextSpan(
                text: c.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: RichText(
        text: TextSpan(
          children: [
            if (c.badge == 'mod')
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: _Badge(color: Color(0xFF00AD03), icon: Icons.shield),
              ),
            if (c.badge == 'sub')
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: _Badge(color: Color(0xFF9146FF), icon: Icons.star),
              ),
            if (c.badge == 'vip')
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: _Badge(color: Color(0xFFE005B9), icon: Icons.diamond),
              ),
            TextSpan(
              text: '${c.username}: ',
              style: TextStyle(
                color: c.color,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
            TextSpan(
              text: c.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                shadows: [Shadow(blurRadius: 2, color: Colors.black87)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _Badge({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Icon(icon, color: Colors.white, size: 10),
    );
  }
}

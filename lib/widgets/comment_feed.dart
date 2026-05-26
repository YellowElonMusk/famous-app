import 'package:flutter/material.dart';
import '../models/fake_data.dart';

class CommentFeed extends StatelessWidget {
  final List<FakeComment> comments;
  final Color usernameColor;

  const CommentFeed({
    super.key,
    required this.comments,
    this.usernameColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: comments.length,
      itemBuilder: (_, i) {
        final c = comments[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: c.avatarColor,
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
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${c.username} ',
                        style: TextStyle(
                          color: usernameColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: c.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
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
}

import 'dart:math';
import 'package:flutter/material.dart';

class FakeComment {
  final String username;
  final String text;
  final Color avatarColor;

  FakeComment({
    required this.username,
    required this.text,
    required this.avatarColor,
  });
}

final _rng = Random();

final _usernames = [
  'alex_r', 'sarah.j', 'mike99', 'luna_star', 'coolkid22', 'jessx',
  'devmaster', 'noemie_v', 'tyler_k', 'breezy44', 'jakewild', 'emmag',
  'photolife', 'sunny_d', 'kira_m', 'nico.p', 'zara_q', 'cody.r',
  'lily_b', 'maxpower', 'ivy.m', 'theo_x', 'rose.w', 'finn_t',
  'gabi_s', 'ryan_c', 'mia_k', 'noah_j', 'ella_p', 'luca_b',
  'hana_s', 'kai.m', 'ava_g', 'owen_h', 'nora_f', 'leo.v',
  'zoe_r', 'jack_m', 'mila_d', 'ethan_w', 'sofia_n', 'lucas.b',
  'chloe_k', 'mason_r', 'grace_t', 'oliver_p', 'amelia.s', 'elijah_c',
];

final _comments = [
  '🔥🔥🔥', 'omg this is insane!!', 'hi from NYC!', 'love this!!',
  'first!', 'you look amazing', '❤️❤️❤️', 'sending love!',
  'this is so good', 'wow!!', 'hi hi hi', '🥰🥰', 'keep going!!',
  'you rock!!', 'drop the link!', 'collab??', 'legend', '👑👑',
  'no way this is real', 'lmaooo', 'fav creator!!', 'LIVEEE',
  'heyyyy', 'where are you from?', '💯💯', 'stream forever pls',
  'sub 4 sub?', 'first time here!', 'yesss queen', '🎉🎉🎉',
  'i love your vibe', 'always here for this', 'legend status fr',
  '👀👀', 'this slaps', 'just joined!', 'slay!!', '😍😍',
  'goals', 'fire content', 'u r so talented', 'iconic',
  'more more more!', 'never leaving', 'ur the best', '💪💪',
  'hi from London!', 'hi from Brazil 🇧🇷', 'watching from Japan 🇯🇵',
  'watching from Canada 🇨🇦', 'hi from Paris!', 'greetings from Australia 🇦🇺',
];

final _avatarColors = [
  const Color(0xFFE91E63), const Color(0xFF9C27B0), const Color(0xFF3F51B5),
  const Color(0xFF2196F3), const Color(0xFF009688), const Color(0xFF4CAF50),
  const Color(0xFFFF9800), const Color(0xFFF44336), const Color(0xFF00BCD4),
  const Color(0xFF8BC34A),
];

FakeComment randomComment() {
  return FakeComment(
    username: _usernames[_rng.nextInt(_usernames.length)],
    text: _comments[_rng.nextInt(_comments.length)],
    avatarColor: _avatarColors[_rng.nextInt(_avatarColors.length)],
  );
}

int fakeViewerCount(int base) {
  return base + _rng.nextInt(500) - 250;
}

String formatViewers(int count) {
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}

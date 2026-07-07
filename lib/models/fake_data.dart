import 'dart:math';
import 'package:flutter/material.dart';

final _rng = Random();

enum LivePlatform { instagram, tiktok, twitch }

enum CommentKind { chat, join, gift }

class FakeComment {
  final String username;
  final String text;
  final Color color;
  final CommentKind kind;
  final String? badge; // 'mod' | 'sub' | 'vip' | 'top'

  FakeComment({
    required this.username,
    required this.text,
    required this.color,
    this.kind = CommentKind.chat,
    this.badge,
  });
}

// ── Usernames ─────────────────────────────────────────────────────

const _igUsernames = [
  'alex.rivera', 'sarah_jbeauty', 'mike.travels', 'luna_star22', 'jessx.o',
  'noemie_vlogs', 'tyler.knox', 'breezy.44', 'jake_wild', 'emma.gracee',
  'photolife_dan', 'sunny.dayz', 'kira_makes', 'nico.paris', 'zara_fit',
  'lily.bakes', 'ivy_moon', 'rose.wanders', 'gabi_styles', 'mia.k.art',
  'ella_petite', 'hana.seoul', 'ava_glow', 'nora.films', 'zoe_reads',
  'mila.dances', 'sofia_nyc', 'chloe.kim', 'grace_tan', 'amelia.smiles',
];

const _tiktokUsernames = [
  'user8829102', 'itzz.maya', 'notlucas.mp4', 'k4yden', 'sk8er.emma',
  'yourfavgirl_ari', 'dre4mcore', 'll.jayden.ll', 'p1nkglossx', 'ur.mom.lol',
  'vibezwithkai', 'gothgf.dee', 'ratedR_riley', 'y2k.baby.x', 'moonlqt',
  'user0021password', 'certifiedloverboyy', 'xo.zaria', 'brainrot.ben',
  'slaymaster3000', 'itsgigi.fr', 'delulu.dana', 'sigma.sam.7', 'npc.natalie',
  'corecore.cam', 'fanum.tax.collector', 'gyatt.lord99', 'rizzlord.max',
];

const _twitchUsernames = [
  'PogChampion_42', 'xX_ShadowSlayer_Xx', 'TTV_KappaKing', 'NoScopeNina',
  'GigaChadGamer', 'SaltyPixels', 'LagSpike_Larry', 'CritHitCarl',
  'MidLaneMia', 'ClutchOrKick', 'BigBrainBenny', 'FeedOrAFK',
  'PepegaPatrol', 'KEKW_Kevin', 'SneakyBeaky_Sam', 'TiltedTina',
  'RespawnRandy', 'GGEZ_Greg', 'WhiffMaster', 'CopiumDealer',
  'MonkaS_Mark', 'JuicerJulia', '5HeadHannah', 'MaldingMax',
  'DiffedDaily', 'RatioedRick', 'BasementDweller_77', 'TouchGrassTom',
];

// ── Chat messages ─────────────────────────────────────────────────

const _igComments = [
  'omg hiii 😍', 'you look so good today', 'love from NYC ❤️',
  'wait you\'re live?? YAY', 'literally obsessed with you', 'queen 👑',
  'can you do a q&a?', 'your skin is glowing what do you use',
  'been following since 2021 🥹', 'say hi to me pls!!', 'the vibes ✨',
  'my fav notification 🔔', 'girl the LIGHTING', 'so pretty omg',
  'greetings from Brazil 🇧🇷', 'hi from London!', 'watching from Tokyo 🇯🇵',
  'this made my day', 'ok but where is that top from', 'link in bio?',
  'pls collab with emma!!', 'your energy is everything', 'ur so real for this',
  'aww hi!! 💕', 'first time catching u live!!', 'CUTIE ALERT 🚨',
  'the way i RAN here', 'notification squad 🏃‍♀️', 'love uuu',
  'can u show the fit?', 'story time pls', 'u inspire me sm 🥺',
];

const _tiktokComments = [
  'W stream', 'GYATTTT', 'chat is this real', 'no shot 💀',
  'the rizz is crazy', 'certified banger stream', 'ayooo 😭😭',
  'bro cooked', 'this is so ohio', 'real ones know', 'CAUGHT IN 4K',
  'lowkey fire ngl', 'sheeeesh 🔥', 'nah he tweakin', 'its giving main character',
  'POV: best live on the fyp', 'the fyp brought me here', 'slayyy',
  'im deceased 💀💀', 'do the dance!!', 'say my name pls im begging',
  'skibidi W', 'gng this crazy', 'fanum taxed my dinner for this',
  'mood fr', 'its the ___ for me', 'not me watching at 3am 😭',
  'u dropped this 👑', 'ate and left no crumbs', 'era defining stream',
  'me n who watching this', 'him: 📈📈📈', 'BFFR 😭', 'fr fr no cap',
];

const _twitchComments = [
  'PogChamp', 'KEKW', 'LETS GOOO', 'W', 'L + ratio', 'no way LULW',
  'CLIP IT', 'chat is this real?', 'monkaS', 'EZ Clap', '5Head play',
  'Pepega', 'actually insane', 'MODS BAN HIM KEKW', 'F in the chat',
  'copium overdose', 'he\'s cracked', 'DIFF', 'GIGACHAD', 'sadge',
  'first time chatter hi!!', 'POGGERS', 'that was clean', 'NA server btw',
  'lag diff', 'skill issue tbh', 'W streamer', 'built different',
  'chat spam W in chat', 'WWWWWWW', 'jebaited', 'OMEGALUL',
  'stream sniper?', 'crit RNG carried', 'notify gang', '?!?!?!?!',
  'GG', 'this guy pings', 'literally 1v5', 'HUGE', 'peepoClap',
];

// ── Join / gift events ────────────────────────────────────────────

const _igGifts = [
  'sent a ❤️', 'sent a 🔥', 'shared this live to their story',
  'sent a 👏👏👏', 'sent a 😍',
];

const _tiktokGifts = [
  'sent a Rose 🌹', 'sent a Rose 🌹 x5', 'sent a Finger Heart 🫰',
  'sent a Galaxy 🌌', 'sent an Ice Cream 🍦', 'sent a Lion 🦁',
  'sent a GG 🎮', 'sent Doughnut 🍩 x3',
];

const _twitchGifts = [
  'subscribed for 3 months!', 'just subscribed with Prime!',
  'gifted 5 subs to the community!', 'cheered 100 bits! Cheer100',
  'subscribed for 12 months! PogChamp', 'gifted a sub to KEKW_Kevin!',
  'cheered 500 bits!! 🎉', 'is now a VIP!',
];

// ── Colors ────────────────────────────────────────────────────────

const _avatarColors = [
  Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFF3F51B5),
  Color(0xFF2196F3), Color(0xFF009688), Color(0xFF4CAF50),
  Color(0xFFFF9800), Color(0xFFF44336), Color(0xFF00BCD4),
  Color(0xFF8BC34A),
];

// Twitch chat username colors (their classic palette)
const _twitchColors = [
  Color(0xFFFF0000), Color(0xFF0000FF), Color(0xFF00FF00),
  Color(0xFFB22222), Color(0xFFFF7F50), Color(0xFF9ACD32),
  Color(0xFFFF4500), Color(0xFF2E8B57), Color(0xFFDAA520),
  Color(0xFFD2691E), Color(0xFF5F9EA0), Color(0xFF1E90FF),
  Color(0xFFFF69B4), Color(0xFF8A2BE2), Color(0xFF00FF7F),
];

// ── Generators ────────────────────────────────────────────────────

List<String> _namesFor(LivePlatform p) => switch (p) {
      LivePlatform.instagram => _igUsernames,
      LivePlatform.tiktok => _tiktokUsernames,
      LivePlatform.twitch => _twitchUsernames,
    };

List<String> _chatFor(LivePlatform p) => switch (p) {
      LivePlatform.instagram => _igComments,
      LivePlatform.tiktok => _tiktokComments,
      LivePlatform.twitch => _twitchComments,
    };

List<String> _giftsFor(LivePlatform p) => switch (p) {
      LivePlatform.instagram => _igGifts,
      LivePlatform.tiktok => _tiktokGifts,
      LivePlatform.twitch => _twitchGifts,
    };

Color _colorFor(LivePlatform p) => p == LivePlatform.twitch
    ? _twitchColors[_rng.nextInt(_twitchColors.length)]
    : _avatarColors[_rng.nextInt(_avatarColors.length)];

String? _badgeFor(LivePlatform p) {
  if (p != LivePlatform.twitch) return null;
  final roll = _rng.nextInt(100);
  if (roll < 4) return 'mod';
  if (roll < 18) return 'sub';
  if (roll < 22) return 'vip';
  return null;
}

FakeComment randomComment(LivePlatform platform) {
  final names = _namesFor(platform);
  final name = names[_rng.nextInt(names.length)];
  final color = _colorFor(platform);
  final roll = _rng.nextInt(100);

  if (roll < 8) {
    return FakeComment(
      username: name,
      text: 'joined',
      color: color,
      kind: CommentKind.join,
    );
  }
  if (roll < 16) {
    final gifts = _giftsFor(platform);
    return FakeComment(
      username: name,
      text: gifts[_rng.nextInt(gifts.length)],
      color: color,
      kind: CommentKind.gift,
      badge: _badgeFor(platform),
    );
  }
  final chat = _chatFor(platform);
  return FakeComment(
    username: name,
    text: chat[_rng.nextInt(chat.length)],
    color: color,
    kind: CommentKind.chat,
    badge: _badgeFor(platform),
  );
}

/// Smoothly drifting viewer count: small ticks, slight upward bias,
/// occasional mini raid/drop so the number feels alive but never jumps
/// hundreds at once.
class ViewerDrift {
  int value;
  final int floor;
  final int ceil;

  ViewerDrift(this.value)
      : floor = value - 1800,
        ceil = value + 3200;

  int tick() {
    final roll = _rng.nextInt(100);
    int delta;
    if (roll < 6) {
      delta = 80 + _rng.nextInt(240); // small raid
    } else if (roll < 12) {
      delta = -(60 + _rng.nextInt(180)); // small dip
    } else {
      delta = _rng.nextInt(50) - 20; // gentle drift, upward bias
    }
    value = (value + delta).clamp(floor, ceil);
    return value;
  }
}

String formatViewers(int count) {
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}

/// Bursty delay for the next comment: usually quick, sometimes a lull,
/// mimicking real chat rhythm.
Duration nextCommentDelay(LivePlatform p) {
  final fast = p == LivePlatform.twitch; // twitch chat is fastest
  final roll = _rng.nextInt(100);
  if (roll < 20) return Duration(milliseconds: 80 + _rng.nextInt(180)); // burst
  if (roll < 88) {
    return Duration(milliseconds: (fast ? 200 : 300) + _rng.nextInt(500));
  }
  return Duration(milliseconds: 1200 + _rng.nextInt(1400)); // lull
}

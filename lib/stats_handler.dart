// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import 'firebase_access.dart';
import 'parameters.dart' as param;

/// Displays team sats.
class StatsHandler extends SlackCommandHandler {
  final Logger _log = new Logger('StatsHandler');

  @override
  Future<Response> handle(Request request) async {
    final params = request.context;
    final String userName = params[SLACK_USERNAME];
    final String userId = params[SLACK_USER_ID];
    final FirebaseAccess client = params[param.FIREBASE_ACCESS];
    _log.info('Stats requested by $userName');
    final statsByUser = await client.getStatsByUser();
    final List<String> userTags = statsByUser.containsKey(userId)
        ? statsByUser[userId]['stats'].map((Map stat) => stat['battletag'])
        : [];
    final stats = statsByUser.values
        .expand((Map<String, dynamic> user) => user['stats'] ?? const [])
        .toList()..sort((Map a, Map b) => b['sr'] - a['sr']);
    final content = stats.map((Map stat) {
      final String tag = stat['battletag'];
      final linkTag = tag.replaceAll('#', '-');
      final shortTag = tag.substring(0, tag.indexOf('#')); // Max length: 12
      final link = new Uri.https('www.overbuff.com', '/players/pc/$linkTag');
      final name = '<$link|$shortTag>' + ''.padRight(12 - shortTag.length);
      final sr = '${stat['sr']}'.padLeft(4);
      final suffix = userTags.contains(tag) ? '<<' : '';
      return '$name $sr $suffix';
    }).join('\n');
    return createTextResponse('```$content```');
  }
}

// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import 'firebase_access.dart';
import 'parameters.dart' as param;

/// Displays the team roster.
class RosterHandler extends SlackCommandHandler {
  final Logger _log = new Logger('RosterHandler');

  @override
  Future<Response> handle(Request request) async {
    final params = request.context;
    final String userName = params[SLACK_USERNAME];
    final FirebaseAccess client = params[param.FIREBASE_ACCESS];
    _log.info('Roster requested by $userName');
    final battletags = await client.getBattletags();
    final content = battletags.map((String tag) {
      final sanitizedTag = tag.replaceAll('#', '-');
      final link =
          new Uri.https('www.overbuff.com', '/players/pc/$sanitizedTag');
      return '<$link|$tag>';
    }).join('\n');
    return createTextResponse('```$content```');
  }
}

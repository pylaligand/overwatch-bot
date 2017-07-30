// Copyright (c) 2017 P.Y. Laligand

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import '../lib/configuration.dart' as config;
import '../lib/firebase_access.dart';

/// Updates the Firebase database with data from Slack and other sources.
class SyncTask extends BackgroundTask {
  @override
  List<String> get environmentVariables => config.ALL;

  /// Extracts battletags from a data string.
  List<String> _extractBattletags(String data) {
    // TODO(pylaligand): handle accentuated characters properly.
    final pattern = new RegExp(r'[a-zA-Z][a-zA-Z0-9]{2,11}#\d{3,}');
    if (data == null || data.isEmpty) {
      return const [];
    }
    return pattern
        .allMatches(data)
        .map((Match match) => match.group(0))
        .toList();
  }

  @override
  execute() async {
    final log = new Logger('DataSyncer');
    log.info('Getting users...');
    final users = await slackClient.listUsers();
    log.info('Found ${users.length} users.');
    final tags = users
        .expand((SlackUser user) => _extractBattletags(user.title))
        .toList()..sort();
    log.info('Extracted ${tags.length} tags.');
    final client = new FirebaseAccess(
      environment[config.FIREBASE_SECRET],
      environment[config.FIREBASE_DATABASE],
    );
    await client.setBattleTags(tags);
    log.info('Database updated!');
  }
}

main(List<String> args) async {
  await new SyncTask().run();
}

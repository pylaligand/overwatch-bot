// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import '../lib/configuration.dart' as config;
import '../lib/firebase_access.dart';
import '../lib/overwatch_client.dart';

/// Updates the Firebase database with data from Slack and other sources.
class SyncTask extends BackgroundTask {
  final bool _debug;

  SyncTask(this._debug);

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

  Future<Map<String, UserSummary>> _fetchStats(
      List<String> battletags, Logger log) async {
    final client = new OverwatchClient();
    final summaries = {};
    await Future.forEach(battletags, (String tag) async {
      log.info('Fetching $tag...');
      summaries[tag] = await client.getUserInfo(tag, log);
    });
    return summaries;
  }

  @override
  execute() async {
    final log = new Logger('DataSyncer');
    final client = new FirebaseAccess(
      environment[config.FIREBASE_SECRET],
      environment[config.FIREBASE_DATABASE],
    );

    log.info('Fetching users...');
    final userList = await slackClient.listUsers();
    final users = _debug ? userList.take(5).toList() : userList;
    log.info('Found ${users.length} users.');
    final Map<SlackUser, List<String>> tagsByUser = new Map.fromIterable(users,
        value: (SlackUser user) => _extractBattletags(user.title));
    final tags = tagsByUser.values.expand((List<String> tags) => tags).toList()
      ..sort();
    log.info('Extracted ${tags.length} tags.');
    await client.setBattleTags(tags);
    log.info('Battletags updated!');

    final stats = {};
    log.info('Fetching stats...');
    final summaries = await _fetchStats(tags, log);
    await Future.forEach(users, (SlackUser user) async {
      final tags = tagsByUser[user] ?? const [];
      stats[user.id] = {
        'name': user.name,
        'stats': tags
            .map((String tag) => summaries[tag])
            .map((UserSummary summary) => {
                  'battletag': summary.battletag,
                  'sr': summary.skillRating,
                })
            .toList(),
      };
    });
    await client.setStatsByUser(stats);
    log.info('Stats updated!');
  }
}

main(List<String> args) async {
  await new SyncTask(args.length == 1 && args[0] == "--debug").run();
}

// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

const List<String> _REGIONS = const ['us', 'eu', 'kr'];

/// Info about a given user.
class UserSummary {
  final String battletag;
  final Map<String, dynamic> _stats;

  UserSummary.fromJson(this.battletag, Map<String, dynamic> data)
      : _stats =
            data[_REGIONS.firstWhere((String key) => data.containsKey(key))];

  dynamic get stats => _stats;

  int get skillRating {
    if (_stats['stats']['competitive'] == null) {
      return 0;
    }
    return _stats['stats']['competitive']['overall_stats']['comprank'];
  }
}

/// Interface for the OW API.
class OverwatchClient {
  final _log = new Logger('OverwatchClient');

  /// Returns a user's profile.
  Future<UserSummary> getUserInfo(String battletag) async {
    final sanitizedTag = battletag.replaceAll('#', '-');
    final url = new Uri.https('owapi.net', 'api/v3/u/$sanitizedTag/blob');
    final data = await getJson(url, _log);
    return new UserSummary.fromJson(battletag, data);
  }
}

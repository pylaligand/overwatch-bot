// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

const List<String> _REGIONS = const ['us', 'eu', 'kr'];

/// Info about a given user.
abstract class UserSummary {
  String get battletag;
  int get skillRating;
}

class _DataUserSummary implements UserSummary {
  @override
  final String battletag;
  final Map<String, dynamic> _stats;

  _DataUserSummary.fromJson(this.battletag, Map<String, dynamic> data)
      : _stats =
            data[_REGIONS.firstWhere((String key) => data.containsKey(key))];

  @override
  int get skillRating {
    if (_stats['stats']['competitive'] == null) {
      return 0;
    }
    return _stats['stats']['competitive']['overall_stats']['comprank'] ?? 0;
  }
}

class _EmptyUserSummary implements UserSummary {
  @override
  final String battletag;

  _EmptyUserSummary(this.battletag);

  @override
  int get skillRating => 0;
}

/// Interface for the OW API.
class OverwatchClient {
  final _log = new Logger('OverwatchClient');

  /// Returns a user's profile.
  Future<UserSummary> getUserInfo(String battletag, Logger log) async {
    final sanitizedTag = battletag.replaceAll('#', '-');
    final url = new Uri.https('owapi.net', 'api/v3/u/$sanitizedTag/blob');
    return getJson(url, _log)
        .then((Map<String, dynamic> data) =>
            new _DataUserSummary.fromJson(battletag, data))
        .catchError((_) {
      log.warning('Could not find profile for $battletag');
      return new _EmptyUserSummary(battletag);
    }, test: (e) => e is JsonException && e.code == 404);
  }
}

// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:firebase/firebase_io.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:heroku_slack_bot/heroku_slack_bot.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import '../lib/configuration.dart' as config;

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

  Future<FirebaseClient> _initializeFirebase() async {
    final secret = environment[config.FIREBASE_SECRET];
    final credentials = new ServiceAccountCredentials.fromJson(secret);
    final httpClient = await clientViaServiceAccount(credentials, [
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/userinfo.email'
    ]);
    return new FirebaseClient.anonymous(client: new _ClientWrapper(httpClient));
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
    final firebaseClient = await _initializeFirebase();
    final database = environment[config.FIREBASE_DATABASE];
    final data = {
      'last_updated': new DateTime.now().toString(),
      'list': tags,
    };
    await firebaseClient.put(new Uri.https(database, 'battletags.json'), data);
    log.info('Database updated!');
  }
}

/// Transforms a [Client] into a [BaseClient].
///
/// This allows us to connect the Google auth library with the Firebase client
/// library.
class _ClientWrapper extends BaseClient {
  final Client _client;

  _ClientWrapper(this._client);

  @override
  Future<StreamedResponse> send(BaseRequest request) => _client.send(request);

  @override
  close() => _client.close();
}

main(List<String> args) async {
  await new SyncTask().run();
}

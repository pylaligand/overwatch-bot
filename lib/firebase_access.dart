// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:firebase/firebase_io.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

class FirebaseAccess {
  final String _secret;
  final String _database;
  FirebaseClient _client;

  FirebaseAccess(this._secret, this._database);

  Future<FirebaseClient> get _access async {
    if (_client != null) {
      return _client;
    }
    final credentials = new ServiceAccountCredentials.fromJson(_secret);
    final httpClient = await clientViaServiceAccount(credentials, [
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/userinfo.email'
    ]);
    _client =
        new FirebaseClient.anonymous(client: new _ClientWrapper(httpClient));
    return _client;
  }

  setBattleTags(List<String> tags) async {
    final client = await _access;
    final data = {
      'last_updated': new DateTime.now().toString(),
      'list': tags,
    };
    await client.put(new Uri.https(_database, 'battletags.json'), data);
  }

  Future<List<String>> getBattletags() async =>
      (await _access).get(new Uri.https(_database, 'battletags/list.json'));
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

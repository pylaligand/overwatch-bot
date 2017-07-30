// Copyright (c) 2017 P.Y. Laligand

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import 'firebase_access.dart';
import 'parameters.dart' as param;

/// Injects a client for the Firebase API.
class FirebaseAccessProvider {
  static Middleware get(String secret, String database) => (Handler handler) =>
      (Request request) => handler(request.change(context: {
            param.FIREBASE_ACCESS: new FirebaseAccess(secret, database),
          }));
}

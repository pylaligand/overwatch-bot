// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

/// Does not do anything useful, really.
class DummyHandler extends SlackCommandHandler {
  final Logger _log = new Logger('DummyHandler');

  @override
  Future<Response> handle(Request request) async {
    final params = request.context;
    final String userName = params[SLACK_USERNAME];
    _log.info('Request from $userName');
    return createTextResponse('Hello $userName!', private: true);
  }
}

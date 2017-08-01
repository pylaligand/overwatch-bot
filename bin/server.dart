// Copyright (c) 2017 P.Y. Laligand

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import '../lib/configuration.dart' as config;
import '../lib/firebase_provider.dart';
import '../lib/roster_handler.dart';
import '../lib/stats_handler.dart';

class Config extends ServerConfig {
  @override
  String get name => 'OverwatchSlackBot';

  @override
  List<String> get environmentVariables => config.ALL;

  @override
  Map<String, SlackCommandHandler> loadCommands(Map<String, String> env) => {
        'roster': new RosterHandler(),
        'stats': new StatsHandler(),
      };

  @override
  List<Middleware> loadMiddleware(Map<String, String> env) => [
        FirebaseAccessProvider.get(
            env[config.FIREBASE_SECRET], env[config.FIREBASE_DATABASE])
      ];

  @override
  List<String> get stallingMessages => [
        'Command executing in 15 seconds...',
        'Cheers love, the cavalry is (almost) here...',
      ];
}

main() async {
  await runServer(new Config());
}

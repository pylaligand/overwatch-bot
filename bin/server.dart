// Copyright (c) 2017 P.Y. Laligand

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import '../lib/dummy_handler.dart';

class Config extends ServerConfig {
  @override
  String get name => 'OverwatchSlackBot';

  @override
  Map<String, SlackCommandHandler> loadCommands(Map<String, String> env) => {
        'dummy': new DummyHandler(),
      };

  @override
  List<String> get stallingMessages => [
        'Command executing in 15 seconds...',
        'Cheers love, the cavalry is (almost) here...',
      ];
}

main() async {
  await runServer(new Config());
}

// Copyright (c) 2017 P.Y. Laligand

package net.zerowatch;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Starts the web server backing the bot.
 */
 @SpringBootApplication(scanBasePackages = {
   "me.ramswaroop.jbot",
   "net.zerowatch"})
@SuppressWarnings("checkstyle:hideutilityclassconstructor")
public class SlackBotApplication {

  public static void main(String[] args) {
    SpringApplication app = new SpringApplication(SlackBotApplication.class);
    app.run(args);
  }
}

package net.zerowatch;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import me.ramswaroop.jbot.core.slack.models.RichMessage;

/**
 * Handles request for SR lookups.
 */
@RestController
public final class SkillRatingCommand {

  @RequestMapping(value = "/test",
      method = RequestMethod.GET)
  public RichMessage onReceiveSlashCommand(
      @RequestParam("something") String something) {
    return new RichMessage("Got: " + something);
  }
}

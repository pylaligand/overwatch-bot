package net.zerowatch;

import me.ramswaroop.jbot.core.slack.models.RichMessage;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Handles request for SR lookups.
 */
@RestController
public final class SkillRatingCommand {

  @RequestMapping(value = "/skills",
      method = RequestMethod.POST,
      consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
  public RichMessage onReceiveSlashCommand(
      @RequestParam("user_name") String userName) {
    RichMessage result = new RichMessage("Hello " + userName + "!");
    result.setResponseType("in_channel");
    return result.encodedMessage();
  }
}

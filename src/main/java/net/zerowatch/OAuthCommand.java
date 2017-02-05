package net.zerowatch;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

/**
 * Handles oAuth requests.
 */
 @RestController
public final class OAuthCommand {

  @Value("${slackClientId}")
  private String clientId;

  @Value("${slackClientSecret}")
  private String clientSecret;

  @Value("${slackRedirectUri}")
  private String redirectUri;

  @RequestMapping(value = "/auth",
      method = RequestMethod.GET)
  public ResponseEntity onAuth(@RequestParam("code") String code) {
    System.out.println("Received authentication code");
    RestTemplate rest = new RestTemplate();
    String urlTemplate = "https://slack.com/api/oauth.access"
        + "?code={code}"
        + "&client_id={id}"
        + "&client_secret={secret}"
        + "&redirect_uri={uri}";
    OAuthParams params = rest.getForObject(
        urlTemplate,
        OAuthParams.class, code, clientId, clientSecret, redirectUri);
    if (!params.getOk()) {
      System.out.println("Authentication error: " + params.getError());
      return new ResponseEntity(HttpStatus.UNAUTHORIZED);
    }
    System.out.println("Access token: " + params.getAccessToken());
    return new ResponseEntity<String>("Good to go!", HttpStatus.OK);
  }

  /**
   * Contains the response to an oAuth access request.
   */
  @JsonIgnoreProperties(ignoreUnknown = true)
  @JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
  public static final class OAuthParams {

    private boolean mOk;
    public void setOk(boolean ok) {
      mOk = ok;
    }
    public boolean getOk() {
      return mOk;
    }

    private String mError;
    public void setError(String error) {
      mError = error;
    }
    public String getError() {
      return mError;
    }

    private String mAccessToken;
    public void setAccessToken(String accessToken) {
      mAccessToken = accessToken;
    }
    public String getAccessToken() {
      return mAccessToken;
    }
  }
}

// The following http params are required to generate an access token: 
// identity=
// apiKeySecret=
// &appSid=
// apiKeySid=


exports.handler = function(context, event, callback) {
    const response = new Twilio.Response();

    // Add CORS Headers
    let headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET",
        "Content-Type": "application/json"
    };
  
    // Set headers in response
    response.setHeaders(headers);
    
    const identity = event.identity;
    const apiKeySecret = event.apiKeySecret;
    const appSid = event.appSid;
    const apiKeySid = event.apiKeySid;

    // grab the identity from the URL
    if (!identity || !apiKeySecret || !appSid || !apiKeySecret) {
        response.setStatusCode(400);
        callback(`Sorry, can't do, missing a required param`);
        return;
    }
  
    const AccessToken = require('twilio').jwt.AccessToken;
    const VoiceGrant = AccessToken.VoiceGrant;

    // Create an access token which we will sign and return to the client,
    // containing the grant we just created
    const voiceGrant = new VoiceGrant({
        // This is the TwiML app that the client will call out to. This parameter is
        // required, even if the client wants to call a PSTN number directly.
        outgoingApplicationSid: appSid,

        // This would allow push notifications for mobile
        //pushCredentialSid: null,

        // This client can receive calls
        incomingAllow: true
    });

  // Create an access token which we will sign and return to the client,
  // containing the grant we just created
  const token = new AccessToken(context.ACCOUNT_SID, apiKeySid, apiKeySecret);
  token.addGrant(voiceGrant);
  token.identity = identity;

  // Include identity and token in a JSON response
  response.setBody({
    'identity': identity,
    'token': token.toJwt()
  });
  
  response.setStatusCode(200);
  callback(null, response);
};
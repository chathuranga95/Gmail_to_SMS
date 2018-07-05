import wso2/twilio;
import ballerina/http;
import ballerina/io;
import ballerina/config;

//retrieve necessary variables from the config file
string myphone = config:getAsString("myphone");
string twilioSenderPhone = config:getAsString("twilioSenderPhone");
string accountSId = config:getAsString("accountSId");
string authToken = config:getAsString("authToken");

//twilio end point
endpoint twilio:Client twilioClient {
    accountSId:accountSId,
    authToken:authToken
};

// A service endpoint represents a listener
endpoint http:Listener listener {
    port: 9091
};

@http:ServiceConfig {
   basePath: "/"
}
// A service is a network-accessible API
// Advertised on '/hello', port comes from listener endpoint
service<http:Service> SMS bind listener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }

    // A resource is an invokable API method
    // Accessible at '/SMS/sendSMS
    // 'caller' is the client invoking this resource 
    sendSMS(endpoint caller, http:Request request) {

        //get the parameter values and send the sms with twilio
        var textpayload = request.getTextPayload();
        match textpayload{
            string txt => sendTextMessage(twilioSenderPhone,myphone,txt);
            error err => io:println(err);
        }

        // Create object to carry data back to caller
        http:Response response = new;

        //tell the caller that the SMS is sent
        response.setTextPayload("SMS sent...!\n");

        // Send a response back to caller
        // Errors are ignored with '_'
        // -> indicates a synchronous network-bound call
        _ = caller->respond(response);
    }
}

//function to send SMS to phone number using twilio
function sendTextMessage(string fromMobile, string toMobile, string message) {
    var details = twilioClient->sendSms(fromMobile, toMobile, message);
    match details {
        twilio:SmsResponse smsResponse => io:println(smsResponse);
        twilio:TwilioError twilioError => io:println(twilioError);
    }
}
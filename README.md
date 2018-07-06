# Gmail to SMS

Gmail to SMS is a project which is developed using ballerina to receive SMS notifications when a gmail is arrived at a specified label.

## A high level architectural view.
The basic components of the Gmail to SMS is as following diagram.

![Alt](https://github.com/chathuranga95/Gmail_to_SMS/blob/master/Architectural%20diagram.jpg)

## Running the Code.
To run the code, first download this git repository and follow the below guide.
1. Obtain the Gmail API details using [O Auth 2.0 Playground](https://developers.google.com/oauthplayground/). Select and authorize Gmail API v1 and "https://mail.google.com/".
2. You can obtain your ```filteringLabelID``` by using [Gmail API](https://developers.google.com/gmail/api/v1/reference/users/labels/list). On the "Try this API" pane, Input your email to ```userId``` field and click "Execute".
3. Obtain the Twilio API details by login in to twilio. You have to create an account if you don't have one.
4. Edit the __ballerina.conf__ file with your gmail and twilio account details.

```java
#gmail API details

accessToken = "access token for gmail"

clientId = "client ID for gmail"

clientSecret = "client secret for gmail"

refreshToken = "refresh token for gmail"

MYEMAIL = "youremail@gmail.com"

filteringLabelID = "Label_1"

#twilio account details

accountSId = "twilio account SId"

authToken = "twilio auth token"

myphone = "+94XXXXXXXXX"

twilioSenderPhone = "+XXXXXXXXXXX"
```
4. Navigate to the Gmail to SMS extracted folder and run the "sms_service.bal" file and "gmail_service.bal" using two separate terminals (or command prompts). 
```$ ballerina run sms_service.bal``` 
```$ ballerina run gmail_service.bal``` 
5. Congratulations. The Gmail to SMS service is up and running. You can test by getting an email under your preferred label. You should receive a SMS notification on the mobile number provided as ```myphone```.

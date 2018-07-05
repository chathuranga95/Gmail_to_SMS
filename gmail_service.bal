import wso2/gmail;
import ballerina/http;
import ballerina/io;
import ballerina/config;
import ballerina/file;
import ballerina/runtime;
import ballerina/task;

//retrieve necessary variables from the config file

string accessTkn = config:getAsString("accessToken");
string clientID = config:getAsString("clientId");
string clientSecret = config:getAsString("clientSecret");
string refreshToken = config:getAsString("refreshToken");
string myemail = config:getAsString("MYEMAIL");
string filteringLabelID = config:getAsString("filteringLabelID");


//gmail end point
endpoint gmail:Client gmailEP {
    clientConfig:{
        auth:{
            accessToken:accessTkn,
            clientId:clientID,
            clientSecret:clientSecret,
            refreshToken:refreshToken
        }
    }
};


//SMS sending service endpoint
endpoint http:Client smsClient {
    url:"http://localhost:9091"
};


//function to get unread mails with wso2/gmail ballerina package
function getnewMails() returns string[]{

    //gmail filter to filter the messages
    gmail:MsgSearchFilter filter;
    filter.labelIds = [filteringLabelID,"UNREAD"];

    //listpage to save listpage results
    gmail:MessageListPage listPage;

    //get mail list from myemail (pre-provided)
    var details = gmailEP->listMessages(myemail,filter = filter);
    match details {
        gmail:MessageListPage msgList => listPage = msgList;
        gmail:GmailError err => io:println(err);

    }

    //get the count of messages
    int newMsgCount = lengthof listPage["messages"];

    //string array to contain the subjects of new messages
    string[] newMsgList = [];

    //iterate through the messages and append the subjects in newMsgList
    int i = 0;
    while(i<newMsgCount){
        gmail:Message msg;
        var msgdetails = gmailEP->readMessage(myemail,<string>listPage["messages"][i]["messageId"]);
        match msgdetails{
            gmail:Message msgtext=> msg = msgtext;
            gmail:GmailError err=>io:println(err);
        }
        if(lengthof msg["headerSubject"]>120){
            newMsgList[i] = "\n" + <string>msg["headerSubject"].substring(0, 120) + "...";
        }
        else{
            newMsgList[i] = "\n" + msg["headerSubject"];
        }
        i++;

    }

    //return the new message list
    return newMsgList;
}

//variable to contain current unread email count, initially set to 0.
int currentCount = 0;

//function to compare the new mail list count with the current unread mail count and
//get the sms service to send the respected sms to the user.
function listenForMails(){

    //latest update of new mails
    string[] newMailList = getnewMails();

    //text to be sent as a SMS
    string smsText = "";

    //compare the new unread mail count with current mail count and send SMS
    if(lengthof newMailList>currentCount){

        //set sms text with unread mail count and the latest email's subject
        smsText = "you have "+<string>(lengthof newMailList)+" unread mails, \n" + "recent Email's subject is "+ newMailList[0];

        //print sending sms text in the console
        io:println(smsText);

        //update the currentCount.
        currentCount = lengthof newMailList;


        //get the sms service to send the sms to the user
        http:Request req = new;
        req.setTextPayload(smsText); //passing parameters;message body

        //post the request and print the response on console
        var response = smsClient->post("/", req);
        match response {
            http:Response resp => {
                io:println(resp.getTextPayload());
            }
            error err => { io:println(err); }
        }

    }
    else if(lengthof newMailList<currentCount){
        //when the user reads a mail and mark as read.
        currentCount = lengthof newMailList;
    }

}

//timer object
task:Timer? timer;

//get the main function to call the mail listening periodically.
function main(string... args) {

    (function() returns error?) onTriggerFunction = listenForMails;
    function(error) onErrorFunction = listenError;
    timer = new task:Timer(onTriggerFunction, onErrorFunction, 10000, delay = 0);
    timer.start();
    runtime:sleep(20000000000); // Temp. workaround to stop the process from exiting.
}


//error msg printing on console
function listenError(error e) {
    io:println("Oops, it's an error...");
    io:println(e);
}
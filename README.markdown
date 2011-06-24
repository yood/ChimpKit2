# ChimpKit2

ChimpKit2 is a simple API wrapper for interacting with [MailChimp API](http://www.mailchimp.com/api) 1.3.

##Requirements

A MailChimp account and API key. You can see your API keys [here](http://admin.mailchimp.com/account/api).

ChimpKit2 includes [json-framework](https://github.com/stig/json-framework) as a submodule.

##Installation

Add ChimpKit2 as a submodule of your git repo by doing something like:

    cd myrepo
    git submodule add https://github.com/mailchimp/ChimpKit2.git Lib/ChimpKit

You'll then want to cd into ChimpKit and pull in its dependency (json-framework):

    cd Lib/ChimpKit
    git submodule init
    git submodule update

##Usage

ChimpKit2 requests are designed for one-time use. To make a request first create an instance of ChimpKit:

    ChimpKit *ck = [[[ChimpKit alloc] initWithDelegate:self 
                                             andApiKey:@"<YOUR_API_KEY>"] 
                                             autorelease];


You may have noticed that we passed "self" as the delegate above. You should implement the "ChimpKitDelegate"
protocol, which includes the following methods:

    - (void)ckRequestSucceeded:(ChimpKit *)ckRequest {
        NSLog(@"HTTP Status Code: %d", [ckRequest responseStatusCode]);
        NSLog(@"Response String: %@", [ckRequest responseString]);
    }

    - (void)ckRequestFailed:(NSError *)error {
        NSLog(@"Response Error: %@", error);
    }

Fetching data is as simple as calling API methods directly on the wrapper object. 
Check the API [documentation](http://www.mailchimp.com/api/1.3) for details.

###Canceling Requests

You can cancel an in-progress request by passing the "cancel" message:

    [ck cancel];


### Controlling Timeout

ChimpKit2 defaults to a 10 second timeout. You can change that (globally) to 30 seconds like so:

    [ChimpKit setTimeout:30];

### Fetching Lists

    [ck callApiMethod:@"lists" withParams:nil];

### Subscribing an Email

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"<YOUR_LIST_ID>" forKey:@"id"];
    [params setValue:@"someemail@example.com" forKey:@"email_address"];
    [params setValue:@"true" forKey:@"double_optin"];
    [params setValue:@"true" forKey:@"update_existing"];

    NSMutableDictionary *mergeVars = [NSMutableDictionary dictionary];
    [mergeVars setValue:@"First" forKey:@"FNAME"];
    [mergeVars setValue:@"Last" forKey:@"LNAME"];
    [params setValue:mergeVars forKey:@"merge_vars"];

    [ck callApiMethod:@"listSubscribe" withParams:params];

## Notes

As much as we love ASIHTTPRequest, ChimpKit2 no longer depends on it. ChimpKit2 does, however, still require json-framework.

##Copyrights

* Copyright (c) 2010-2011 The Rocket Science Group. Please see LICENSE.txt for details.
* MailChimp (c) 2001-2011 The Rocket Science Group.
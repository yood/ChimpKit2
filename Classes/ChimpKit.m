//
//  ChimpKit.m
//  ChimpKit2
//
//  Created by Amro Mousa on 11/19/10.
//  Copyright 2010 MailChimp. All rights reserved.
//

#import "ChimpKit.h"

@interface ChimpKit()
- (NSString *)encodeString:(NSString *)unencodedString;
@end


@implementation ChimpKit

@synthesize timeout, apiUrl, apiKey, request, delegate, onSuccess, onFailure;

#pragma mark -
#pragma mark Initialization

- (void)setApiKey:(NSString*)key {
    apiKey = key;
    if (apiKey) {
        //Parse out the datacenter and template it into the URL.
        NSArray *apiKeyParts = [apiKey componentsSeparatedByString:@"-"];
        if ([apiKeyParts count] > 1) {
            self.apiUrl = [NSString stringWithFormat:@"https://%@.api.mailchimp.com/1.3/?method=", [apiKeyParts objectAtIndex:1]];
        }
    }
}

- (id)initWithDelegate:(id)aDelegate andApiKey:(NSString *)key {
	self = [super init];
	if (self != nil) {
        self.apiUrl  = @"https://api.mailchimp.com/1.3/?method=";
        [self setApiKey:key];
        self.delegate = aDelegate;
        self.timeout = 30;
	}
	return self;
}

- (void)callApiMethod:(NSString *)method withParams:(NSDictionary *)params {
    [self callApiMethod:method withParams:params andUserInfo:nil];
}

- (void)callApiMethod:(NSString *)method withParams:(NSDictionary *)params andUserInfo:(NSDictionary *)userInfo {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.apiUrl, method];

    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.request setDelegate:self.delegate];
    [self.request setTimeOutSeconds:self.timeout];
    [self.request setUserInfo:userInfo];
    [self.request setDidFinishSelector:self.onSuccess];
    [self.request setDidFailSelector:self.onFailure];
    [self.request setRequestMethod:@"POST"];
    [self.request setShouldContinueWhenAppEntersBackground:YES];

    NSMutableDictionary *postBodyParams = [NSMutableDictionary dictionary];
    if (self.apiKey) {
        [postBodyParams setValue:self.apiKey forKey:@"apikey"];
    }

    if (params) {
        [postBodyParams setValuesForKeysWithDictionary:params];
    }

    NSString *encodedParamsAsJson = [self encodeString:[postBodyParams JSONRepresentation]];
    NSMutableData *postData = [NSMutableData dataWithData:[encodedParamsAsJson dataUsingEncoding:NSUTF8StringEncoding]];
    [self.request setPostBody:postData];
    [self.request startAsynchronous];
}

- (NSString *)encodeString:(NSString *)unencodedString {
    NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                                                  (CFStringRef)unencodedString, 
                                                                                  NULL, 
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                                  kCFStringEncodingUTF8);
    return [encodedString autorelease];
}

- (void)cancelRequest {
    if (self.request) {
        [self.request clearDelegatesAndCancel];
        [request release];
        self.request = nil;
    }
}

- (void)dealloc {
    self.apiKey = nil;
    self.apiUrl = nil;
    [super dealloc];
}

@end

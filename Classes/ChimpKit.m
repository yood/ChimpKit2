//
//  ChimpKit.m
//  ChimpKit2
//
//  Created by Amro Mousa on 11/19/10.
//  Copyright 2010 MailChimp. All rights reserved.
//

#import "ChimpKit.h"

static NSUInteger timeout = 10;
static NSOperationQueue *queue = nil;

@interface ChimpKit()
- (void)setDefaultRequestParams;
- (NSMutableData *)encodeRequestParams:(NSDictionary *)params;
- (NSString *)encodeString:(NSString *)unencodedString;
- (void)cancel;
@end


@implementation ChimpKit

@synthesize apiUrl, apiKey, request, delegate, userInfo;
@synthesize responseString = _responseString;
@synthesize responseStatusCode = _responseStatusCode;
@synthesize error = _error;

+ (void)setTimeout:(NSUInteger)tout {
    timeout = tout;
}

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
        
        if (!queue) {
            queue = [[NSOperationQueue alloc] init];
            [queue setMaxConcurrentOperationCount:3];
        }
	}
	return self;
}

#pragma mark Setup

- (NSMutableData *)encodeRequestParams:(NSDictionary *)params {
    NSMutableDictionary *postBodyParams = [NSMutableDictionary dictionary];
    if (self.apiKey) {
        [postBodyParams setValue:self.apiKey forKey:@"apikey"];
    }

    if (params) {
        [postBodyParams setValuesForKeysWithDictionary:params];
    }

    NSString *encodedParamsAsJson = [self encodeString:[postBodyParams JSONRepresentation]];
    NSMutableData *postData = [NSMutableData dataWithData:[encodedParamsAsJson dataUsingEncoding:NSUTF8StringEncoding]];
    return postData;
}

- (void)setDefaultRequestParams {
    [self.request setDelegate:self];
    [self.request setTimeOutSeconds:timeout];
    [self.request setRequestMethod:@"POST"];
    [self.request setShouldContinueWhenAppEntersBackground:YES];
}

- (void)callApiMethod:(NSString *)method withParams:(NSDictionary *)params {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.apiUrl, method];
    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self setDefaultRequestParams];
    
    NSMutableData *postData = [self encodeRequestParams:params];
    
    [self.request setPostBody:postData];
    [self.request setCompletionBlock:^{
        _responseString = [self.request.responseString retain];
        _responseStatusCode = self.request.responseStatusCode;
        
        if ([self.delegate respondsToSelector:@selector(ckRequestSucceeded:)]) {
            [self.delegate performSelector:@selector(ckRequestSucceeded:) withObject:self];
        }
    }];
    
    [self.request setFailedBlock:^{
        _error = [self.request.error retain];
        if ([self.delegate respondsToSelector:@selector(ckRequestFailed:)]) {
            [self.delegate performSelector:@selector(ckRequestFailed:) withObject:_error];
        }
    }];

    [queue addOperation:self];
}

- (NSString *)encodeString:(NSString *)unencodedString {
    NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                                                  (CFStringRef)unencodedString, 
                                                                                  NULL, 
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                                  kCFStringEncodingUTF8);
    return [encodedString autorelease];
}

#pragma mark Tear down

- (void)cancel {
    if (self.request) {
        [self.request clearDelegatesAndCancel];
    }
}

- (void)dealloc {
    if (_error) {
        [_error release];
    }
    
    if (_responseString) {
        [_responseString release];
    }
    
    [request release];
    self.request = nil;

    self.apiKey = nil;
    self.apiUrl = nil;
    [super dealloc];
}

#pragma mark NSOperationQueue

- (void)main {
    [self.request startAsynchronous];
}

@end

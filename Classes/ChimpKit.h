//
//  ChimpKit.h
//  ChimpKit2
//
//  Created by Amro Mousa on 11/19/10.
//  Copyright 2010 MailChimp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "JSON.h"

@class ChimpKit;

@protocol ChimpKitDelegate <NSObject>

@optional
- (void)ckRequestSucceeded:(ChimpKit *)ckRequest;

@optional
- (void)ckRequestFailed:(NSError *)error;

@end

@interface ChimpKit : NSOperation {
    id  delegate;
    SEL onSuccess;
    SEL onFailure;

    NSString *apiUrl;
    NSString *apiKey;

    ASIHTTPRequest *request;
    id userInfo;
}

@property (assign, readwrite) id delegate;
@property (nonatomic, retain) id userInfo;

@property (nonatomic, retain) NSString *apiUrl;
@property (nonatomic, retain) NSString *apiKey;

@property (nonatomic, retain) ASIHTTPRequest *request;

@property (nonatomic, readonly) NSString *responseString;
@property (nonatomic, readonly) NSUInteger responseStatusCode;
@property (nonatomic, readonly) NSError *error;

+ (void)setTimeout:(NSUInteger)tout;

-(id)initWithDelegate:(id)aDelegate andApiKey:(NSString *)key;
-(void)callApiMethod:(NSString *)method withParams:(NSDictionary *)params;

@end
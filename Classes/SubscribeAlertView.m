//
//  SubscriptionAlertView.m
//  ChimpKit2
//
//  Created by Amro Mousa on 4/6/11.
//  Copyright 2011 return7, LLC. All rights reserved.
//

#import "SubscribeAlertView.h"
#import "ChimpKit.h"

@interface SubscribeAlertView()
@property (nonatomic, retain) ChimpKit *chimpKit;
@property (nonatomic, retain) NSString *listId;
- (void)requestCompleted:(ASIHTTPRequest *)request;
@end

@implementation SubscribeAlertView

@synthesize textField, chimpKit, listId;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
            apiKey:(NSString *)apiKey
            listId:(NSString *)aListId
  cancelButtonTitle:(NSString *)cancelButtonTitle
  subscribeButtonTitle:(NSString *)subscribeButtonTitle {

	self = [super initWithTitle:title
                        message:message
                       delegate:nil
              cancelButtonTitle:cancelButtonTitle
              otherButtonTitles:subscribeButtonTitle, nil];
    if (self) {
        //Set the delegate to self so we can handle button presses
        self.delegate = self;

        UITextField *aTextField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
        aTextField.borderStyle = UITextBorderStyleRoundedRect;
        aTextField.placeholder = @"Email Address";
        aTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        aTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        aTextField.delegate = self;
        aTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.textField = aTextField;        
        [self addSubview:self.textField];
        
        self.listId = aListId;
        
        ChimpKit *cKit = [[[ChimpKit alloc] initWithDelegate:self andApiKey:apiKey] autorelease];
        cKit.onSuccess = @selector(requestCompleted:);
        cKit.onFailure = @selector(requestCompleted:);
        self.chimpKit = cKit;
        
        //ChimpKit expects self to be around (since it's the delegate!) 
        //so retain ourselves just in case
        [self retain];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
    
    CGRect lowestRect = CGRectZero;
    for (UIView *view in self.subviews) {
        //Find the lowest view's rect so we can position the textField later
        if ([view isKindOfClass:[UILabel class]] && (view.frame.origin.y >= lowestRect.origin.y)) {
            lowestRect = view.frame;
        }

        //Shift the buttons down (they're instances of a private class so we can't reference it by name)
        if (![view isKindOfClass:[UITextField class]] && ![view isKindOfClass:[UILabel class]] && ![view isKindOfClass:[UIImageView class]]) {
            view.frame = CGRectMake(CGRectGetMinX(view.frame),
                                    CGRectGetMinY(view.frame) + kSubscriptionAlertViewTextFieldHeight,
                                    CGRectGetWidth(view.frame),
                                    CGRectGetHeight(view.frame));
        }
    }
    
    //Position the text field based on the lowest view's rect, which we found earlier
    self.textField.frame = CGRectMake(CGRectGetMinX(lowestRect),
                                      CGRectGetMaxY(lowestRect) + kSubscriptionAlertViewTextFieldYPadding,
                                      CGRectGetWidth(lowestRect),
                                      kSubscriptionAlertViewTextFieldHeight);
    
    //Adjust the size of the entire view to account for the height of the text field
    self.frame = CGRectMake(CGRectGetMinX(self.frame), 
                            CGRectGetMinY(self.frame), 
                            CGRectGetWidth(self.frame), 
                            CGRectGetHeight(self.frame) + kSubscriptionAlertViewTextFieldHeight + kSubscriptionAlertViewTextFieldYPadding);
}

- (void) show {
	[super show];
	[self.textField becomeFirstResponder];
}

- (void)dealloc {    
    [textField release];
    [chimpKit release];
    [listId release];
    [super dealloc];
}

#pragma mark - ChimpKit Delegate Methods

- (void)requestCompleted:(ASIHTTPRequest *)request {
    NSString *response = [request responseString];
    if (![response isEqualToString:@"true"]
        && [response rangeOfString:@"214"].location == NSNotFound ) { // Ignore already subscribed error.
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Subscription Failed"
															message:@"Unable to subscribe your email address. Please check it and try again."
														   delegate:nil 
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[errorAlertView show];
		[errorAlertView release];
    }
    else
    {
        UIAlertView *successAlertView = [[UIAlertView alloc] initWithTitle:nil
															message:@"Thanks! We've successfully added you to our mailing list."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
        [successAlertView show];
        [successAlertView release];
    }

    //Release self since we retained self in init and self's work is now done.
    [self release];
}

#pragma mark - <UIAlertViewDelegate> Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // Subscribe pressed
         NSMutableDictionary *params = [NSMutableDictionary dictionary];
         [params setValue:self.listId forKey:@"id"];
         [params setValue:self.textField.text forKey:@"email_address"];
         [params setValue:@"false" forKey:@"double_optin"];
         [self.chimpKit callApiMethod:@"listSubscribe" withParams:params];
    }
}

#pragma mark - <UITextFieldDelegate> Methods

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
    [aTextField resignFirstResponder];
	return NO;
}

@end

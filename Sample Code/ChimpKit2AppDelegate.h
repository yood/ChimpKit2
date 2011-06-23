//
//  ChimpKit2AppDelegate.h
//  ChimpKit2
//
//  Created by Amro Mousa on 11/19/10.
//  Copyright 2010 MailChimp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChimpKit.h"

@class ChimpKit2ViewController;

@interface ChimpKit2AppDelegate : NSObject <UIApplicationDelegate, ChimpKitDelegate> {
    UIWindow *window;
    ChimpKit2ViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ChimpKit2ViewController *viewController;

@end


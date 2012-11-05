//
//  AppDelegate.h
//  Bomb Unit
//
//  Created by Erran Carey on 4/21/12.
//  Copyright (c) 2012 App2o. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class CongratsController;
@class HelpController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UIWindow *window;
    ViewController *viewController;
    CongratsController *congratsController;
    HelpController *helpController;
}

@property (strong, nonatomic) UIWindow *window;

@end
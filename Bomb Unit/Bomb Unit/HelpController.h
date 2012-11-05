//
//  HelpController.h
//  Bomb Unit
//
//  Created by Erran Carey on 4/25/12.
//  Copyright (c) 2012 App2O. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HighScoreManager.h"

@class HighScoreManager;
@class ViewController;
@interface HelpController : UIViewController<HighscoreManagerDelegate, UIAlertViewDelegate>{
    HighScoreManager *highscoreManager;
}


@property int upSwipes;
@property int downSwipes;
@property int leftSwipes;
@property int rightSwipes;
@property int konamiInt;
@property BOOL bBool;
@property BOOL aBool;

@property (strong, nonatomic) IBOutlet UIImageView *gamepad;
@property (strong, nonatomic) IBOutlet UIButton *b;
@property (strong, nonatomic) IBOutlet UIButton *a;

- (void)addRecognizers;
- (void)upSwiped:(UIGestureRecognizer *)recognizer;
- (void)downSwiped:(UIGestureRecognizer *)recognizer;
- (void)leftSwiped:(UIGestureRecognizer *)recognizer;
- (void)rightSwiped:(UIGestureRecognizer *)recognizer;
- (IBAction)bPressed;
- (IBAction)aPressed;
- (void)toggleGamepad;
- (void)konami;

@end
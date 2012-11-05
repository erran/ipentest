//
//  CongratsController.h
//  Bomb Unit
//
//  Created by Erran Carey on 4/25/12.
//  Copyright (c) 2012 App2O. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class ViewController;
@interface CongratsController : UIViewController<AVAudioPlayerDelegate>{
    AVAudioPlayer *song;
}

-(IBAction)switchView:(id)sender;
-(void)songPlay;
@end
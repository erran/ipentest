//
//  ViewController.m
//  Bomb Unit
//
//  Created by Erran Carey on 4/21/12.
//  Copyright (c) 2012 App2O. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "AppSpecificValues.h"
#import "HighScoreManager.h"
#import "CongratsController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize startButton;
@synthesize robotButton;
@synthesize detonated;
@synthesize blastZone;
@synthesize level;
@synthesize difficultLv;
@synthesize tries;
@synthesize allowedTries;
@synthesize timebonus;
@synthesize triesLbl;
@synthesize timeRemaining;
@synthesize where;
@synthesize score;
@synthesize scoreInt;
@synthesize currentScore;
@synthesize currentLeaderBoard;
@synthesize highscoreManager;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad{
	[super viewDidLoad];
	
	self.currentLeaderBoard = kLeaderboardID;
	self.currentScore = 0;
	
	if ([HighScoreManager isGameCenterAvailable]) {
		
		self.highscoreManager = [[[HighScoreManager alloc] init] autorelease];
		[self.highscoreManager setDelegate:self];
		[self.highscoreManager authenticateLocalUser];
		
		
	}
	self.detonated = 0;
	scoreInt = 0;
	score.text = [NSString stringWithFormat:@"Score: %i",scoreInt];
	if(difficultLv){
		[self resetGame];
		[self alertContinue];
		for (int i=1001; i < 1026; ++i) {
			UIButton *b = (UIButton *)[self.view viewWithTag:i];
			[b addTarget:self action:@selector(guess:) forControlEvents:UIControlEventTouchUpInside];
		}
	}
	else {
		level.text = [NSString stringWithFormat:@"Level %i",difficultLv];
		difficultLv = 1;
		tries = 14 - difficultLv;
		allowedTries = tries;
		[self resetGame];
		[self alertStart];
		for (int i=1001; i < 1026; ++i) {
			UIButton *b = (UIButton *)[self.view viewWithTag:i];
			[b addTarget:self action:@selector(guess:) forControlEvents:UIControlEventTouchUpInside];
		}
	}
	
	NSError *error = nil;
	NSURL *noiseURL;
	
	noiseURL = [[NSBundle mainBundle] URLForResource:@"applause" withExtension:@"mp3"];
	bomb = [[AVAudioPlayer alloc] initWithContentsOfURL:noiseURL error:&error];
	
	noiseURL = [[NSBundle mainBundle] URLForResource:@"altapplause" withExtension:@"mp3"];
	bombDiffused = [[AVAudioPlayer alloc] initWithContentsOfURL:noiseURL error:&error];
	
	noiseURL = [[NSBundle mainBundle] URLForResource:@"alarm" withExtension:@"mp3"];
	caution = [[AVAudioPlayer alloc] initWithContentsOfURL:noiseURL error:&error];
	
	noiseURL = [[NSBundle mainBundle] URLForResource:@"cheer" withExtension:@"mp3"];
	phew = [[AVAudioPlayer alloc] initWithContentsOfURL:noiseURL error:&error];
	
	[bomb setDelegate:self];
	[bomb setVolume:1.0];
	[bomb prepareToPlay];
	[bombDiffused setDelegate:self];
	[bombDiffused setVolume:1.0];
	[bombDiffused prepareToPlay];
	[caution setDelegate:self];
	[caution setVolume:1.0];
	[caution prepareToPlay];
	[phew setDelegate:self];
	[phew setVolume:1.0];
	[phew prepareToPlay];
	
	[self becomeFirstResponder];
	
	//[self startGame:nil];
}

- (void) viewDidUnload {
	[blastZone release];
	[bomb release];
	[bombDiffused release];
	[caution release];
	[phew release];
	[super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self becomeFirstResponder];
}

- (void)resetGame {
	[self swapcolor];
	startButton.hidden = NO;
	CABasicAnimation *trans = [CABasicAnimation animation];
	trans.keyPath = @"transform.scale";
	trans.repeatCount = HUGE_VALF;
	trans.duration = 0.5;
	trans.autoreverses = YES;
	trans.removedOnCompletion = NO;
	trans.fillMode = kCAFillModeForwards;
	trans.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	trans.fromValue = [NSNumber numberWithFloat:0.9];
	trans.toValue = [NSNumber numberWithFloat:1.1];
	[self.startButton.titleLabel.layer addAnimation:trans forKey:@"pulse"];
	for (int i=1001; i < 1026; ++i)
		[(UIButton *)[self.view viewWithTag:i] setEnabled:YES];
	elapsed_seconds = 0;
}

- (IBAction)startGame:(id)sender {
	startButton.hidden = YES;
	robotButton.hidden = NO;
	for (int i=1001; i < 1026; ++i) {
		UIButton *b = (UIButton *)[self.view viewWithTag:i];
		[b setImage:[UIImage imageNamed:@"box"] forState:UIControlStateNormal];
		//[b setTitle:@"?" forState:UIControlStateNormal];
		b.enabled = YES;
	}
	[self.startButton.titleLabel.layer removeAllAnimations];
	hiddenLocation = arc4random()%25;
	//NSLog(@"Hidden Location: %i",hiddenLocation+1);
	elapsed_seconds = 0;
	[timeRemaining setText:@"00:00:00"];
	if (clock) {
		[clock invalidate];
	}
	clock = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

- (BOOL)canBecomeFirstResponder { 
	return YES;
}

- (void)guess:(id)sender {
	UIButton *guessed = (UIButton *)sender;
	guessed.enabled = YES;
	switch (hiddenLocation) {
		case 0:
			blastZone = [[NSArray alloc] initWithObjects:@"1",@"5",@"6",nil];
			break;
		case 1:
			blastZone = [[NSArray alloc] initWithObjects:@"0",@"2",@"5",@"6",@"7",nil];
			break;
		case 2:
			blastZone = [[NSArray alloc] initWithObjects:@"1",@"3",@"6",@"7",@"8",nil];
			break;
		case 3:
			blastZone = [[NSArray alloc] initWithObjects:@"2",@"4",@"7",@"8",@"9",nil];
			break;
		case 4:
			blastZone = [[NSArray alloc] initWithObjects:@"3",@"8",@"9",nil];
			break;
		case 5:
			blastZone = [[NSArray alloc] initWithObjects:@"0",@"1",@"6",@"10",@"11",nil];
			break;
		case 6:
			blastZone = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"5",@"7",@"10",@"11",@"12",nil];
			break;
		case 7:
			blastZone = [[NSArray alloc] initWithObjects:@"1",@"2",@"3",@"6",@"8",@"11",@"12",@"13",nil];
			break;
		case 8:
			blastZone = [[NSArray alloc] initWithObjects:@"2",@"3",@"4",@"7",@"9",@"12",@"13",@"14",nil];
			break;
		case 9:
			blastZone = [[NSArray alloc] initWithObjects:@"3",@"4",@"8",@"13",@"14",nil];
			break;
		case 10:
			blastZone = [[NSArray alloc] initWithObjects:@"5",@"6",@"11",@"15",@"16",nil];
			break;
		case 11:
			blastZone = [[NSArray alloc] initWithObjects:@"5",@"6",@"7",@"10",@"12",@"15",@"16",@"17",nil];
			break;
		case 12:
			blastZone = [[NSArray alloc] initWithObjects:@"6",@"7",@"8",@"11",@"13",@"16",@"17",@"18",nil];
			break;
		case 13:
			blastZone = [[NSArray alloc] initWithObjects:@"7",@"8",@"9",@"12",@"14",@"17",@"18",@"19",nil];
			break;
		case 14:
			blastZone = [[NSArray alloc] initWithObjects:@"8",@"9",@"13",@"18",@"19",nil];
			break;
		case 15:
			blastZone = [[NSArray alloc] initWithObjects:@"10",@"11",@"16",@"20",@"21",nil];
			break;
		case 16:
			blastZone = [[NSArray alloc] initWithObjects:@"10",@"11",@"12",@"15",@"17",@"20",@"21",@"22",nil];
			break;
		case 17:
			blastZone = [[NSArray alloc] initWithObjects:@"11",@"12",@"13",@"16",@"18",@"21",@"22",@"23",nil];
			break;
		case 18:
			blastZone = [[NSArray alloc] initWithObjects:@"12",@"13",@"14",@"17",@"19",@"22",@"23",@"24",nil];
			break;
		case 19:
			blastZone = [[NSArray alloc] initWithObjects:@"13",@"14",@"18",@"23",@"24",nil];
			break;
		case 20:
			blastZone = [[NSArray alloc] initWithObjects:@"15",@"16",@"21",nil];
			break;
		case 21:
			blastZone = [[NSArray alloc] initWithObjects:@"15",@"16",@"17",@"20",@"22",nil];
			break;
		case 22:
			blastZone = [[NSArray alloc] initWithObjects:@"16",@"17",@"18",@"21",@"23",nil];
			break;
		case 23:
			blastZone = [[NSArray alloc] initWithObjects:@"17",@"18",@"19",@"22",@"24",nil];
			break;	   
		case 24:
			blastZone = [[NSArray alloc] initWithObjects:@"18",@"19",@"23",nil];
			break;
		default:
			break;
	}
	[CATransaction begin];
	self.detonated = 0;
	if (guessed.tag - 1001 == hiddenLocation) {
		[guessed setImage:[UIImage imageNamed:@"black_bomb"] forState:UIControlStateNormal];
		[clock invalidate]; 
		clock = nil;
		robotButton.hidden = YES;
		startButton.hidden = NO;
		self.detonated = 1;
		[bomb play];
		[self levelPassed];
		[self checkSelection];
	}
	else if(blastZone.count > 0 && [[blastZone objectAtIndex:0] intValue] == (guessed.tag - 1001)) {
		if (tries > 1){
			[guessed setImage:[UIImage imageNamed:@"hazard"] forState:UIControlStateNormal];
			[caution stop];
			[caution prepareToPlay];
			[caution play];
			tries--;
			triesLbl.text = [NSString stringWithFormat:@"x%i",tries];

		}
		else{
			[self checkSelection];
		}
	}
	else if(blastZone.count > 1 && [[blastZone objectAtIndex:1] intValue] == (guessed.tag - 1001)) {
		if (tries > 1){
			[guessed setImage:[UIImage imageNamed:@"hazard"] forState:UIControlStateNormal];
			[caution stop];
			[caution prepareToPlay];
			[caution play];
			tries--;
			triesLbl.text = [NSString stringWithFormat:@"x%i",tries];

		}
		else{
			[self checkSelection];
		}
	}
	else if(blastZone.count > 2 && [[blastZone objectAtIndex:2] intValue] == (guessed.tag - 1001)) {
		if (tries > 1){
			[guessed setImage:[UIImage imageNamed:@"hazard"] forState:UIControlStateNormal];
			[caution stop];
			[caution prepareToPlay];
			[caution play];
			tries--;
			triesLbl.text = [NSString stringWithFormat:@"x%i",tries];

		}
		else{
			[self checkSelection];
		}
	}
	else if(blastZone.count > 3 && [[blastZone objectAtIndex:3] intValue] == (guessed.tag - 1001) ) {
		if (tries > 1){
			[guessed setImage:[UIImage imageNamed:@"hazard"] forState:UIControlStateNormal];
			[caution stop];
			[caution prepareToPlay];
			[caution play];
			tries--;
			triesLbl.text = [NSString stringWithFormat:@"x%i",tries];

		}
		else{
			[self checkSelection];
		}
	}
	else if (blastZone.count > 4 && [[blastZone objectAtIndex:4] intValue] == (guessed.tag - 1001)) {
		if (tries > 1){
			[guessed setImage:[UIImage imageNamed:@"hazard"] forState:UIControlStateNormal];
			[caution stop];
			[caution prepareToPlay];
			[caution play];
			tries--;
			triesLbl.text = [NSString stringWithFormat:@"x%i",tries];

		}
		else{
			[self checkSelection];
		}
	}
	else if (blastZone.count > 5 && [[blastZone objectAtIndex:5] intValue] == (guessed.tag - 1001)) {
		if (tries > 1){
			[guessed setImage:[UIImage imageNamed:@"hazard"] forState:UIControlStateNormal];
			[caution stop];
			[caution prepareToPlay];
			[caution play];
			tries--;
			triesLbl.text = [NSString stringWithFormat:@"x%i",tries];

		}
		else{
			[self checkSelection];
		}
	}
	else if(blastZone.count > 6 && [[blastZone objectAtIndex:6] intValue] == (guessed.tag - 1001)) {
		if (tries > 1){
			[guessed setImage:[UIImage imageNamed:@"hazard"] forState:UIControlStateNormal];
			[caution stop];
			[phew stop];
			[caution prepareToPlay];
			[caution play];   
			tries--;
			triesLbl.text = [NSString stringWithFormat:@"x%i",tries];

		}
		else{
			[self checkSelection];
		}
	}
	else if(blastZone.count > 7 && [[blastZone objectAtIndex:7] intValue] == (guessed.tag - 1001)) {
		if (tries > 1){
			[guessed setImage:[UIImage imageNamed:@"hazard"] forState:UIControlStateNormal];
			[caution stop];
			[phew stop];
			[caution prepareToPlay];
			[caution play];   
			tries--;
			triesLbl.text = [NSString stringWithFormat:@"x%i",tries];

		}
		else{
			[self checkSelection];
		}
	}
	else if (tries > 1){
		[guessed setImage:[UIImage imageNamed:@"robot"] forState:UIControlStateNormal];
		[guessed setEnabled:YES];
		[phew stop];
		[phew prepareToPlay];
		[phew play];
		tries--;
		triesLbl.text = [NSString stringWithFormat:@"x%i",tries];
	}
	else{
		[self checkSelection];
	}
   [CATransaction commit];
	[self swapcolor];
}

- (void)tick:(NSTimer *)timer {
	elapsed_seconds++;
	[timeRemaining setText:[NSString stringWithFormat:@"%02d:%02d:%02d",
							elapsed_seconds / 3600, (elapsed_seconds % 3600) / 60, elapsed_seconds % 60]];
}

- (void)alertCongrats{
	CongratsController *congratsController = [self.storyboard instantiateViewControllerWithIdentifier:@"congrats"];
	[self presentModalViewController:congratsController animated:YES];
	[self submitScore];
	[self gameover];
}

- (void)alertContinue{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:[NSString stringWithFormat:@"Level %i", difficultLv] 
						  message:[NSString stringWithFormat:@"Detonation Attempts: %i", tries] 
						  delegate:self 
						  cancelButtonTitle:@"Continue" 
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	[self submitScore];
}

- (void)alertGameOver{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"GAME OVER" 
						  message:[NSString stringWithFormat:@"Level %i\nScore: %i",difficultLv,scoreInt] 
						  delegate:self 
						  cancelButtonTitle:@"New Game" 
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	[self gameover];
}

- (void)alertStart{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:[NSString stringWithFormat:@"Level %i", difficultLv] 
						  message:[NSString stringWithFormat:@"Detonation Attempts: %i", tries] 
						  delegate:self 
						  cancelButtonTitle:@"Start" 
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)checkSelection{
	if(self.detonated == 1){
		if(difficultLv < 14){
			[self alertContinue];
		}
		else {
			[self alertCongrats];
		}
	}
	else if(tries == 1){
		[self alertGameOver];
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 0){
		[self resetGame];
		[self startGame:nil];
		triesLbl.text = [NSString stringWithFormat:@"x%i",tries];
		score.text = [NSString stringWithFormat:@"Score: %i",scoreInt];
		level.text = [NSString stringWithFormat:@"Level %i",difficultLv];
	}
}
- (void)levelPassed{
	timebonus = (60-elapsed_seconds)*5;
	if (elapsed_seconds < 60){
		self.scoreInt = (scoreInt + ((tries)*(10)*(difficultLv)-10)+timebonus);
	}
	else{
		self.scoreInt = (scoreInt + ((tries)*(10)*(difficultLv)-10));
	}
	self.currentScore = self.scoreInt;
	[self checkAchievements];
	difficultLv++;
	tries = 14 - difficultLv;
	allowedTries = tries;
}

- (void)swapcolor{
	if (tries==0) {
		where.image = [UIImage imageNamed:@"bg_red"];
	}
	else if(tries==1){
		where.image = [UIImage imageNamed:@"bg_red"];
	}
	else if(tries==2){
		where.image = [UIImage imageNamed:@"bg_yellow"];
	}
	else if(tries==3){
		where.image = [UIImage imageNamed:@"bg_green"];
	}
	else {
		where.image = [UIImage imageNamed:@"bg"];
	}
}
-(void)gameover{
	scoreInt = 0;
	difficultLv = 1;
	tries = 14 - difficultLv;
	allowedTries = tries;
	[self resetGame];
	for (int i=1001; i < 1026; ++i) {
		UIButton *b = (UIButton *)[self.view viewWithTag:i];
		[b addTarget:self action:@selector(guess:) forControlEvents:UIControlEventTouchUpInside];
	}
}

-(void)konamiSkip{
	self.scoreInt = 0;
	self.currentScore = self.scoreInt;
	self.difficultLv = 12;
	self.tries = 14 - difficultLv;
}

- (IBAction) showLeaderboard{
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL){
		leaderboardController.category = self.currentLeaderBoard;
		leaderboardController.timeScope = GKLeaderboardTimeScopeWeek;
		leaderboardController.leaderboardDelegate = self;
		[self presentModalViewController:leaderboardController animated: YES];
	}

}
- (IBAction) showAchievements{
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != NULL)
	{
		achievements.achievementDelegate = self;
		[self presentModalViewController: achievements animated: YES];
	}
}
- (void) submitScore{
	self.currentScore = self.scoreInt;
	if(self.currentScore > 0){
		[self.highscoreManager reportScore:self.currentScore forCategory:self.currentLeaderBoard];
	}
}

- (void) checkAchievements{
	NSString* identifier = NULL;
	double percentComplete = 0;
	self.currentScore = self.difficultLv; 
	switch(self.difficultLv){
		case 1:{identifier= kAchievementID1; percentComplete= 100.0; break;}
		case 2:{identifier= kAchievementID2; percentComplete= 100.0; break;}
		case 3:{identifier= kAchievementID3; percentComplete= 100.0; break;}
		case 4:{identifier= kAchievementID4; percentComplete= 100.0; break;}
		case 5:{identifier= kAchievementID5; percentComplete= 100.0; break;}
		case 6:{identifier= kAchievementID6; percentComplete= 100.0; break;}
		case 7:{identifier= kAchievementID7; percentComplete= 100.0; break;}
		case 8:{identifier= kAchievementID8; percentComplete= 100.0; break;}
		case 9:{identifier= kAchievementID9; percentComplete= 100.0; break;}
		case 10:{identifier= kAchievementID10; percentComplete= 100.0; break;}
		case 11:{identifier= kAchievementID11; percentComplete= 100.0; break;}
		case 12:{identifier= kAchievementID12; percentComplete= 100.0; break;}
		case 13:{identifier= kAchievementID13; percentComplete= 100.0; break;}
	}
	if(identifier!= NULL)
	{
		[self.highscoreManager submitAchievement: identifier percentComplete: percentComplete];
	}
}
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
	[self dismissModalViewControllerAnimated: YES];
	[viewController release];
}
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController{
	[self dismissModalViewControllerAnimated: YES];
	[viewController release];
}
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.s
}
- (void)dealloc {
	[super dealloc];
}

@end
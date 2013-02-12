//
//  AppDelegate.m
//  TUIOTouchSynthesizer
//
//  Created by Simon Heys on 09/02/2013.
//  Copyright (c) 2013 Simon Heys Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "TuioTouchSynthesizer.h"

@interface AppDelegate ()
@property (nonatomic, retain) TuioTouchSynthesizer *touchSynthesizer;
@end

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_touchSynthesizer release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = [[ViewController new] autorelease];
    [self.window makeKeyAndVisible];
    
    // map touches to entire window
    self.touchSynthesizer = [[[TuioTouchSynthesizer alloc] initWithView:self.window.rootViewController.view port:3333] autorelease];
    self.touchSynthesizer.showTouches = YES;
    [self.touchSynthesizer startSynthesizing];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.touchSynthesizer stopSynthesizing];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.touchSynthesizer stopSynthesizing];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.touchSynthesizer startSynthesizing];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end

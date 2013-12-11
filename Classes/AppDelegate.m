//
//  AppDelegate.m
//  sansibar
//
//  Created by Heiko Bublitz on 07.07.10.
//  Copyright: com.bauermedia 2010. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
	CGRect screen = [[UIScreen mainScreen]bounds];
	window = [[UIWindow alloc] initWithFrame:screen];
	
	rootController = [RootVC new];
	 
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	 
	[[NSNotificationCenter defaultCenter] 
		addObserver:rootController 
		selector:@selector(orientationChanged:) 
		name:UIDeviceOrientationDidChangeNotification object:nil];
	
	[rootController.view setFrame:screen];
 	[window addSubview:rootController.view];
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[rootController applicationWillTerminate:application];
}

- (void)dealloc {
	[rootController release];
    [window release];
    [super dealloc];
}


@end

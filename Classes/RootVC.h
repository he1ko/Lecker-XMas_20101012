//
//  RootVC.h
//  sansibar
//
//  Created by Heiko Bublitz on 07.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageView.h"
#import "NaviView.h"
#import "FadeView.h"
#import "Toolbar.h"
#import "InfoView.h"


@interface RootVC : UIViewController <PageViewNotifications, NaviNotifications, ToolbarClickProtocol, InfoViewNotifications> {

	PageView *pageView;
	NaviView *naviView;
	FadeView *splashScreen;
	Toolbar *toolbar;
	InfoView *infoView;
	
	bool orientationIsLandscape;
	bool orientationInitialized;
	bool splashScreenHidden;
	
	bool naviLoaded;
	bool naviVisible;
	
	CGRect currentScreen;
	CGFloat pageZoomFactor;
	CGFloat pageWidth;
	
	int numberOfLoadingPage;
}


- (void) orientationChanged:(NSNotification*)notification;
- (void) setOrientation:(UIInterfaceOrientation) orientation;
- (void) showNavi:(bool)show;
- (void) showToolbar:(bool)show;
- (void) showInfoView:(bool)show;
- (void) hideSplashScreen;
- (void) resizePageImage:(CGRect)targetRect;
- (void) resizePageView:(CGRect)targetRect;
- (void) zoomToScreenWidthWithTouchPoint:(CGPoint)touchPoint;
- (void) zoomToSize:(CGSize)newSize withTouchPoint:(CGPoint)touchPoint;

+ (CGRect) translateFrame:(CGRect)frame byVector:(CGPoint)vector;
+ (CGRect) centerFrame:(CGRect)f1 inFrame:(CGRect)f2;
+ (bool) frameOrientationIsLandscape:(CGRect)frame;
+ (CGRect) getCurrentScreen:(bool)inLandscapeMode;

- (int) getLastPagenumberFromPropertyFile;
- (void) writeLastPagenumberToPropertyFile;

- (void) applicationWillTerminate:(UIApplication *)application;

@end

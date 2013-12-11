//
//  RootVC.m
//  sansibar
//
//  Created by Heiko Bublitz on 07.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import "RootVC.h"


@implementation RootVC



#pragma mark DEFAULT VIEW CONTROLLER INTERCEPTORS

/**
 *	initialization of views after construction of controllers view
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//// create SplashScreen
	splashScreen = [[FadeView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
	[self.view addSubview:splashScreen];
	
	//// create page container - HIDDEN until loading is done
	pageView = [[PageView alloc] initWithFrame:[self.view frame]];
	[pageView setHidden:YES];
	[pageView setPageViewDelegate:self];
	[pageView setBackgroundColor:MAIN_BGCOLOR];
	
	
	//// create navi panel - HIDDEN until loading is done
	naviView = [[NaviView alloc] initWithFrame:CGRectMake(-463, 67, 493, 2000)];
	[naviView setBackgroundColor:[UIColor clearColor]];
	[naviView setHidden:YES];
	[naviView setNaviDelegate:self];
	
	
	//// create panel with misc. buttons (info / help)
	toolbar = [[Toolbar alloc]initWithFrame:CGRectMake(0, 0, 463, 60)];
	[toolbar setToolbarDelegate:self];	
	[toolbar setToolbarTouchDelegate:naviView];
	
	infoView = [[InfoView alloc]initWithFrame:CGRectMake(0, 0, 1100, 1100)];
	[infoView setInfoViewDelegate:self];
	[infoView setAlpha:0.0];
	[infoView setCenter:[self.view center]];
	if ([infoView shouldShowUpOnStartup] || ![infoView startUpFlagAlreadyPresent]) {
		[self showInfoView:YES];
	}
	
	[self.view addSubview:pageView];
	[self.view addSubview:naviView];
	[self.view addSubview:toolbar];
	[self.view addSubview:infoView];
	[self.view bringSubviewToFront:splashScreen];
	
	[pageView release];
	[naviView release];
	[toolbar release];
	[infoView release];
	[splashScreen release];
	
	[NSTimer scheduledTimerWithTimeInterval:0.3 target:naviView selector:@selector(initItems) userInfo:nil repeats:NO];
	// [naviView initItems];
}



#pragma mark -
#pragma mark ROTATION HANDLING

/**
 *	Allow automatic rotation of controller view
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


/**
 *	general wrapper for rotation notifications
 */
- (void)orientationChanged:(NSNotification*)notification {
	if (UIDeviceOrientationIsValidInterfaceOrientation([[notification object] orientation])) {
		[self setOrientation:[[notification object] orientation]];
	}
	else if (!orientationInitialized) {
		[self setOrientation:[[notification object] orientation]];
		orientationInitialized = YES;
	}
}


/**
 *	implemention of actions in case of rotation
 */
- (void) setOrientation:(UIInterfaceOrientation) orientation {
	if (orientationInitialized && orientationIsLandscape == (UIDeviceOrientationIsLandscape(orientation))) {
		return;
	}
	
	orientationIsLandscape = (UIDeviceOrientationIsLandscape(orientation));	
	currentScreen = [RootVC getCurrentScreen:orientationIsLandscape];
	
	[self.view setFrame:currentScreen];
	
	// NSLog(@"Root-View set to %@", NSStringFromCGRect(currentScreen));
	
	if (splashScreen && !splashScreenHidden) {
		[splashScreen setCenter:self.view.center];
		[splashScreen setFrame: [RootVC translateFrame:[splashScreen frame] byVector:CGPointMake(0, -20)] ];
	}
	
	[infoView setCenter:[self.view center]];
	[self showToolbar:YES];

	CGRect viewport;
	
	if (orientationIsLandscape) {
		[self showNavi:YES];
		viewport = CGRectMake(463, 0, 561, 748);		
	}
	else {
		[self showNavi:NO];
		viewport = CGRectMake(0, 0, 768, 1004);
	}
	
	[self resizePageView:viewport];
	[pageView setCurrentScreen:viewport];
	
	orientationInitialized = YES;
}


#pragma mark -
#pragma mark ANIMATING VIEWS

/**
 *	Fade out the splashScreen
 */
- (void) hideSplashScreen {
	
	CGFloat yOffset = ([splashScreen frame].size.height + 100) * -1;
	CGRect finalFrame = [RootVC translateFrame:[splashScreen frame] byVector:CGPointMake(0, yOffset)];
	
	[UIView beginAnimations:ANI_SPLASH_HIDE context:NULL];
	[UIView setAnimationDuration:0.6];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[splashScreen setFrame:finalFrame];
	[splashScreen setAlpha:0.7];
	[UIView commitAnimations];
}

/**
 *	animate size and position of main Page
 *  ZOOM-OUT in LANDSCAPE
 */
- (void) resizePageView:(CGRect)targetRect {
	
	NSString *animationIdentifier;
	
	if (targetRect.size.width > [pageView frame].size.width) {
		animationIdentifier = ANI_PAGE_ZOOM_IN;
	}
	else {
		animationIdentifier = ANI_PAGE_ZOOM_OUT;
	}

	[UIView beginAnimations:animationIdentifier context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[pageView resizePageAndImageToRect:targetRect];
	[UIView commitAnimations];
}





/**
 *	animate size and position of main Page
 *  ZOOM_OUT in PORTRAIT
 */
- (void) resizePageImage:(CGRect)targetRect {
	
	NSString *animationIdentifier;
	
	if (targetRect.size.width > [pageView frame].size.width) {
		animationIdentifier = ANI_PAGE_ZOOM_IN;
	}
	else {
		animationIdentifier = ANI_PAGE_ZOOM_OUT;
	}
	[UIView beginAnimations:animationIdentifier context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[pageView resizeImageToRect:targetRect];
	[UIView commitAnimations];
}


//// ZOOM-IN in LANDSCAPE
- (void) zoomToScreenWidthWithTouchPoint:(CGPoint)touchPoint {
	[UIView beginAnimations:ANI_PAGE_ZOOM_IN context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[pageView zoomToPageWidthWithTouchPoint:touchPoint];
	[UIView commitAnimations];
}

//// ZOOM-IN in PORTRAIT
- (void) zoomToSize:(CGSize)newSize withTouchPoint:(CGPoint)touchPoint {
	[UIView beginAnimations:ANI_PAGE_ZOOM_IN context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[pageView zoomImageToSize:newSize withTouchPoint:touchPoint];
	[UIView commitAnimations];
}



- (void) showToolbar:(bool)show {
	CGFloat offsetY = currentScreen.size.height - [toolbar frame].size.height;
	CGFloat offsetX = [toolbar getXPosForState:show];
	[toolbar setFrame:CGRectMake(offsetX, offsetY, [toolbar frame].size.width, [toolbar frame].size.height)];
}


/**
 *	slide navigation panel in or out
 */
- (void) showNavi:(bool)show {
	
	CGRect targetFrame;
	CGFloat targetXPos;
	NSString *animationIdentifier;
	int height;
	
	[pageView setSuppressOverlayTouches:NO];
		
	if (orientationIsLandscape) {
		height = 625;
		[naviView showShadow:NO];
	}
	else {
		height = 881;
		[naviView showShadow:YES];
		[pageView setSuppressOverlayTouches:show];		
	}
	
	if (show) {
		targetXPos = 0;
		animationIdentifier = ANI_NAVI_SHOW;
	}
	else {
		targetXPos = 0 - [naviView frame].size.width;
		animationIdentifier = ANI_NAVI_HIDE;
	}
	
	targetFrame = CGRectMake(targetXPos, 0, [naviView frame].size.width, [naviView frame].size.height);
	
	[UIView beginAnimations:animationIdentifier context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	[naviView setFrame:targetFrame];
	[naviView setScrollHeight:height];
	[self showToolbar:show];
	
	[UIView commitAnimations];
}


#pragma mark -
#pragma mark POST ANIMATION PROCESSING

/**
 *	central animationDidStop-handler
 *	animations can be distinguished by their previously set identifiers 
 *	--> ANI_ constants defined in defines.h
 */
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	
	if ([animationID  isEqual: ANI_PAGE_PAN_ANIMATED]) {
		
	}
	else if ([animationID  isEqual: ANI_PAGE_ZOOM_IN]) {
		pageWidth = [pageView frame].size.width;
	}
	else if ([animationID  isEqual: ANI_PAGE_ZOOM_OUT]) {
		pageWidth = [pageView frame].size.width;
	}
	else if ([animationID  isEqual: ANI_ROTATE]) {
		
	}
	else if ([animationID  isEqual: ANI_NAVI_SHOW]) {
		naviVisible = YES;
		[toolbar setVisible:YES];
		[toolbar updateButtonStates];
	}
	else if ([animationID  isEqual: ANI_NAVI_HIDE]) {
		naviVisible = NO;
		[toolbar setVisible:NO];
		[toolbar updateButtonStates];
	}
	else if ([animationID  isEqual: ANI_SPLASH_HIDE]) {
		splashScreenHidden = YES;
		[splashScreen removeFromSuperview];
	}
	
	//// ALWAYS: 
	[pageView imageAnimationDone];
	//[infoView setFrame:[RootVC centerFrame:[infoView frame] inFrame:currentScreen]];
}


#pragma mark -
#pragma mark PAGE VIEW NOTIFICATIONS


/**
 *	called by PageView instances, when double-tapped
 */
- (void) pageDoubleTapped:(CGPoint)tapPoint {
	
	if (orientationIsLandscape && naviVisible) {
		// Landscape: ZOOM IN fullPage --> pageWidth
		[pageView setCurrentScreen:CGRectMake(0, 0, 1024, 748)];
		[self zoomToScreenWidthWithTouchPoint:tapPoint];
		[self showNavi:NO];
	}
	else if (orientationIsLandscape && !naviVisible && pageWidth == 1024) {
		// Landscape: ZOOM OUT pageWidth --> fullPage
		[self resizePageView:CGRectMake(463, 0, 561, 748)];
		[pageView setCurrentScreen:CGRectMake(463, 0, 561, 748)];
		[self showNavi:YES];
	}
	else if (!orientationIsLandscape && [pageView getImageWidth] <= [self.view frame].size.width) {
		// Portrait ZOOM IN fullPage --> oversize zoom
		[pageView setCurrentScreen:CGRectMake(0, 0, 768, 1004)];
		[self zoomToSize:CGSizeMake(1152, 1536) withTouchPoint:tapPoint];
	}
	else if (!orientationIsLandscape && [pageView getImageWidth] > [self.view frame].size.width) {
		// Portrait ZOOM OUT oversize zoom --> fullPage
		[self resizePageImage:CGRectMake(0, 0, 768, 1004)];
	}
}

/**
 *	called by PageView instances, when double-tapped
 */
- (void) pageSingleTapped:(CGPoint)tapPoint {
	if (!orientationIsLandscape && naviVisible) {
		[self showNavi:NO];
	}
}


- (void) pageLoadingDone:(int)pageNumber {	
	// Notify navigation:
	if (naviLoaded) {
		[naviView resetActiveItem];
		[naviView setItemDisplayMode:NAVI_ITEM_MODE_ACTIVE forItemWithTag:pageNumber];
		
		// NSLog(@"AKTUELLE / VORIGE SEITE: %d / %d", [pageView currentPageNumber], [pageView previousPageNumber]);
		[toolbar showZurueckButton:([pageView previousPageNumber] != -1)];
	}
}


- (bool) isOrientationLandscape {
	return orientationIsLandscape;
}


#pragma mark -
#pragma mark NAVI VIEW NOTIFICATIONS

/**
 *	called by NaviView instances, when loading is done
 */
- (void) naviFinishedLoading {
	[naviView setHidden:NO];
	[pageView setHidden:NO];
	[pageView gotoPage:1];
	
	int lastPage = [self getLastPagenumberFromPropertyFile];
	if (lastPage) {
		[pageView gotoPage:lastPage];
	}
	
	naviLoaded = YES;
	[NSTimer scheduledTimerWithTimeInterval:1.3 target:self selector:@selector(hideSplashScreen) userInfo:nil repeats:NO];
}

/**
 *	called by PageView instances, when single Item is being touched
 */
- (void) naviItemClicked:(int)page {
	numberOfLoadingPage = page;
	if (!orientationIsLandscape) {
		[self showNavi:NO];
	}
	[pageView gotoPage:page];
}

#pragma mark -
#pragma mark TOOLBAR CLICK NOTIFICATIONS:

- (void) helpButtonClicked {
	[self showInfoView:YES];
}

- (void) naviHideButtonClicked {
	if (orientationIsLandscape && naviVisible) {
		// simulate a doubleTap at the top page edge: 
		CGPoint touchPoint = [self.view center];
		touchPoint.y = 0.0;
		[self pageDoubleTapped:touchPoint];
	}
	else {
		[self showNavi:NO];
	}
}

- (void) naviShowButtonClicked {
	if (orientationIsLandscape && !naviVisible) {
		// simulate a doubleTap at the top page edge: 
		[self pageDoubleTapped:[self.view center]];
	}
	else {
		[self showNavi:YES];
	}
}

- (void) zurueckButtonClicked {
	if ([pageView previousPageNumber] > -1) {
		[self naviItemClicked:[pageView previousPageNumber]];
		[pageView setPreviousPageNumber: -1];
	}
}


#pragma mark -
#pragma mark TOOLBAR CLICK ACTIONS:

- (void) showInfoView:(bool)show {
	
	[infoView setFrame:[RootVC centerFrame:[infoView frame] inFrame:currentScreen]];
	
	if ((show && infoView.alpha > 0.0) || (!show && infoView.alpha == 0.0)) {
		return;
	}
	
	CGFloat finalAlpha = 0.0;
	
	if (show) {
		finalAlpha = 1.0;
	}
	
	[UIView beginAnimations:ANI_INFO_FADE context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[infoView setAlpha:finalAlpha];
	[UIView commitAnimations];
}


#pragma mark -
#pragma mark INFO VIEW NOTIFICATIONS

- (void) closeRequested {
	[self showInfoView:NO];
}

#pragma mark -
#pragma mark STATIC HELPER METHODS

/**
 *	moves a frame by x and y specified in a CGPoint
 */
+ (CGRect) translateFrame:(CGRect)frame byVector:(CGPoint)vector {
	CGPoint currentPosition = frame.origin;
	currentPosition.x += vector.x;
	currentPosition.y += vector.y;
	frame.origin = currentPosition;
	return frame;
}


+ (CGRect) centerFrame:(CGRect)f1 inFrame:(CGRect)f2 {
	CGFloat offsetX = (f2.size.width - f1.size.width) / 2;
	CGFloat offsetY = (f2.size.height - f1.size.height) / 2;
	f1.origin = CGPointMake(offsetX, offsetY);
	return f1;
}


+ (bool) frameOrientationIsLandscape:(CGRect)frame {
	return (frame.size.width > frame.size.height);
}




- (int) getLastPagenumberFromPropertyFile {

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *finalPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:PROPERTYFILE];
	
	int pageNumber = 0;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:finalPath]) {
		
		NSDictionary *plistData =  [NSDictionary dictionaryWithContentsOfFile:finalPath];
		if([plistData objectForKey:PROP_LAST_PAGE_NUMBER] != nil) {
			pageNumber = [[plistData objectForKey:PROP_LAST_PAGE_NUMBER] intValue];	
		}
	}	
	return pageNumber;
}


/**
 *	saves the information if infoview should show up on startup to property file
 */
- (void) writeLastPagenumberToPropertyFile {
	
	int pageNumber = [pageView currentPageNumber];
	
	//save to file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *finalPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:PROPERTYFILE];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:finalPath]){
		// file exists overwrite value:
		NSMutableDictionary *plistData = [NSMutableDictionary dictionaryWithContentsOfFile:finalPath];
		[plistData setValue:[NSNumber numberWithInt:pageNumber] forKey:PROP_LAST_PAGE_NUMBER];
		[plistData writeToFile:finalPath atomically:YES];
	}		
	else {
		// create file and key-value-entry:
		NSMutableDictionary *plistData = [NSMutableDictionary new];
		[plistData setValue:[NSNumber numberWithInt:pageNumber] forKey:PROP_LAST_PAGE_NUMBER];
		[plistData writeToFile:finalPath atomically:YES];
		[plistData release];
	}
}



/**
 *	provides the currently accessible screen dimensions. 
 *	--> "application viewport" 
 */
+ (CGRect) getCurrentScreen:(bool)inLandscapeMode {
	CGRect currentScreen;
	if (inLandscapeMode) {
		currentScreen = CGRectMake(0, 20, 1024, 748);
	}
	else {
		currentScreen = CGRectMake(0, 20, 768, 1004);
	}
	return currentScreen;
}

#pragma mark -
#pragma mark DESTRUCTORS AND SUCH...


- (void) applicationWillTerminate:(UIApplication *)application {
	[self writeLastPagenumberToPropertyFile];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[naviView release];
	[pageView release];
	[toolbar release];
	[infoView release];
    [super dealloc];
}



@end

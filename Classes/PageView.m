//
//  PageView.m
//  LeckerXMas
//
//  Created by Heiko Bublitz on 07.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import "PageView.h"
#import "ThumbView.h"
#import "RootVC.h"

@implementation PageView

@synthesize pageViewDelegate;
@synthesize currentScreen;
@synthesize currentPageNumber;
@synthesize previousPageNumber;
@synthesize suppressOverlayTouches;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
		[self setUserInteractionEnabled:YES];
		[self setMultipleTouchEnabled:YES];
		
		prevPage = [[PageImage alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[prevPage setTouchDelegate:self];
		[self addSubview:prevPage];
		
		nextPage = [[PageImage alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[nextPage setTouchDelegate:self];
		[self addSubview:nextPage];
		
		centerPage = [[PageImage alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[centerPage setTouchDelegate:self];
		[self addSubview:centerPage];
		
		currentPageNumber = -1;
		previousPageNumber = -1;
		
		[self calcMotionLimits];
		[self initOverlayData];
    }
    return self;
}



- (void) gotoPage:(int)page {
	
	pageNumber2change2 = page;
	
	if (currentPageNumber == -1) {
		
		//// first Load, no Animation!
		
		[centerPage setPageNumber:page];
		[centerPage setCenter:[self center]];
		if ([self frame].origin.x > 0) {
			[centerPage setFrame:[RootVC translateFrame:[centerPage frame] byVector:CGPointMake([self frame].origin.x * -1, 0)]];
		}
		currentPageNumber = page;
		[self calcMotionLimits];
		[self loadPagesAfterInit];
		return;
	}
	
	
	CGFloat deltaX = 0;	
	CGFloat deltaY = 0;
	
	
	if (page > currentPageNumber) {
		//// MOVE T ONEXT PAGE!
		deltaX = [nextPage frame].origin.x * -1;
		if ([nextPage getPageNumber] != page) {
			[nextPage setPageNumber:page];
		}
	}
	else if (page < currentPageNumber) {
		//// MOVE TO PREVIOUS PAGE!
		deltaX = [prevPage frame].origin.x * -1;
		if ([prevPage getPageNumber] != page) {
			[prevPage setPageNumber:page];
		}
	}
	
	CGPoint motion = CGPointMake(deltaX, deltaY);
	
	CGRect frPrev = [RootVC translateFrame:[prevPage frame] byVector:motion];
	CGRect frThis = [RootVC translateFrame:[centerPage frame] byVector:motion];
	CGRect frNext = [RootVC translateFrame:[nextPage frame] byVector:motion];
	
	[UIView beginAnimations:ANI_SPLASH_HIDE context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

	[prevPage setFrame:frPrev];
	[centerPage setFrame:frThis];
	[nextPage setFrame:frNext];
	
	[UIView commitAnimations];
	
}




- (void) keepCurrentPageAndSlideByVector:(CGPoint)motion {
	
	// NSLog(@"KEIN SEITENWECHSEL!");
	pageNumber2change2 = currentPageNumber;
	
	CGFloat targetX = [centerPage frame].origin.x;
	CGFloat targetY = [centerPage frame].origin.y;
	
	if ([centerPage frame].size.width <= [self frame].size.width) {
		targetX = 0;
	}
	else if (fabs(moveSpeedX) > 5) {
		if (moveSpeedX > 0) {
			targetX = 0;
		}
		else {
			targetX = [self frame].size.width - [centerPage frame].size.width;
		}
	}
	else if (targetX < imageMinX) {
		targetX = imageMinX;
	}
	else if (targetX > imageMaxX) {
		targetX = imageMaxX;
	}

	
	bool linkVerticalPositions = NO;
	
	if (fabs(moveSpeedY) > 5 && [centerPage frame].size.height > currentScreen.size.height) {
		
		if (currentScreen.size.width > currentScreen.size.height) {
			linkVerticalPositions = YES;
		}
		
		if (moveSpeedY > 0) {
			targetY = 0;
		}
		else {
			targetY = currentScreen.size.height - [centerPage frame].size.height;
		}
	}
	else {
		if (currentScreen.size.width > currentScreen.size.height) {
			linkVerticalPositions = YES;
		}
	}

	//// Setup each pages frames:
	CGRect frThis = CGRectMake(targetX, targetY, [centerPage frame].size.width, [centerPage frame].size.height);
	CGRect frPrev = [prevPage frame];
	CGRect frNext = [nextPage frame];
	
	frPrev.origin.x = frThis.origin.x - frPrev.size.width;
	frNext.origin.x = frThis.origin.x + frThis.size.width;
	
	if (linkVerticalPositions) {
		frPrev.origin.y = frThis.origin.y;
		frNext.origin.y = frThis.origin.y;
	}
	
	
	[UIView beginAnimations:ANI_SPLASH_HIDE context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	[prevPage setFrame:frPrev];
	[centerPage setFrame:frThis];
	[nextPage setFrame:frNext];
	
	[UIView commitAnimations];
}



- (void) loadPagesAfterInit {
	[prevPage setPageNumber:[self getPrevPageNumber]];
	[prevPage setFrame:[RootVC translateFrame:[self frame] byVector:CGPointMake(([self frame].size.width * -1) - [self frame].origin.x, 0)]];
	[nextPage setPageNumber:[self getNextPageNumber]];
	[nextPage setFrame:[RootVC translateFrame:[self frame] byVector:CGPointMake([self frame].size.width - [self frame].origin.x, 0)]];
	[self addOverlaysToPages];
	[pageViewDelegate pageLoadingDone:currentPageNumber];
}


- (void) loadPagesAfterSwap {

	CGFloat prevY = [prevPage frame].origin.y;
	
	NSLog(@"POST-Seitenwechsel-Anpassungen .....");
	
	[centerPage zoomToRect:[prevPage frame]];
	[centerPage moveToX:0];
	[centerPage moveToY:prevY];
	[centerPage setPageNumber:currentPageNumber];
	
	[prevPage setPageNumber:[self getPrevPageNumber]];
	[self resizeImageToPageWidth:prevPage];
	[prevPage moveToX:[prevPage frame].size.width * -1];
	[prevPage moveToY:prevY];
	
	[nextPage setPageNumber:[self getNextPageNumber]];
	[self resizeImageToPageWidth:nextPage];
	[nextPage moveToX:[self frame].size.width];
	[nextPage moveToY:prevY];
	
	[self addOverlaysToPages];
	if (!previousChangeFromOverlayTouch || previousPageNumber == currentPageNumber) {
		previousPageNumber = -1;
	}
	[pageViewDelegate pageLoadingDone:currentPageNumber];
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if (pageNumber2change2 != currentPageNumber) {
		currentPageNumber = pageNumber2change2;
		[self loadPagesAfterSwap];	
	}
	[self calcMotionLimits];
}


//// ZOOM-OUT in LANDSCAPE
- (void) resizePageAndImageToRect:(CGRect)newFrame {
	[self setFrame:newFrame];
	newFrame.origin = CGPointMake(0, 0);
	[self setImageWidth:newFrame.size.width];
	[centerPage setFrame:newFrame];
	[self loadPagesAfterInit];
}


- (void) resizeToRect:(CGRect)newFrame {
	[self setFrame:newFrame];
	[self loadPagesAfterInit];
}


//// ZOOM_OUT in PORTRAIT
- (void) resizeImageToRect:(CGRect)newFrame {
	[self setImageWidth:newFrame.size.width];
	[centerPage setFrame:newFrame];
	[self loadPagesAfterInit];
}


- (void) resizeImageToRect:(CGRect)newFrame pageImage:(PageImage *)image {
	[self setImageWidth:newFrame.size.width];
	[image setFrame:newFrame];
	[centerPage removeOverlays];
	[self addOverlaysToPages];
}


- (void) resizeImageToPageWidth:(PageImage *)image {
	CGFloat w = [self frame].size.width;
	CGFloat h = [image frame].size.height * (w / [image frame].size.width);
	CGRect newFrame = CGRectMake(0, [image frame].origin.y, w, h);
	[self resizeImageToRect:newFrame pageImage:image];
}

//// ZOOM-IN in LANDSCAPE
- (void) zoomToPageWidthWithTouchPoint:(CGPoint)touchPoint {
	
	CGFloat pageWidth = currentScreen.size.width;
	CGFloat scaleFactor = pageWidth / [self frame].size.width;
	CGFloat pageHeight = [self frame].size.height * scaleFactor;
	
	// first set new size and defauklt position:
	[self resizeToRect:CGRectMake(0, 0, pageWidth, pageHeight)];
	
	CGFloat touchY = touchPoint.y * scaleFactor;
	CGFloat deltaY = CGRectGetMidY(currentScreen) - touchY;
	CGRect imgFrame = [RootVC translateFrame:[self frame] byVector:CGPointMake(0, deltaY)];
	
	CGFloat minY = currentScreen.size.height - imgFrame.size.height;
	CGFloat maxY = 0;
	
	if (imgFrame.origin.y > maxY) {
		imgFrame.origin.y = maxY;
	}
	if (imgFrame.origin.y < minY) {
		imgFrame.origin.y = minY;
	}
	
	[self setImageWidth:imgFrame.size.width];
	[self resizeImageToRect:imgFrame pageImage:centerPage];
}

//// ZOOM-IN in PORTRAIT
- (void) zoomImageToSize:(CGSize)newSize withTouchPoint:(CGPoint)touchPoint {
	
	CGFloat pageWidth = newSize.width;
	CGFloat scaleFactor = pageWidth / [self frame].size.width;
	CGFloat pageHeight = [self frame].size.height * scaleFactor;
	
	CGFloat touchX = touchPoint.x * scaleFactor;
	CGFloat touchY = touchPoint.y * scaleFactor;
	CGFloat deltaX = CGRectGetMidX(currentScreen) - touchX;
	CGFloat deltaY = CGRectGetMidY(currentScreen) - touchY;
	
	CGRect imgFrame = CGRectMake(0, 0, pageWidth, pageHeight);
	imgFrame = [RootVC translateFrame:imgFrame byVector:CGPointMake(deltaX, deltaY)];
	
	CGFloat minX = currentScreen.size.width - imgFrame.size.width;
	CGFloat maxX = 0;
	CGFloat minY = currentScreen.size.height - imgFrame.size.height;
	CGFloat maxY = 0;
	
	if (imgFrame.origin.x > maxX) {
		imgFrame.origin.x = maxX;
	}
	if (imgFrame.origin.x < minX) {
		imgFrame.origin.x = minX;
	}
	if (imgFrame.origin.y > maxY) {
		imgFrame.origin.y = maxY;
	}
	if (imgFrame.origin.y < minY) {
		imgFrame.origin.y = minY;
	}
	
	[self setImageWidth:pageWidth];	
	[self resizeImageToRect:imgFrame pageImage:centerPage];
	[self loadPagesAfterInit];
}



- (void) imageAnimationDone {
	[self calcMotionLimits];
}


- (void) moveBy:(CGPoint)vector {
	CGRect tmpFrame = [centerPage frame];
	CGFloat newX = tmpFrame.origin.x + vector.x;
	CGFloat newY = tmpFrame.origin.y + vector.y;
	
	pageNumber2change2 = currentPageNumber;
	
	if (newX < imageMinX) {
		pageNumber2change2 = [self getNextPageNumber];
		if (pageNumber2change2 != currentPageNumber) {
			tmpFrame.origin.x = newX;
		}
	}
	else if (newX > imageMaxX) {
		pageNumber2change2 = [self getPrevPageNumber];
		if (pageNumber2change2 != currentPageNumber) {
			tmpFrame.origin.x = newX;
		}
	}
	else {
		pageNumber2change2 = currentPageNumber;
		tmpFrame.origin.x = newX;
	}

	
	if (newY >= imageMinY && newY <= imageMaxY) {
		tmpFrame.origin.y = newY;
	}
	
	[centerPage setFrame:tmpFrame];
	[nextPage moveToX:CGRectGetMaxX([centerPage frame])];
	[prevPage moveToX:CGRectGetMinX([centerPage frame]) - [prevPage frame].size.width];
	
	if ([prevPage frame].size.height == [centerPage frame].size.height) {
		[prevPage moveToY:tmpFrame.origin.y];
	}
	if ([nextPage frame].size.height == [centerPage frame].size.height) {
		[nextPage moveToY:tmpFrame.origin.y];
	}
}



- (void) calcMotionLimits {
	CGRect frPage = [centerPage frame];
	
	imageMinX = 0 - (frPage.size.width - currentScreen.size.width);
	imageMinY = 0 - (frPage.size.height - currentScreen.size.height);
	
	imageMaxX = 0;
	imageMaxY = 0;
	
	//NSLog(@"minX = %.0f / maxX = %.0f / minY = %.0f / maxY = %.0f", imageMinX, imageMaxX, imageMinY, imageMaxY);
}


#pragma mark image touch notifications
-(void)imageSingleTouch:(CGPoint)touchPoint {
	
}

-(void)imageFingerZoom:(CGRect)zoomRect {
	
}

-(void)imageDoubleTap:(CGPoint)touchPoint {
	
}



#pragma mark TOUCH HANDLING

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	NSSet *allTouches = [event allTouches];
	UITouch *touch0 = [[allTouches allObjects] objectAtIndex:0];
	
	if (1 == [allTouches count]) {
		// Tap or Move page
		CGPoint touchPoint = [touch0 locationInView:centerPage];
		if (!suppressOverlayTouches) {
			overlayTargetPage = [centerPage getOverlayTargetPageByTouchPoint:touchPoint];
			[centerPage flashTouchedOverlay];
		}
	}
	else if (2 == [allTouches count]) {
		// zoom page
		UITouch *touch1 = [[allTouches allObjects] objectAtIndex:1];
		zoomFingeDistance = [PageView calcDistanceBetweenPoint1:[touch0 locationInView:self] andPoint2:[touch1 locationInView:self]];
		NSLog(@"Fingerabstand: %.0f", zoomFingeDistance);
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSSet *allTouches = [event allTouches];
	UITouch *touch0 = [[allTouches allObjects] objectAtIndex:0];
	
	if (1 == [allTouches count]) {
		moveSpeedX = [touch0 locationInView:self].x - [touch0 previousLocationInView:self].x;
		moveSpeedY = [touch0 locationInView:self].y - [touch0 previousLocationInView:self].y;
		[self moveBy:CGPointMake(moveSpeedX, moveSpeedY)];
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSSet *allTouches = [event allTouches];
	UITouch *touch = [touches anyObject];
	zoomingRequested = FALSE;
	
	if (1 == [allTouches count]) {
		// single digit:
		
		if ([touch tapCount] == 0) {
			// MOTION:
			if (pageNumber2change2 != currentPageNumber) {
				if ((pageNumber2change2 > currentPageNumber && moveSpeedX < PAGE_SWAP_SPEED_MIN *-1) || 
					(pageNumber2change2 < currentPageNumber && moveSpeedX > PAGE_SWAP_SPEED_MIN)) {
					// fast enough, switch to desired page
					[self gotoPage:pageNumber2change2];
				}
				else {
					// too slow or wrong direction, return to current page
					[self keepCurrentPageAndSlideByVector:CGPointMake(moveSpeedX, moveSpeedY)];
				}
 
			}
			else {
				[self keepCurrentPageAndSlideByVector:CGPointMake(moveSpeedX, moveSpeedY)];
			}

		}
		
		
		if ([touch tapCount] == 2) {
			// double touch:
			zoomingRequested = TRUE;
			[pageViewDelegate pageDoubleTapped:CGPointMake([touch locationInView:self].x, [touch locationInView:self].y)];
		}
		
		if ([touch tapCount] == 1) {
			// single touch:
			if (!zoomingRequested && overlayTargetPage > -1 && !suppressOverlayTouches) {
				if (overlayTargetPage > TOTAL_NUMBER_OF_PAGES) {
					//// WEBLINK:
					overlayTargetPage = -1;
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.lecker.de/weihnachten"]];
				}
				[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(overlayTouch:) userInfo:[NSNumber numberWithInt:overlayTargetPage] repeats:NO];
			}
			else {
				[pageViewDelegate pageSingleTapped:CGPointMake([touch locationInView:self].x, [touch locationInView:self].y)];
			}
		}	
		
	}
	else if (2 == [allTouches count]) {
		// two fingers:
		zoomingRequested = TRUE;
		UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
		UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
		CGPoint touchesCenter = [PageView getCenterBetween:[touch1 locationInView:self] andPoint:[touch2 locationInView:self]];
		[pageViewDelegate pageDoubleTapped:touchesCenter];
	}
	// set overlay target to "none" again:
	overlayTargetPage = -1;
}


- (int) getNextPageNumber {
	int desiredPageNumber = currentPageNumber +1;
	int max = TOTAL_NUMBER_OF_PAGES;
	while (![ThumbView imageExistsForPage:desiredPageNumber]) {
		desiredPageNumber ++;
		if (desiredPageNumber > max) {
			return currentPageNumber;
		}
	}
	return desiredPageNumber;
}


- (int) getPrevPageNumber {
	int desiredPageNumber = currentPageNumber -1;
	while (![ThumbView imageExistsForPage:desiredPageNumber]) {
		desiredPageNumber --;
		if (desiredPageNumber < 1) {
			return currentPageNumber;
		}
	}
	return desiredPageNumber;
}


- (void) setImageWidth:(CGFloat)width {
	imageWidth = width;
	[centerPage setImageWidth: width];
	[centerPage setImageScaleFactor:width / UNSCALED_IMAGES_WIDTH];
	[centerPage removeOverlays];
	[self addOverlaysToPages];	
}

- (CGFloat) getImageWidth {
	return imageWidth;
}



/**
 *	Retrieves raw data of overlay definitions and parses each row
 *	in order to assign data to distinct pages later
 */
- (void) initOverlayData {
	
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *resourcePath = [mainBundle resourcePath];
	NSString *filePath = [resourcePath stringByAppendingPathComponent: @"overlays.plist"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		overlayRawData = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
		overlayObjects = [[NSMutableArray alloc] init];
	}
	// [mainBundle release];
	
	NSArray *pagesAndTargets = [overlayRawData allKeys];
	
	int parentPage;
	int targetPage;
	CGFloat left;
	CGFloat top;
	CGFloat width;
	CGFloat height;
	Overlay *ovrTemp;
	
	for (NSString *pageAndTarget in pagesAndTargets) {
		NSString *sizeAndCoords = [overlayRawData objectForKey:pageAndTarget];
		
		NSMutableArray * pageAndTargetData = [[NSMutableArray alloc] init];
		[pageAndTargetData addObjectsFromArray: [pageAndTarget componentsSeparatedByString:@"_"]];
		parentPage = [[pageAndTargetData objectAtIndex:0] intValue];
		targetPage = [[pageAndTargetData objectAtIndex:1] intValue];
		
		NSMutableArray * sizeAndCoordsData = [[NSMutableArray alloc] init];
		[sizeAndCoordsData addObjectsFromArray: [sizeAndCoords componentsSeparatedByString:@"|"]];
		left = [[sizeAndCoordsData objectAtIndex:0] floatValue];
		top = [[sizeAndCoordsData objectAtIndex:1] floatValue];
		width = [[sizeAndCoordsData objectAtIndex:2] floatValue];
		height = [[sizeAndCoordsData objectAtIndex:3] floatValue];
		
		CGRect ovrFrame = CGRectMake(left, top, width, height);
		ovrTemp = [[Overlay alloc] initWithFrame:ovrFrame];
		[ovrTemp setParentPageId:parentPage];
		[ovrTemp setTargetPageId:targetPage];
		[overlayObjects addObject:ovrTemp];
		
		[pageAndTargetData release];
		[sizeAndCoordsData release];
	}
	[ovrTemp release];
	[overlayRawData release];
}





- (void) addOverlaysToPages {
	[centerPage setOrientationIsLandscape:[pageViewDelegate isOrientationLandscape]];
	[centerPage removeOverlays];
	for(int i = 0; i < [overlayObjects count]; ++i) {
		if ([(Overlay *)[overlayObjects objectAtIndex:i] parentPageId] == [centerPage pageNumber]) {
			[centerPage addOverlay:(Overlay *)[overlayObjects objectAtIndex:i]];
		}
	}
}


- (void) overlayTouch:(NSTimer *)timer {
	int neueSeite = [timer.userInfo integerValue];
	if (!zoomingRequested) {
		previousChangeFromOverlayTouch = YES;
		previousPageNumber = currentPageNumber;
		[self gotoPage:neueSeite];
	}
}

								 
+ (CGPoint) getCenterBetween:(CGPoint)p1 andPoint:(CGPoint)p2 {
	 CGFloat newX = (p1.x + p2.x) / 2;
	 CGFloat newY = (p1.y + p2.y) / 2;
	 return CGPointMake(newX, newY);
}


+ (CGFloat) calcDistanceBetweenPoint1:(CGPoint)p1 andPoint2:(CGPoint)p2 {
	return sqrt(fabs(p1.x - p2.x)*fabs(p1.x - p2.x) + fabs(p1.y - p2.y)*fabs(p1.y - p2.y));
}


- (void)dealloc {
	[prevPage release];
	[centerPage release];
	[nextPage release];
	[overlayRawData release];
	[overlayObjects release];
    [super dealloc];
}


@end

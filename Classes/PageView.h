//
//  PageView.h
//  LeckerXMas
//
//  Created by Heiko Bublitz on 07.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageImage.h"

#define PAGE_SWAP_SPEED_MIN 16


@protocol PageViewNotifications

- (void) pageDoubleTapped:(CGPoint)tapPoint;
- (void) pageSingleTapped:(CGPoint)tapPoint;
- (void) pageLoadingDone:(int)pageNumber;
- (bool) isOrientationLandscape;

@end



@interface PageView : UIView <ImageTouchNotifications> {

	PageImage *prevPage;
	PageImage *centerPage;
	PageImage *nextPage;
	int currentPageNumber;
	int previousPageNumber;
	
	CGFloat moveSpeedX;
	CGFloat moveSpeedY;
	
	id <PageViewNotifications> pageViewDelegate;
	
	CGRect currentScreen;
	
	CGFloat imageMinX;
	CGFloat imageMaxX;
	CGFloat imageMinY;
	CGFloat imageMaxY;
	
	CGFloat imageWidth;
	CGFloat imageScaleFactor;
	int pageNumber2change2;
	
	bool zoomingRequested;
	CGFloat zoomFingeDistance;
	bool suppressOverlayTouches;
	
	NSMutableDictionary *overlayRawData;
	NSMutableArray *overlayObjects;
	bool previousChangeFromOverlayTouch;
	int overlayTargetPage;
}


- (void) resizeToRect:(CGRect)newFrame;
- (void) resizeImageToRect:(CGRect)newFrame;
- (void) resizeImageToRect:(CGRect)newFrame pageImage:(PageImage *)image;
- (void) resizeImageToPageWidth:(PageImage *)image;
- (void) resizePageAndImageToRect:(CGRect)newFrame;
- (void) zoomToPageWidthWithTouchPoint:(CGPoint)touchPoint;
- (void) zoomImageToSize:(CGSize)newSize withTouchPoint:(CGPoint)touchPoint;
- (void) setImageWidth:(CGFloat)width;
- (CGFloat) getImageWidth;

- (void) imageAnimationDone;
- (void) moveBy:(CGPoint)vector;
- (void) calcMotionLimits;
- (void) gotoPage:(int)page;
- (void) loadPagesAfterInit;
- (void) loadPagesAfterSwap;

- (void) keepCurrentPageAndSlideByVector:(CGPoint)motion;
- (int) getNextPageNumber;
- (int) getPrevPageNumber;

- (void) initOverlayData;
- (void) addOverlaysToPages;
- (void) overlayTouch:(NSTimer *)timer;

+ (CGPoint) getCenterBetween:(CGPoint)p1 andPoint:(CGPoint)p2;
+ (CGFloat) calcDistanceBetweenPoint1:(CGPoint)p1 andPoint2:(CGPoint)p2;

@property (nonatomic, assign) id <PageViewNotifications> pageViewDelegate;
@property (nonatomic, assign) CGRect currentScreen;
@property (nonatomic, assign) int currentPageNumber;
@property (nonatomic, assign) int previousPageNumber;
@property (nonatomic, assign) bool suppressOverlayTouches;

@end

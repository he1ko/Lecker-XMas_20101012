//
//  PageImage.h
//  LeckerXMas
//
//  Created by Heiko Bublitz on 07.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Overlay.h"


@protocol ImageTouchNotifications

-(void)imageSingleTouch:(CGPoint)touchPoint;
-(void)imageFingerZoom:(CGRect)zoomRect;
-(void)imageDoubleTap:(CGPoint)touchPoint;

@end



@interface PageImage : UIImageView {

	int pageNumber;
	id <ImageTouchNotifications> touchDelegate;
	CGFloat imageWidth;
	CGFloat imageScaleFactor;
	int targetPageOfTouchedOverlay;
	bool orientationIsLandscape;
}

- (void) setPageNumber:(int)page;
- (int)  getPageNumber;
- (void) setImageFromPageNumber:(int)page;
- (void) zoomToRect:(CGRect)newRect;
- (void) moveToX:(CGFloat)xPos;
- (void) moveToY:(CGFloat)yPos;
- (void) addOverlay:(Overlay *)ovr;
- (void) removeOverlays;
- (void) activateOverlays:(bool)active;
- (int) getOverlayTargetPageByTouchPoint:(CGPoint)p;
- (void) flashTouchedOverlay;

@property (nonatomic, assign) id <ImageTouchNotifications> touchDelegate;
@property (nonatomic, assign) int pageNumber;
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageScaleFactor;
@property (nonatomic, assign) bool orientationIsLandscape;

@end

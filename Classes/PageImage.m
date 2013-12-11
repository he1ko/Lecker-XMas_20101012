//
//  PageImage.m
//  LeckerXMas
//
//  Created by Heiko Bublitz on 07.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import "PageImage.h"


@implementation PageImage

@synthesize touchDelegate;
@synthesize pageNumber;
@synthesize imageWidth;
@synthesize imageScaleFactor;
@synthesize orientationIsLandscape;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self setUserInteractionEnabled:YES];
    }
    return self;
}


- (void) setPageNumber:(int)page {
	pageNumber = page;
	[self setImageFromPageNumber:page];
}


- (void) removeOverlays {
	NSArray *sv = [self subviews];
	for (int i=0; i<[sv count]; i++) {
		if ([[sv objectAtIndex:i] isKindOfClass:[Overlay class]] ) {
			[[sv objectAtIndex:i] removeFromSuperview];
		}
	}
}


- (void) activateOverlays:(bool)active {
	NSArray *sv = [self subviews];
	for (int i=0; i<[sv count]; i++) {
		if ([[sv objectAtIndex:i] isKindOfClass:[Overlay class]] ) {
			[[sv objectAtIndex:i] setUserInteractionEnabled:active];
		}
	}
}


- (void) addOverlay:(Overlay *)ovr {
	
	CGFloat scaleFactor_w = [self frame].size.width / UNSCALED_IMAGES_WIDTH;
	CGFloat scaleFactor_h = [self frame].size.height / UNSCALED_IMAGES_HEIGHT;
	
	CGFloat w = [ovr initialFrame].size.width * scaleFactor_w;
	CGFloat h = [ovr initialFrame].size.height * scaleFactor_h;
	CGFloat x = [ovr initialFrame].origin.x * scaleFactor_w;
	CGFloat y = [ovr initialFrame].origin.y * scaleFactor_h;
		
	[ovr setFrame:CGRectMake(x, y, w, h)];
	
	[self addSubview:ovr];
	[ovr fadeOut:0.8];
}


//// ermittelt die Zielseite des Overlays unter dem Touch-Punkt
- (int) getOverlayTargetPageByTouchPoint:(CGPoint)p {
	NSArray *sv = [self subviews];
	CGRect tmpRect;
	targetPageOfTouchedOverlay = -1;
	
	for (int i=0; i<[sv count]; i++) {
		if ([[sv objectAtIndex:i] isKindOfClass:[Overlay class]] ) {
			tmpRect = [[sv objectAtIndex:i] frame];
			if (CGRectContainsPoint(tmpRect, p)) {
				targetPageOfTouchedOverlay = [(Overlay *)[sv objectAtIndex:i] targetPageId];
				break;
			}
		}
	}
	return targetPageOfTouchedOverlay;
}


- (void)flashTouchedOverlay {
	NSArray *sv = [self subviews];
	for (int i=0; i<[sv count]; i++) {
		if ([[sv objectAtIndex:i] isKindOfClass:[Overlay class]] ) {
			if ([(Overlay *)[sv objectAtIndex:i] targetPageId] == targetPageOfTouchedOverlay) {
				[(Overlay *)[sv objectAtIndex:i] fadeOut:0.5];
			}
		}
	}
}


- (void) setImageFromPageNumber:(int)page {
	NSString *filename = [NSString stringWithFormat:FILENAME_PATTERN_PAGE, page];
	self.image = [UIImage imageNamed:filename];
}


- (void) zoomToRect:(CGRect)newRect {
	[self setFrame:newRect];
}


- (void) moveToX:(CGFloat)xPos {
	CGRect tmpFrame = [self frame];
	tmpFrame.origin.x = xPos;
	[self setFrame:tmpFrame];
}

- (void) moveToY:(CGFloat)yPos {
	CGRect tmpFrame = [self frame];
	tmpFrame.origin.y = yPos;
	[self setFrame:tmpFrame];
}

- (int) getPageNumber {
	return pageNumber;
}


- (void)dealloc {
    [super dealloc];
}


@end

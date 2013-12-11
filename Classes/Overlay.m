//
//  Overlay.m
//  LeckerXMas
//
//  Created by adm.bublitz_mac on 04.10.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import "Overlay.h"


@implementation Overlay

@synthesize parentPageId;
@synthesize targetPageId;
@synthesize initialFrame;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self setInitialFrame:frame];
        [self setUserInteractionEnabled:NO];
		[self setBackgroundColor:[UIColor clearColor]];
		
		frame.origin = CGPointMake(0, 0);
		b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[b setBackgroundColor:[UIColor lightGrayColor]];
		[b setFrame:frame];
		[self addSubview:b];

		[self fadeOut:0.1];
    }
    return self;
}


- (void) adjustContent {
	CGRect frame = [b frame];
	frame.size.width = [self frame].size.width;
	frame.size.height = [self frame].size.height;
	[b setFrame:frame];
}


- (void) fadeOut:(CGFloat)seconds {
	[self adjustContent];
	[self setAlpha:0.5];
	
	[UIView beginAnimations:@"hideOverlay" context:NULL];
	[UIView setAnimationDuration:seconds];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[self setAlpha:0.0];
	[UIView commitAnimations];
}



- (void)dealloc {
	[b release];
    [super dealloc];
}


@end

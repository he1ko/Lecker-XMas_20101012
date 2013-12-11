//
//  ButtonPanel.m
//  sansibar
//
//  Created by Heiko Bublitz on 22.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import "Toolbar.h"


@implementation Toolbar

@synthesize toolbarDelegate;
@synthesize toolbarTouchDelegate;
@synthesize visible;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code

		[self setUserInteractionEnabled:YES];
		[self setBackgroundColor:[UIColor clearColor]];
		[self setImage:[UIImage imageNamed:@"toolbar-bg.png"]];
		
		/**
		 * Define and place custom toolbar buttons:
		 */
		
		helpButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 1, 58, 58)];
		[helpButton setImage:[UIImage imageNamed:@"sym-help.png"] forState:UIControlStateNormal];
		[self addSubview:helpButton];
		[helpButton release];
		
		naviShowButton = [[UIButton alloc] initWithFrame:CGRectMake(400, 1, 58, 58)];
		[naviShowButton setImage:[UIImage imageNamed:@"sym-navi-show.png"] forState:UIControlStateNormal];
		[self addSubview:naviShowButton];
		[naviShowButton release];
		
		naviHideButton = [[UIButton alloc] initWithFrame:CGRectMake(400, 1, 58, 58)];
		[naviHideButton setImage:[UIImage imageNamed:@"sym-navi-hide.png"] forState:UIControlStateNormal];
		[self addSubview:naviHideButton];
		[naviHideButton release];
		
		zurueckButton = [[UIButton alloc] initWithFrame:CGRectMake(310, 0, 60, 60)];
		[zurueckButton setImage:[UIImage imageNamed:@"sym-zurueck.png"] forState:UIControlStateNormal];
		[self addSubview:zurueckButton];
		[zurueckButton setHidden:YES];
		[zurueckButton release];
		
		/**
		 * add event handlers to each button:
		 */
		[helpButton addTarget:self action:@selector(helpButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[naviHideButton addTarget:self action:@selector(naviHideButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[naviShowButton addTarget:self action:@selector(naviShowButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[zurueckButton addTarget:self action:@selector(zurueckButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		
    }
    return self;
}



- (void) helpButtonClicked {
	[toolbarDelegate helpButtonClicked];
}


- (void) naviHideButtonClicked {
	[toolbarDelegate naviHideButtonClicked];
}

- (void) naviShowButtonClicked {
	[toolbarDelegate naviShowButtonClicked];
}

- (void) zurueckButtonClicked {
	[toolbarDelegate zurueckButtonClicked];
}


- (void) updateButtonStates {
	
	if (visible) {
		[naviShowButton setHidden:YES];
		[naviHideButton setHidden:NO];
	}
	else {
		[naviShowButton setHidden:NO];
		[naviHideButton setHidden:YES];
	}
}


- (void) showZurueckButton:(bool)show {
	if (zurueckButton.hidden != show) {
		return;
	}
	[zurueckButton setHidden:!show];
	[self moveMeHorizontalTo:[self getXPosForState:visible]];
}


#pragma mark -
#pragma mark TOUCH HANDLING
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSSet *allTouches = [event allTouches];
	
	if (1 == [allTouches count]) {
		[toolbarTouchDelegate footerTouched];
	}
}


#pragma mark -
#pragma mark HELPERS

- (void) moveMeHorizontalTo:(CGFloat)x {
	CGRect tempFrame = [self frame];
	tempFrame.origin.x = x;
	[self setFrame:tempFrame];
}


- (CGFloat) getXPosForState:(bool)visibility {
	if (visibility) {
		return -2.0;
	}
	
	if (!zurueckButton.hidden) {
		return -280.0;
	}
	return -400.0;
}


- (void)dealloc {
	[helpButton release];
	[naviHideButton release];
	[naviShowButton release];
	[zurueckButton release];
    [super dealloc];
}


@end

//
//  ThumbView.m
//  sansibar
//
//  Created by Heiko Bublitz on 08.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import "ThumbView.h"

@implementation ThumbView

@synthesize thumbDelegate;

- (id)initWithPageNumber:(int)page state:(int)state {
	
	pageNumber = page;
	displayMode = state;
	
	labelOpacityDefault = 0.4;
	labelOpacityActive = 1.0;
	
	CGRect rect = [self getFrame];
	[self setUserInteractionEnabled:YES];
	
	return [self initWithFrame:rect];
}



- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
        //// INIT BACKGROUND:
		[self initBgImage];
		[self addSubview:bgImage];
		[bgImage release];
		
		//// INIT THUMBNAIL
		[self initThumbImage];
		[thumb setFrame:CGRectMake(32, 6, [thumb frame].size.width, [thumb frame].size.height)];
		[self addSubview:thumb];
		[thumb release];
		
		//// INIT PAGE NUMBER
		number = [[UILabel alloc] initWithFrame:CGRectMake(410, 75, 60, 50)];
		[number setText: [NSString stringWithFormat:@"%d", pageNumber]];
		[number setFont:[UIFont fontWithName:@"Georgia" size:24]];
		[number setTextColor: [UIColor blackColor]];
		[number setBackgroundColor:[UIColor clearColor]];
		[number setAlpha:labelOpacityDefault];
		[self addSubview:number];
		[number release];
		
		//// INIT TITLE TEXT:
		titleText = [[UILabel alloc]initWithFrame:CGRectMake(150, 20, 225, 125)];
		[titleText setBackgroundColor:[UIColor clearColor]];
		//	[titleText setFont:[UIFont fontWithName:@"Times New Roman" size:24]];
		[titleText setFont:[UIFont fontWithName:@"Georgia" size:20]];
		[titleText setLineBreakMode:UILineBreakModeWordWrap];
		[titleText setNumberOfLines:3];
		[self addSubview:titleText];
		[titleText release];
    }
    return self;
}


- (void) setTitleText:(NSString *)text {
	titleText.text = text;
}


- (void) setThumbVisibility {
	if (displayMode == NAVI_ITEM_MODE_ACTIVE) {
		[thumb setHidden:YES];
	}
	else {
		[thumb setHidden:NO];
	}
}


- (void) setLabelsPlacement {
	CGRect numberFrame = CGRectMake(410, 75, 60, 50);
	CGRect titleFrame = CGRectMake(150, 20, 225, 125);
	
	if (displayMode == NAVI_ITEM_MODE_ACTIVE) {
		numberFrame.origin.y = 10;
		[number setAlpha:labelOpacityActive];
		titleFrame.origin = CGPointMake(32, 7);
		titleFrame.size = CGSizeMake(340, 60);
		[titleText setLineBreakMode:UILineBreakModeTailTruncation];
		[titleText setNumberOfLines:1];
	}
	else {
		[titleText setLineBreakMode:UILineBreakModeWordWrap];
		[titleText setNumberOfLines:3];
		[number setAlpha:labelOpacityDefault];
	}
	
	[number setFrame:numberFrame];
	[titleText setFrame:titleFrame];
}


- (CGRect) getFrame {
	CGFloat height = 138.0;
	if (displayMode == NAVI_ITEM_MODE_ACTIVE) {
		height = 69.0;
	}
	return CGRectMake(0, 0, 463.0, height);
}


- (CGFloat)placeItemAtYOffset:(CGFloat)yPos {
	CGRect myFrame = [self frame];
	CGSize s = myFrame.size;
	CGPoint o = myFrame.origin;
	CGFloat myBottom = yPos + s.height;
	
	// NSLog(@"beweg Dich nach Y %.0f", yPos);
	
	o.y = yPos;
	myFrame.origin = o;
	[self setFrame:myFrame];
	return myBottom;
}


- (void) initThumbImage {
	NSString *filename = [NSString stringWithFormat:FILENAME_PATTERN_THUMB, pageNumber];
	thumb = [[UIImageView alloc]initWithImage: [UIImage imageNamed:filename]];
	// [filename release];
}


- (void) initBgImage {
	if (displayMode == NAVI_ITEM_MODE_ACTIVE) {
		bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"navBgItemActive.png"]];
	}
	else if (displayMode == NAVI_ITEM_MODE_TOUCHED) {
		bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"navBgItemTouched.png"]];
	}
	else {
		bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"navBgItem.png"]];
	}
}


+ (bool) imageExistsForPage:(int)page {
	
	bool rc;
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *resourcePath = [mainBundle resourcePath];
	NSString *filename = [NSString stringWithFormat:FILENAME_PATTERN_THUMB, page];
	filename = [resourcePath stringByAppendingPathComponent: filename];
	//NSLog(@"RES-Pfad: %@", filename);
	
	rc = ([[NSFileManager defaultManager] fileExistsAtPath:filename]);
	// [mainBundle release];
	return rc;
}


- (void) setDisplayMode:(int)mode {
		
	displayMode = mode;
	
	if (mode == NAVI_ITEM_MODE_ACTIVE) {
		[bgImage setImage:[UIImage imageNamed:@"navBgItemActive.png"]];
		[titleText setTextColor:[UIColor whiteColor]];
		[number setTextColor:[UIColor whiteColor]];
	}
	else if (mode == NAVI_ITEM_MODE_TOUCHED) {
		[bgImage setImage:[UIImage imageNamed:@"navBgItemTouched.png"]];
		[thumb setHidden:NO];
		[titleText setTextColor:[UIColor whiteColor]];
		[number setTextColor:[UIColor whiteColor]];
	}
	else { // NAVI_ITEM_MODE_DEFAULT
		[bgImage setImage:[UIImage imageNamed:@"navBgItem.png"]];
		[thumb setHidden:NO];
		[titleText setTextColor:[UIColor blackColor]];
		[number setTextColor:[UIColor blackColor]];
	}
	
	[self setThumbVisibility];
	[self setLabelsPlacement];
	
	CGRect tmpFrame = [self getFrame];
	[bgImage setFrame:tmpFrame];
	
	tmpFrame.origin.y = [self frame].origin.y;
	[self setFrame:tmpFrame];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSSet *allTouches = [event allTouches];

	if (1 == [allTouches count]) {
		// [self setDisplayMode:NAVI_ITEM_MODE_TOUCHED];
		[thumbDelegate thumbClickedWithPageNumber:pageNumber];
	}
}


- (void)dealloc {
	[number release];
	[thumb release];
	[titleText release];
	[bgImage release];
    [super dealloc];
}


@end

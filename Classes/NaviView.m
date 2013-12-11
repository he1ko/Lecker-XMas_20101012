//
//  NaviView.m
//  sansibar
//
//  Created by Heiko Bublitz on 07.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import "NaviView.h"


@implementation NaviView

@synthesize naviDelegate;
@synthesize currentlyActiveItemId;
@synthesize touchedItemId;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
		[self loadPageTitles];
		
        // Initialization code
		self.userInteractionEnabled = YES;
		
		//// Shadow first (virtually send it to bottom)
		naviShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi-shadow.png"]];
		[naviShadow setFrame:CGRectMake(435, 0, 77, 1024)];
		[self addSubview:naviShadow];
		[naviShadow release];
		
		//// INIT SCROLLVIEW
		scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 67, 463, 715)];
		[scroll setBackgroundColor:[UIColor darkGrayColor]];
		scroll.userInteractionEnabled = YES;
		scroll.scrollEnabled = YES;
		scroll.showsVerticalScrollIndicator = NO;
		scroll.showsHorizontalScrollIndicator = NO;
		[self addSubview:scroll];
		[scroll release];
		
		//// INIT HEADER 
		header = [[NaviHeader alloc]initWithFrame:CGRectMake(0, 0, 463, 87)];
		[header setMyNaviParent: self];
		[self addSubview:header];
		[header release];
		
		//// A SEPERATOR BETWEEN NAVI AND CONTENT:
		pageBorder = [[UIImageView alloc]initWithFrame:CGRectMake(453, 0, 10, 1024)];
		[pageBorder setImage:[UIImage imageNamed:@"pageEdge.png"]];
		[self addSubview:pageBorder];
		[pageBorder release];
    }
    return self;
}


- (void) initItems {
	
	CGFloat yOffset = 1;
	int max = TOTAL_NUMBER_OF_PAGES;
	int displayMode = NAVI_ITEM_MODE_ACTIVE;
	ThumbView *tmpThumb;
	
	for (int i=1; i <= max; i++) {
		if ([ThumbView imageExistsForPage:i]) {
			
			NSString *key = [NSString stringWithFormat:@"title%d", i];
			NSString *title = [pageTitles objectForKey:key];
			
			tmpThumb = [[ThumbView alloc]initWithPageNumber:i state:NAVI_ITEM_MODE_DEFAULT];
			[tmpThumb setDisplayMode:displayMode];
			[tmpThumb setThumbDelegate:self];
			[tmpThumb setTitleText:title];
			[tmpThumb setTag:i];
			yOffset = [tmpThumb placeItemAtYOffset:yOffset] +1;
			
			[scroll setContentSize:CGSizeMake(463, yOffset)];
			[scroll addSubview:tmpThumb];
			[navItems addObject:tmpThumb];
			
			[tmpThumb release];
			
			// mode for items 2-n:
			displayMode = NAVI_ITEM_MODE_DEFAULT;
		}
	}
	
	[self setCurrentlyActiveItemId:1];
	[self setItemDisplayMode:NAVI_ITEM_MODE_ACTIVE forItemWithTag:currentlyActiveItemId];
	
	// Notify RootViewController:
	[naviDelegate naviFinishedLoading];
	
}


- (void) setScrollHeight:(CGFloat)height {
	CGRect tempFrame = [scroll frame];
	tempFrame.size.height = height;
	[scroll setFrame:tempFrame];
}


- (void) showShadow:(bool)show {
	[naviShadow setHidden:!show];
}


- (void) rearrangeItemAfterChangeFromId:(int)prevActive toId:(int)currentActive {
	
	int firstItem = prevActive;
	int lastItem = currentActive;
	if (firstItem > lastItem) {
		firstItem = currentActive;
		lastItem = prevActive;
	}
	
	CGFloat yOffset = [(ThumbView *)[self viewWithTag:firstItem] frame].origin.y;
	
	for (int i=firstItem; i<=lastItem; i++) {
		if ([ThumbView imageExistsForPage:i]) {
			yOffset = [(ThumbView *)[self viewWithTag:i] placeItemAtYOffset:yOffset] +1;
		}
	}
	
}


-(void) loadPageTitles {
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *resourcePath = [mainBundle resourcePath];
	NSString *filePath = [resourcePath stringByAppendingPathComponent: @"pageTitles.plist"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		pageTitles = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
	}
	// [mainBundle release];
}


- (void) resetActiveItem {
	[(ThumbView *)[self viewWithTag:currentlyActiveItemId] setDisplayMode:NAVI_ITEM_MODE_DEFAULT];
	if (touchedItemId == currentlyActiveItemId) {
		touchedItemId = -1;
	}
}


- (void) setItemDisplayMode:(int)mode forItemWithTag:(int)itemTag {
		
	[(ThumbView *)[self viewWithTag:itemTag] setDisplayMode:mode];
	if (mode == NAVI_ITEM_MODE_ACTIVE) {
		int prevActive = currentlyActiveItemId;
		int newActive = itemTag;
		
		[self setCurrentlyActiveItemId:itemTag];
		[self rearrangeItemAfterChangeFromId:prevActive toId:newActive];
		[self scrollToItemWithId:itemTag];
	}
	else if (mode == NAVI_ITEM_MODE_TOUCHED) {
		[self setTouchedItemId:itemTag];
	}
}


- (void) scrollToItemWithId:(int)itemTag {
	
	CGFloat itemHeight = 138.0;
	CGFloat newY = [(ThumbView *)[self viewWithTag:itemTag] frame].origin.y;
	CGFloat maxScrollPos = [scroll contentSize].height - [scroll frame].size.height;
	
	if (newY > itemHeight) {
		newY -= itemHeight;
	}
	
	if (newY > maxScrollPos) {
		newY = maxScrollPos;
	}
	
	[scroll setContentOffset:CGPointMake(0, newY) animated:YES];
}


- (void)dealloc {
	[naviShadow release];
	[pageBorder release];
	[scroll release];
	[header release];
	[navItems release];
	[pageTitles release];
    [super dealloc];
}



#pragma mark Thumb Notifications

- (void) thumbClickedWithPageNumber:(int)page {
	if (page == touchedItemId || page == currentlyActiveItemId) {
		return;
	}
	[self setTouchedItemId:page];
	[self setItemDisplayMode:NAVI_ITEM_MODE_TOUCHED forItemWithTag:page];
	[naviDelegate naviItemClicked:page];
}


#pragma mark Header Touch Handling
- (void) headerTouched {
	// [self thumbClickedWithPageNumber:1];
	[self scrollToItemWithId:1];
}


#pragma mark Footer Touch Handling
- (void) footerTouched {
	int lastPage = TOTAL_NUMBER_OF_PAGES;
	[self scrollToItemWithId:lastPage];
}


@end

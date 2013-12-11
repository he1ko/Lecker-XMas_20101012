//
//  NaviView.h
//  sansibar
//
//  Created by Heiko Bublitz on 07.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbView.h"
#import "NaviHeader.h"
#import "Toolbar.h"


@protocol NaviNotifications

- (void) naviFinishedLoading;
- (void) naviItemClicked:(int)page;

@end



@interface NaviView : UIScrollView <thumbNotifications, headerTouchProtocol, ToolbarTouchProtocol> {

	UIScrollView *scroll;
	NaviHeader *header;
	UIView *pageNums;
	UIImageView *pageBorder;
	UIImageView *naviShadow;
	NSMutableArray *navItems;
	NSMutableDictionary* pageTitles;
	
	int touchedItemId;
	int currentlyActiveItemId;
	
	id <NaviNotifications> naviDelegate;
}


- (void) initItems;
- (void) loadPageTitles;
- (void) resetActiveItem;
- (void) setItemDisplayMode:(int)mode forItemWithTag:(int)itemTag;
- (void) scrollToItemWithId:(int)itemTag;
- (void) rearrangeItemAfterChangeFromId:(int)prevActive toId:(int)currentActive;
- (void) setScrollHeight:(CGFloat)height;
- (void) showShadow:(bool)show;

@property (nonatomic, assign) id <NaviNotifications> naviDelegate;
@property (nonatomic, assign) int currentlyActiveItemId;
@property (nonatomic, assign) int touchedItemId;

@end

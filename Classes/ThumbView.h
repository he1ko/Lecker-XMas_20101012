//
//  ThumbView.h
//  sansibar
//
//  Created by Heiko Bublitz on 08.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol thumbNotifications

- (void) thumbClickedWithPageNumber:(int)page;


@end



@interface ThumbView : UIView {

	int pageNumber;
	int displayMode;	// defined in defines.h
	
	CGFloat labelOpacityDefault;
	CGFloat labelOpacityActive;
	
	UIImageView *thumb;
	UIImageView *bgImage;
	UILabel *titleText;
	UILabel *number;
	
	id <thumbNotifications> thumbDelegate;
}


- (id)initWithPageNumber:(int)page state:(int)state;
- (void) initThumbImage;
- (void) setThumbVisibility;
- (void) setLabelsPlacement;
- (void) initBgImage;
- (CGFloat)placeItemAtYOffset:(CGFloat)yPos;
- (CGRect) getFrame;
- (void) setDisplayMode:(int)mode;
- (void) setTitleText:(NSString *)text;

+ (bool) imageExistsForPage:(int)page;

@property (nonatomic, assign) id <thumbNotifications> thumbDelegate;

@end

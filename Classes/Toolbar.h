//
//  ButtonPanel.h
//  sansibar
//
//  Created by Heiko Bublitz on 22.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import <UIKit/UIKit.h>


// Notify viewController about toolbar commands
@protocol ToolbarClickProtocol
- (void) helpButtonClicked;
- (void) naviHideButtonClicked;
- (void) naviShowButtonClicked;
- (void) zurueckButtonClicked;

@end


// Notify NAVI if toolbar body is touched
@protocol ToolbarTouchProtocol
- (void) footerTouched;
@end



@interface Toolbar : UIImageView {
	
	id <ToolbarClickProtocol> toolbarDelegate;
	id <ToolbarTouchProtocol> toolbarTouchDelegate;
	bool visible;
	
	UIButton *helpButton;
	UIButton *naviHideButton;
	UIButton *naviShowButton;
	UIButton *zurueckButton;
	
}

- (void) updateButtonStates;
- (void) showZurueckButton:(bool)show;
- (void) moveMeHorizontalTo:(CGFloat)x;
- (CGFloat) getXPosForState:(bool)visibility;

@property (nonatomic, assign) id <ToolbarClickProtocol> toolbarDelegate;
@property (nonatomic, assign) id <ToolbarTouchProtocol> toolbarTouchDelegate;
@property (nonatomic, assign) bool visible;

@end

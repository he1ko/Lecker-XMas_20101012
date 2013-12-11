//
//  InfoView.h
//  LeckerXMas
//
//  Created by Heiko Bublitz on 22.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoViewNotifications

- (void) closeRequested;

@end



@interface InfoView : UIView {
	
	bool showUpOnStartup;
	UIImageView *panelBg;
	UILabel *fliesstext;
	UILabel *switchLabel;
	UISwitch *showSwitch;
	UIButton *closeButton;
	
	id <InfoViewNotifications> infoViewDelegate;
	
	bool startUpFlagAlreadyPresent;
}

- (bool)shouldShowUpOnStartup;
- (void)setShowUpOnStartup:(bool)show;
- (void)showStartupCheckBox:(bool)show;
- (void)switchAction:(id)sender;
- (void) initStartupFlagFromPropertyFile;
- (void) writeStartupFlagToPropertyFile:(bool)startupFlag;
- (void) closeButtonClicked;
- (void) placeObjectInPanel:(UIView *)obj withOffset:(CGPoint)offset;

@property (nonatomic, assign) id <InfoViewNotifications> infoViewDelegate;
@property (nonatomic, assign) bool startUpFlagAlreadyPresent;

@end

//
//  Overlay.h
//  LeckerXMas
//
//  Created by adm.bublitz_mac on 04.10.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Overlay : UIView {

	int targetPageId;
	int parentPageId;
	CGRect initialFrame;
	
	UIButton * b;
}

- (void) fadeOut:(CGFloat)seconds;

@property (nonatomic, assign) int parentPageId;
@property (nonatomic, assign) int targetPageId;
@property (nonatomic, assign) CGRect initialFrame;

@end

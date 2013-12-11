//
//  NaviFooter.h
//  LeckerXMas
//
//  Created by adm.bublitz_mac on 04.10.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol footerTouchProtocol

- (void) footerTouched;

@end



@interface NaviFooter : UIView {

	id<footerTouchProtocol> myNaviParent;
}

@property (nonatomic, assign) id<footerTouchProtocol> myNaviParent;


@end
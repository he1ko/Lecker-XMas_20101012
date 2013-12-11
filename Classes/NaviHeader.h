//
//  NaviHeader.h
//  LeckerXMas
//
//  Created by adm.bublitz_mac on 04.10.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol headerTouchProtocol

- (void) headerTouched;

@end


@interface NaviHeader : UIView {

	id<headerTouchProtocol> myNaviParent;
}

@property (nonatomic, assign) id<headerTouchProtocol> myNaviParent;


@end

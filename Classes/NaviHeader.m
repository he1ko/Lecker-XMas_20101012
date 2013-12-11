//
//  NaviHeader.m
//  LeckerXMas
//
//  Created by adm.bublitz_mac on 04.10.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import "NaviHeader.h"


@implementation NaviHeader

@synthesize myNaviParent;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self addSubview:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"header-medium-snow.png"]]];
    }
    return self;
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSSet *allTouches = [event allTouches];
	
	if (1 == [allTouches count]) {
		[myNaviParent headerTouched];
	}
}


- (void)dealloc {
    [super dealloc];
}


@end

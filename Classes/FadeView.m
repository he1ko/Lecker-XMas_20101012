
#import "FadeView.h"
#import "RootVC.h"

@implementation FadeView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splashScreen.png"]];
		
		CGRect newFrame = [imageView frame];
		[self setFrame:newFrame];
		[self addSubview:imageView];
    }
    return self;
}


- (void)dealloc {
	[imageView release];
    [super dealloc];
}


@end
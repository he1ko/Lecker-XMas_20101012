//
//  InfoView.m
//  sansibar
//
//  Created by Heiko Bublitz on 22.07.10.
//  Copyright 2010 com.bauermedia. All rights reserved.
//

#import "InfoView.h"
#import "RootVC.h"

@implementation InfoView

@synthesize infoViewDelegate;
@synthesize startUpFlagAlreadyPresent;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
		// determine, if this view should show up at all
		[self initStartupFlagFromPropertyFile];
		
		// Semi transparent fulscreen overlay
		UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[bg setBackgroundColor:[UIColor blackColor]];
		[bg setAlpha:0.7];
		[self addSubview:bg];
		
		// coloured background of the content panel
		panelBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"infoBg3.png"]];
		[panelBg setCenter:[bg center]];
		[self addSubview:panelBg];
		[panelBg release];
		
		// add the text Label
		fliesstext = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
		[self placeObjectInPanel:fliesstext withOffset:CGPointMake(60, 20)];
		[fliesstext setBackgroundColor:[UIColor clearColor]];
		[fliesstext setText:kInfoText];
		[fliesstext setFont:[UIFont fontWithName:@"Arial" size:22]];
		[fliesstext setLineBreakMode:UILineBreakModeWordWrap];
		[fliesstext setNumberOfLines:20];
		[self addSubview:fliesstext];
		[fliesstext release];
		
		// add a label in front of the switch		
		switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 350, 27)];
		[self placeObjectInPanel:switchLabel withOffset:CGPointMake(80, 650)];
		[switchLabel setBackgroundColor:[UIColor clearColor]];
		[switchLabel setTextColor:[UIColor whiteColor]];
		[switchLabel setText:@"Hilfe beim nächsten Start wieder anzeigen?"];
		[self addSubview:switchLabel];
		[switchLabel release];
		
		showSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
		[self placeObjectInPanel:showSwitch withOffset:CGPointMake(430, 650)];
		[showSwitch setBackgroundColor:[UIColor clearColor]];
        [showSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
		[showSwitch setOn:showUpOnStartup animated:NO];
		[self addSubview:showSwitch];
		[showSwitch release];
		
		closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[closeButton setFrame:CGRectMake(0, 0, 200, 39)];
		[closeButton setCenter:[bg center]];
		[closeButton setFrame:[RootVC translateFrame:[closeButton frame] byVector:CGPointMake(0, 200 )]];
		[closeButton setTitle:@"Schließen" forState:UIControlStateNormal];
		[closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:closeButton];		
		
    }
    return self;
}


- (bool)shouldShowUpOnStartup {
	if (showUpOnStartup) {
		NSLog(@"popup anzeigen!");
	}
	else {
		NSLog(@"popup NICHT anzeigen!");
	}
	return showUpOnStartup;
}


- (void)setShowUpOnStartup:(bool)show {
	[self writeStartupFlagToPropertyFile:show];
	showUpOnStartup = show;
}


- (void) placeObjectInPanel:(UIView *)obj withOffset:(CGPoint)offset {
	offset.x += [panelBg frame].origin.x;
	offset.y += [panelBg frame].origin.y;
	[obj setFrame:[RootVC translateFrame:[obj frame] byVector:offset]];
}


- (void)showStartupCheckBox:(bool)show {
	
}


- (void)switchAction:(id)sender {
	int numericValue = [sender isOn];
	showUpOnStartup = (numericValue == 1);
	[self writeStartupFlagToPropertyFile:showUpOnStartup];
}


/**
 *	read the information if infoview should show up on startup from property file
 */
- (void) initStartupFlagFromPropertyFile {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *finalPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:PROPERTYFILE];
	
	int numericValue = 0;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:finalPath]) {
		
		startUpFlagAlreadyPresent = YES;
		
		NSDictionary *plistData =  [NSDictionary dictionaryWithContentsOfFile:finalPath];
		if([plistData objectForKey:PROP_SHOW_INFO_ON_STARTUP] != nil) {
			numericValue = [[plistData objectForKey:PROP_SHOW_INFO_ON_STARTUP] intValue];	
			showUpOnStartup = (numericValue == 1);
			// NSLog(@"read Startup Flag from File (%d)", numericValue);
		}
		else {
			// NSLog(@"no Startup property in file !");
		}
	}
	else {
		// NSLog(@"no property File!!");
		startUpFlagAlreadyPresent = NO;
		// First start? File does not exist:
		[self setShowUpOnStartup:NO];
	}
	
}


/**
 *	saves the information if infoview should show up on startup to property file
 */
- (void) writeStartupFlagToPropertyFile:(bool)startupFlag {
	
	int numericValue;
	
	if (startupFlag) {
		numericValue = 1;
	}
	else {
		numericValue = 0;
	}
	
	// NSLog(@"write Startup Flag to File (%d)", numericValue);
	
	//save to file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *finalPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:PROPERTYFILE];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:finalPath]){
		// file exists overwrite value:
		NSMutableDictionary *plistData = [NSMutableDictionary dictionaryWithContentsOfFile:finalPath];
		[plistData setValue:[NSNumber numberWithInt:numericValue] forKey:PROP_SHOW_INFO_ON_STARTUP];
		[plistData writeToFile:finalPath atomically:YES];
	}		
	else {
		// create file and key-value-entry:
		NSMutableDictionary *plistData = [NSMutableDictionary new];
		[plistData setValue:[NSNumber numberWithInt:numericValue] forKey:PROP_SHOW_INFO_ON_STARTUP];
		[plistData writeToFile:finalPath atomically:YES];
		[plistData release];
	}
}


- (void) closeButtonClicked {
	[infoViewDelegate closeRequested];
}


- (void)dealloc {
	[fliesstext release];
	[switchLabel release];
	[showSwitch release];
	[closeButton release];
	[panelBg release];
    [super dealloc];
}


@end

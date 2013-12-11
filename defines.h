

// title to be displayed in App
#define APP_TITLE @"Christmas Special"

// default background color:
// #define MAIN_BGCOLOR [UIColor colorWithRed:0.18 green:0.22 blue:0.25 alpha:1.0]
#define MAIN_BGCOLOR [UIColor lightGrayColor]

// the corporate colors:
#define CORPORATE_COLOR_1 [UIColor colorWithRed:0.337 green:0.749 blue:0.8 alpha:1.0]

// filename pattern of page images
#define FILENAME_PATTERN_PAGE @"%d.jpg"

// filename pattern of page thumbnails
#define FILENAME_PATTERN_THUMB @"thm%d.jpg"

	// how many pagees are present?
#define TOTAL_NUMBER_OF_PAGES 98

// the (reference) size of an original image:
#define UNSCALED_IMAGES_WIDTH 1152
#define UNSCALED_IMAGES_HEIGHT 1536


// where are user properties saved /read from?
#define PROPERTYFILE @"einstellungen.plist"
#define PROP_SHOW_INFO_ON_STARTUP @"showInfoOnStartup"
#define PROP_LAST_PAGE_NUMBER @"lastPageNumber"

// ANIMATION identifiers
#define ANI_PAGE_PAN_ANIMATED @"ani1"
#define ANI_PAGE_ZOOM_IN @"ani2"
#define ANI_PAGE_ZOOM_OUT @"ani3"
#define ANI_ROTATE @"ani4"
#define ANI_NAVI_SHOW @"ani5"
#define ANI_NAVI_HIDE @"ani6"
#define ANI_SPLASH_HIDE @"ani7"
#define ANI_INFO_FADE @"ani8"



// Navigation Item display modes
typedef enum {
	NAVI_ITEM_MODE_DEFAULT,
	NAVI_ITEM_MODE_TOUCHED,
	NAVI_ITEM_MODE_ACTIVE
} NAVI_ITEM_MODES;


#define kInfoText @"Navigation:\n\nZur nächsten bzw. vorigen Seite können Sie mit einer Wischbewegung blättern.\n\nIm Querformat erhalten Sie zur Navigation zusätzlich eine Leiste zum bequemen Blättern ... \n\n\n\nZoom:\n\nZum Herein- und Hinauszoomen tippen Sie zweimal kurz hintereinander auf die Heftseite."


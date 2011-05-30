//
//  Copyright 2011 Andrey Tarantsov. Distributed under the MIT license.
//

#import <UIKit/UIKit.h>
#include "wbcMenu.h"
#include "ofxGuiGlobals.h"

@interface DemoItemView : UIImageView {
	bool isCenterSet;
	CGPoint cent;
	
	NSString*	m_title;				// name that gets displayed
	
	NSString*	m_websiteURL;
	NSString*	m_imageURL;
	
	int _wbcDataDescrCount;
	
	wbcMenu* _Menu;
	ofxGuiGlobals*			_Globals;
}
@property(nonatomic, assign) NSString* _title;
@property(nonatomic, assign) NSString* websiteURL;
@property(nonatomic, assign) NSString* imageURL;
@property(nonatomic, assign) int wbcDataDescrCount;
@property(nonatomic, assign) wbcMenu* Menu;
@property(nonatomic, assign) ofxGuiGlobals* Globals;

-(void)handleTripleTap;
-(void)handleDoubleTap;
-(void)handleSingleTap;
@end

//
//  Copyright 2011 Andrey Tarantsov. Distributed under the MIT license.
//

#import <UIKit/UIKit.h>
#include "wbcMenu.h"

@interface DemoItemView : UIImageView {
	bool isCenterSet;
	bool _isSelected;
	CGPoint cent;
	
	NSString*	m_title;				// name that gets displayed
	
	NSString*	m_websiteURL;
	NSString*	m_imageURL;
	
	int _wbcDataDescrCount;
	
	wbcMenu* _Menu;
}

@property(nonatomic, assign) bool isSelected;
@property(nonatomic, assign) NSString* _title;
@property(nonatomic, assign) NSString* websiteURL;
@property(nonatomic, assign) NSString* imageURL;
@property(nonatomic, assign) int wbcDataDescrCount;

-(void)handleTripleTap;
-(void)handleDoubleTap;
-(void)handleSingleTap;

@end

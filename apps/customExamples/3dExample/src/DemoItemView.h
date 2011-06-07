//
//  Copyright 2011 Andrey Tarantsov. Distributed under the MIT license.
//

#import <UIKit/UIKit.h>
#include "wbcMenu.h"
#include "ofxGuiGlobals.h"

@interface DemoItemView : UIImageView {
	CGPoint cent;
	
	int _index;
	
	wbcMenu* _Menu;
	ofxGuiGlobals*			_Globals;
	
	int _heirarchy;
	//NSMutableArray* _elems;
}
//for heirarchy items
@property(nonatomic, assign) int heirarchy;
//@property(nonatomic, assign) NSMutableArray* elems;

//general items
@property(nonatomic, assign) int index;
@property(nonatomic, assign) wbcMenu* Menu;
@property(nonatomic, assign) ofxGuiGlobals* Globals;

- (id)initWithImage:(UIImage *)image withHeirarchy:(int)index;

//used for topHeirarchy Item
- (id)initWithNoImage;

-(void)handleTripleTap;
-(void)handleDoubleTap;
-(void)handleSingleTap;

-(void)insert:(UIImageView*)item;

@end

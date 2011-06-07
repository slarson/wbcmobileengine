//
//  
//

#import <QuartzCore/QuartzCore.h>  // for self.layer.smt

#import "DemoItemView.h"


@implementation DemoItemView

@synthesize Menu = _Menu;
@synthesize Globals = _Globals;
@synthesize index = _index;
@synthesize heirarchy = _heirarchy;
//@synthesize elems = _elems;

- (id)initWithImage:(UIImage *)image {
	if ((self = [super initWithImage:image])) {
        //self.layer.cornerRadius = 8;
        self.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        self.layer.borderWidth = 1.5;
        //self.layer.backgroundColor = [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] CGColor];
        self.opaque = NO;
				self.userInteractionEnabled = YES;
    }
		
		_heirarchy = -1;
		//_elems = [[NSMutableArray alloc] initWithCapacity:1];

		UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTripleTap)];
	
		[tripleTap setNumberOfTapsRequired:3];
		[self addGestureRecognizer:tripleTap];
		[tripleTap release];
	
		UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
	 
		[doubleTap setNumberOfTapsRequired:2];
		[doubleTap requireGestureRecognizerToFail:tripleTap];
		[self addGestureRecognizer:doubleTap];
		[doubleTap release];
	
		UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
	
		[singleTap setNumberOfTapsRequired:1]; // Unnecessary since it's the default
		[singleTap requireGestureRecognizerToFail:doubleTap];
		[self addGestureRecognizer:singleTap];
		[singleTap release];
	
    return self;
}

- (id)initWithImage:(UIImage *)image withHeirarchy:(int)index {
	if ((self = [super initWithImage:image])) {
		//self.layer.cornerRadius = 8;
		self.layer.borderColor = [[UIColor darkGrayColor] CGColor];
		self.layer.borderWidth = 1.5;
		//self.layer.backgroundColor = [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] CGColor];
		self.opaque = NO;
		self.userInteractionEnabled = YES;
	}
	
	_heirarchy = index;
	//_elems = [[NSMutableArray alloc] initWithCapacity:0];
	
	UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTripleTap)];
	
	[tripleTap setNumberOfTapsRequired:3];
	[self addGestureRecognizer:tripleTap];
	[tripleTap release];
	
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapHeir)];
	
	[doubleTap setNumberOfTapsRequired:2];
	[doubleTap requireGestureRecognizerToFail:tripleTap];
	[self addGestureRecognizer:doubleTap];
	[doubleTap release];
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
	
	[singleTap setNumberOfTapsRequired:1]; // Unnecessary since it's the default
	[singleTap requireGestureRecognizerToFail:doubleTap];
	[self addGestureRecognizer:singleTap];
	[singleTap release];
	
	
	return self;
}

- (id)initWithNoImage {
	self = [super init];
	_heirarchy = -1;
	//_elems = [[NSMutableArray alloc] initWithCapacity:0];
						 
	return self;
}

- (void)handleTripleTap {
}

- (void)handleDoubleTap {
	printf("handling doubleTap\n");
	if (!_Menu->mItems.at(self.index)->bIsSelected)
	{
		_Globals->mTap.play();
		_Menu->mItems.at(self.index)->bIsSelected = true;
		
		_Globals->mListener->handleGui(_Menu->mItems.at(self.index)->parameterID, 0, nil, 0);
	}
}

-(void)handleDoubleTapHeir {
	[_Menu->_arrayView removeAll];
	[_Menu->_arrayView insertList:self.heirarchy];
}

- (void)handleSingleTap {
}

- (void)insert:(UIImageView*) item {
	item.tag = [[_Menu->_arrayView.elems	objectAtIndex:self.heirarchy] count];
	[[_Menu->_arrayView.elems	objectAtIndex:self.heirarchy] addObject:item];
}

@end

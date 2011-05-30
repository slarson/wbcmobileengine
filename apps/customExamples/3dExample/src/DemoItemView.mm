//
//  Copyright 2011 Andrey Tarantsov. Distributed under the MIT license.
//

#import <QuartzCore/QuartzCore.h>  // for self.layer.smt

#import "DemoItemView.h"


@implementation DemoItemView

@synthesize _title = m_title;
@synthesize	imageURL= m_imageURL;
@synthesize websiteURL= m_websiteURL;
@synthesize wbcDataDescrCount = _wbcDataDescrCount;
@synthesize Menu = _Menu;
@synthesize Globals = _Globals;


- (id)initWithImage:(UIImage *)image {
	if ((self = [super initWithImage:image])) {
        //self.layer.cornerRadius = 8;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.layer.borderWidth = 2;
        //self.layer.backgroundColor = [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] CGColor];
        self.opaque = NO;
				self.userInteractionEnabled = YES;
    }
	
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
	
		isCenterSet = FALSE;
	
    return self;
}

- (void)handleTripleTap {
	printf("I have been triple tapped\n");	
}

- (void)handleDoubleTap {
	if (isCenterSet != TRUE)
	{
			//preserve original center for transformations
			cent = self.center;
			isCenterSet = TRUE;
	}

	if (!_Menu->mItems.at(self.tag)->bIsSelected)
	{
		_Globals->mTap.play();
		_Menu->mItems.at(self.tag)->bIsSelected = true;
		
		_Globals->mListener->handleGui(_Menu->mItems.at(self.tag)->parameterID, 0, nil, 0);
	}
}

- (void)handleSingleTap {
	printf("I have been single tapped\n");	
}

@end

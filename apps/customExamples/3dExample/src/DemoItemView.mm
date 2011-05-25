//
//  Copyright 2011 Andrey Tarantsov. Distributed under the MIT license.
//

#import <QuartzCore/QuartzCore.h>  // for self.layer.smt

#import "DemoItemView.h"


@implementation DemoItemView

@synthesize isSelected = _isSelected;
@synthesize _title = m_title;
@synthesize	imageURL= m_imageURL;
@synthesize websiteURL= m_websiteURL;
@synthesize wbcDataDescrCount = _wbcDataDescrCount;


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
		_isSelected = FALSE;
	
    return self;
}

- (void)handleTripleTap {
	printf("I have been triple tapped\n");	
}

- (void)handleDoubleTap {
	//[self animateWithDuration: 1.0 delay:0.1 options: UIViewAnimationCurveE
	if (isCenterSet != TRUE)
	{
			//preserve original center for transformations
			cent = self.center;
			isCenterSet = TRUE;
	}
	
	if (!_isSelected)
	{
		_isSelected = !_isSelected;
		[UIView animateWithDuration: 1.0 
													delay: 0.0
												options: UIViewAnimationTransitionCurlDown
										 animations:^{
												self.alpha = 0.5;
											  //self.transform = CGAffineTransformMakeScale(1.55, 1.55);
												self.center = CGPointMake(-512, 0);
									   }
										 completion:nil];
	}
	else 
	{
		_isSelected = !_isSelected;
		[UIView animateWithDuration: 1.0 
													delay: 0.0
												options: UIViewAnimationTransitionFlipFromLeft
										 animations:^{
											 self.alpha = 1.0;
											 self.center = CGPointMake(cent.x, cent.y);
											 //self.transform = CGAffineTransformMakeScale(.35, .35);
										}
										completion:nil];
	}
}

- (void)handleSingleTap {
	printf("I have been single tapped\n");	
}


@end

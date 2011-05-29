//
//  Copyright 2011 Andrey Tarantsov. Distributed under the MIT license.
//

#import "ATArrayView.h"
#import "DemoItemView.h"

@interface ATArrayView () <UIScrollViewDelegate>
- (void)setup;
- (void)configureItems:(BOOL)updateExisting;
- (void)configureItem:(UIView *)item forIndex:(NSInteger)index;
- (void)recycleItem:(UIView *)item;

@end



@implementation ATArrayView

@synthesize itemSize=_itemSize;
@synthesize contentInsets=_contentInsets;
@synthesize minimumColumnGap=_minimumColumnGap;
@synthesize scrollView=_scrollView;
@synthesize itemCount=_itemCount;
@synthesize preloadBuffer=_preloadBuffer;
@synthesize itemURLs = _itemURLs;

#pragma mark -
#pragma mark init/dealloc

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
	
		_itemCount = 0;
	
	
		_visibleItems = [[NSMutableSet alloc] init];
		_recycledItems = [[NSMutableSet alloc] init];
		_itemURLs = [[NSMutableArray alloc] initWithCapacity:0];
	
		[self setup];
		[self reloadData];
		[self hide:YES];
		[self interact:NO];
	
    return self;
}

/*- (void) awakeFromNib {
    [self setup];
}*/

/* Moving setup here, allows for ATArrayView to work with InterfaceBuilder since
awakeFromNib is called instead of initWithFrame */
-(void) setup {
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		_itemSize = CGSizeMake(130, 130);
	}
	else 
	{
		_itemSize = CGSizeMake(70, 70);
	}	
    _minimumColumnGap = 5;
    _preloadBuffer = 0;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = YES;
    _scrollView.delegate = self;
		_scrollView.scrollEnabled = YES;
		_scrollView.pagingEnabled = NO;
		_scrollView.directionalLockEnabled = YES;
		_scrollView.backgroundColor = [UIColor clearColor];
		_scrollView.opaque = NO;
    [self addSubview:_scrollView];
}

- (void)dealloc {
    [_scrollView release], _scrollView = nil;
    [super dealloc];
}

- (void) hide:(BOOL)shouldHide {
	for( DemoItemView* view in self.subviews )
	{
			if (shouldHide)
				[view setHidden:YES];
			else {
				[view setHidden:NO];
			}
	}
	
	if (shouldHide)
		[self setHidden:YES];
	else {
		[self setHidden:NO];
	}
}

- (void) interact:(BOOL)canInteract{
	for( DemoItemView* view in self.subviews )
	{
		if (canInteract)
			[view setUserInteractionEnabled:YES];
		else {
			[view setUserInteractionEnabled:NO];
		}
	}
	
	if (canInteract)
		[self setUserInteractionEnabled:YES];
	else {
		[self setUserInteractionEnabled:NO];
	}
}

- (void)insert:(NSString *)path {
	[_itemURLs addObject:path];
	
	[self reloadData];
}
#pragma mark -
#pragma mark Data

- (void)reloadData {
	_itemCount = [_itemURLs count];
	[self layoutSubviews];
	
    // recycle all items
	/*for (UIView *view in _visibleItems) {
        [self recycleItem:view];
    }
    [_visibleItems removeAllObjects];*/

    [self configureItems:NO];
}

#pragma mark -
#pragma mark Item Views

- (UIView *)viewForItemAtIndex:(NSUInteger)index {
    for (UIView *item in _visibleItems)
        if (item.tag == index)
            return item;
    return nil;
}

- (UIView *)viewForItemInArrayView:(NSInteger)index {
	//has this index been created before?
	DemoItemView *itemView = (DemoItemView *) [self dequeueReusableItem:index];
	
	//has not, need to create it
	if (itemView == nil) {
		UIImage* image;
		if (index < [_itemURLs count]) {
			NSString *str = [_itemURLs objectAtIndex:index];
						 
			image = [[UIImage alloc] initWithContentsOfFile:str];
			itemView = [[[DemoItemView alloc] initWithImage:image] autorelease];
			itemView.tag = index;
		}
	}
	
	return itemView;
}

- (UIView *)viewItemInArrayViewAtIndex:(NSInteger)index {
	for (UIView *item in _visibleItems)
	{
		if (item.tag == index)
			return item;
	}
	
	for (UIView *item in _recycledItems)
	{
		if (item.tag == index)
			return item;
	}
	
	return nil;
}
- (void)configureItems:(BOOL)reconfigure {
    // update content size if needed
    CGSize contentSize = CGSizeMake(self.bounds.size.width,
                                    _itemSize.height * _rowCount + _rowGap * (_rowCount - 1) + _effectiveInsets.top + _effectiveInsets.bottom);
    if (_scrollView.contentSize.width != contentSize.width || _scrollView.contentSize.height != contentSize.height) {
        _scrollView.contentSize = contentSize;
    }

    // calculate which items are visible
    int firstItem = [self firstVisibleItemIndex];
    int lastItem  = [self lastVisibleItemIndex];

    // recycle items that are no longer visible
    for (UIView *item in _visibleItems) {
        if (item.tag < firstItem || item.tag > lastItem) {
            [self recycleItem:item];
        }
    }
    [_visibleItems minusSet:_recycledItems];

    if (lastItem < 0)
        return;

    // add missing items
    for (int index = firstItem; index <= lastItem; index++) {
        UIView *item = [self viewForItemAtIndex:index];
			if (item == nil) {
				item = [self viewForItemInArrayView:index];

				[_scrollView addSubview:item];
				[_visibleItems addObject:item];
			} 
			else if (!reconfigure) {
				continue;
			}
			
			[self configureItem:item forIndex:index];
    }
}

- (void)configureItem:(UIView *)item forIndex:(NSInteger)index {
    //item.tag = index;
    item.frame = [self rectForItemAtIndex:index];
    [item setNeedsDisplay]; // just in case
}


#pragma mark -
#pragma mark Layouting

- (void)layoutSubviews {
    BOOL boundsChanged = !CGRectEqualToRect(_scrollView.frame, self.bounds);
    if (boundsChanged) {
        // Strangely enough, if we do this assignment every time without the above
        // check, bouncing will behave incorrectly.
        _scrollView.frame = self.bounds;
    }

    _colCount = floorf((self.bounds.size.width - _contentInsets.left - _contentInsets.right) / _itemSize.width);

    while (1) {
        _colGap = (self.bounds.size.width - _contentInsets.left - _contentInsets.right - _itemSize.width * _colCount) / (_colCount + 1);
        if (_colGap >= _minimumColumnGap)
            break;
        --_colCount;
    };

    _rowCount = (_itemCount + _colCount - 1) / _colCount;
    _rowGap = _colGap;

    _effectiveInsets = UIEdgeInsetsMake(_contentInsets.top + _rowGap,
                                        _contentInsets.left + _colGap,
                                        _contentInsets.bottom + _rowGap,
                                        _contentInsets.right + _colGap);

    [self configureItems:boundsChanged];
}

- (NSInteger)firstVisibleItemIndex {
    int firstRow = MAX(floorf((CGRectGetMinY(_scrollView.bounds) - _effectiveInsets.top) / (_itemSize.height + _rowGap)), 0);
    //return MIN( firstRow * _colCount, _itemCount - 1);
    //Formula changed to incorporate the 'preload' buffer functionality
    return MIN( MAX(0,firstRow - (_preloadBuffer)) * _colCount, _itemCount - 1);
}

- (NSInteger)lastVisibleItemIndex { 
    int lastRow = MIN( ceilf((CGRectGetMaxY(_scrollView.bounds) - _effectiveInsets.top) / (_itemSize.height + _rowGap)), _rowCount - 1);
    //return MIN((lastRow + 1) * _colCount - 1, _itemCount - 1);
    return MIN( (lastRow + (_preloadBuffer + 1)) * _colCount - 1, _itemCount - 1);
}

- (CGRect)rectForItemAtIndex:(NSUInteger)index {
    NSInteger row = index / _colCount;
    NSInteger col = index % _colCount;

    return CGRectMake(_effectiveInsets.left + (_itemSize.width  + _colGap) * col,
                      _effectiveInsets.top  + (_itemSize.height + _rowGap) * row,
                      _itemSize.width, _itemSize.height);
}


#pragma mark -
#pragma mark Recycling

// It's the caller's responsibility to remove this item from _visibleItems,
// since this method is often called while traversing _visibleItems array.
- (void)recycleItem:(UIView *)item {
    [_recycledItems addObject:item];
    [item removeFromSuperview];
}

- (UIView *)dequeueReusableItem:(NSInteger)index {
	for (UIView *item in _recycledItems) {
		if (item.tag == index)
			return item;
	}
	return nil;
	
    /*UIView *result = [_recycledItems anyObject];
    if (result) {
        [_recycledItems removeObject:[[result retain] autorelease]];
    }
    return result;*/
}


#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self configureItems:NO];
}

@end

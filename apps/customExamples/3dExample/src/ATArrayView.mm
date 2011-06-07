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
@synthesize elems = elems;

#pragma mark -
#pragma mark init/dealloc

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
	
		_itemCount = 0;
		//number of different sites we load from, eg. brain maps, ZF, CCDB
		numHeirarchy = 6;
		topHeirarchy = 0;
	
		_visibleItems = [[NSMutableSet alloc] init];
		_recycledItems = [[NSMutableSet alloc] init];
		_elems = [[NSMutableArray alloc] initWithCapacity:0];
	
		[self setup];
		[self hide:YES];
		[self interact:NO];
	
		UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight)];
	  [swipe setDirection:(UISwipeGestureRecognizerDirectionRight)];
		[self addGestureRecognizer:swipe];
		[swipe release];
		
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
	for (int i = 0; i < numHeirarchy; i++) {
		[_elems addObject:[[NSMutableArray alloc] initWithCapacity:0]];
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
	for( UIView* view in self.subviews )
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
	for( UIView* view in self.subviews )
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

//Should only ever be used by HeirarchyItemViews
/*- (void)insert:(NSString *)path {
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
	HeirarchyItemView *itemView = [[[HeirarchyItemView alloc] initWithImage:image] autorelease];
	itemView.tag = numHeirarchy++; 
	
	[_topHeirarchy.slides addObject:itemView];
	_currentHeirarchy = _topHeirarchy;
	
s
	[self reloadData];
}*/


//insert it into the top heirarchy
- (void)insert:(UIImageView*)item withHeirarchyVal:(int)index {
	DemoItemView* subItem = (DemoItemView*)item;
	subItem.tag = [[_elems objectAtIndex:index] count];
	[[_elems objectAtIndex:index]	addObject:subItem];
	
		//printf("Heirarchy %d list count is %d\n", index, [[_elems objectAtIndex:index] count]);
	
	if(index == 0)
	{
		[self recycleItem:subItem];
		[self reloadData:[[_elems objectAtIndex:index] count]];
	}
}

- (void)removeAll {
	[self clearAllVisible];
	[_recycledItems removeAllObjects];
}
- (void)clearAllVisible {
	for (UIView *view in _visibleItems) {
		[self recycleItem:view];
	}
	[_visibleItems removeAllObjects];
}

- (void)insertList:(int)index{
	[self removeAll];
	[_recycledItems addObjectsFromArray:[_elems objectAtIndex:index]];
	printf("inserting Heirarchy list %d into ATArrayView with visible count %d and recycled count %d\n", index,[_visibleItems count], [_recycledItems count]);
	[self reloadData:[_recycledItems count]];
}

#pragma mark -
#pragma mark Data

- (void)reloadData:(NSInteger)count{
	_itemCount = count;

	[self layoutSubviews];
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
	DemoItemView *itemView = (DemoItemView *) [self dequeueReusableItem:index];
	
	return itemView;
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
				item = (DemoItemView *)[self dequeueReusableItem:index];

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
}

#pragma mark -
#pragma mark Swipe recongition 
- (void)handleSwipeRight {
	printf("handling swipe\n");
	[self insertList:0];
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self configureItems:NO];
}


@end

//
//  Copyright 2011 Andrey Tarantsov. Distributed under the MIT license.
//

#import <Foundation/Foundation.h>

// A container that arranges its items in rows and columns similar to the
// thumbnails screen in Photos.app, the API is modeled after UITableView.
@interface ATArrayView : UIView {
    // subviews
    UIScrollView *_scrollView;

    UIEdgeInsets    _contentInsets;
    CGSize          _itemSize;
    CGFloat         _minimumColumnGap;
    int             _preloadBuffer;
	
    // state
    NSInteger       _itemCount;
    NSMutableSet   *_recycledItems;
    NSMutableSet   *_visibleItems;
		NSMutableArray	*_itemURLs;

    // geometry
    NSInteger       _colCount;
    NSInteger       _rowCount;
    CGFloat         _rowGap;
    CGFloat         _colGap;
    UIEdgeInsets    _effectiveInsets;
}

/* Depending on memory, I you can use the preload buffer to buffer additional rows that
should be rendered. This is useful if we are usign CATiledLayer as the layerClass of the
UIView that will be used in the grid because CATiledLayer drawRect happens in the background. Doing this will
prevent a previous reusable "grid" cell to not show the content of previous cell while we continue to render the new cell's content.
This allows for smoother scrolling and minimizing 'jerkyness' when loading network resources in cells at the tradeoff of memory.
 */
@property(nonatomic,assign) int preloadBuffer;

@property(nonatomic, assign) UIEdgeInsets contentInsets;

@property(nonatomic, assign) CGSize itemSize;

@property(nonatomic, assign) CGFloat minimumColumnGap;

@property(nonatomic, assign) NSInteger itemCount;

@property(nonatomic, readonly) UIScrollView *scrollView;

@property(nonatomic, readonly) NSInteger firstVisibleItemIndex;

@property(nonatomic, readonly) NSInteger lastVisibleItemIndex;

@property(nonatomic, assign)NSMutableArray* itemURLs;


- (void)hide:(BOOL)shouldHide;

- (void)interact:(BOOL)canInteract;

- (void)insert:(NSString *)path;

- (void)reloadData;  // must be called at least once to display something

- (UIView *)viewForItemAtIndex:(NSUInteger)index;  // nil if not loaded

- (UIView *)dequeueReusableItem;  // nil if none

- (CGRect)rectForItemAtIndex:(NSUInteger)index;

- (UIView *)viewForItemInArrayView:(NSInteger)index;



@end


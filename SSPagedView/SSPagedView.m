//
//  SSPagedView.m
//  SSPagedView
//
//  Created by Stevenson on 3/9/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSPagedView.h"

#define MINIMUM_ALPHA 0.3f
#define MINIMUM_SCALE 0.8f

@interface SSPagedView()

@property (nonatomic) UIScrollView *theScrollView;

@property (nonatomic) UIView *scrollViewWrapper;

@property (nonatomic) NSInteger currentPageIndex;

@property (nonatomic) BOOL shouldReload;

@property (nonatomic) NSMutableArray *reusableEntries;

@end

@implementation SSPagedView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.shouldReload) {
        if (self.delegate) {
            self.pageCount = [self.delegate numberOfPagesInView:self];
            [self.pageControl setNumberOfPages:self.pageCount];
            
            self.pageSize = [self.delegate sizeForPageInView:self];
        }
        
        [self.reusableEntries removeAllObjects];
        self.visibleEntries = NSMakeRange(0.f, 0.f);
        
        for (NSInteger i=0; i < [self.entries count]; i++) {
            [self removeEntryForIndex:i];
        }
        [self.entries removeAllObjects];
        
        for (NSInteger i=0; i <self.pageCount; i++) {
            [self.entries addObject:[NSNull null]];
        }
        
        self.theScrollView.frame = CGRectMake(0.f, 0.f, self.pageSize.width, self.pageSize.height);
        self.theScrollView.contentSize = CGSizeMake(self.pageSize.width * self.pageCount, self.pageSize.height);
        self.theScrollView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    
    [self setPageAtOffset:self.theScrollView.contentOffset];
    [self reloadVisibleEntries];
}

#pragma mark - setup methods
-(void)setup
{
    self.pageSize = self.bounds.size;
    self.pageCount = 0;
    self.currentPageIndex = 0;
    
    self.entries = [[NSMutableArray alloc] init];
    self.reusableEntries = [[NSMutableArray alloc] init];
    self.visibleEntries = NSMakeRange(0.f, 0.f);
    
    self.theScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.theScrollView.delegate = self;
    self.theScrollView.backgroundColor = [UIColor clearColor];
    self.theScrollView.pagingEnabled = YES;
    self.theScrollView.showsHorizontalScrollIndicator = NO;
    self.theScrollView.clipsToBounds = NO;
    
    self.scrollViewWrapper = [[UIView alloc] initWithFrame:self.bounds];
    [self.scrollViewWrapper setAutoresizesSubviews:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.scrollViewWrapper setBackgroundColor:[UIColor clearColor]];
    [self.scrollViewWrapper addSubview:self.theScrollView];
    [self addSubview:self.scrollViewWrapper];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tap];
    
    self.shouldReload = YES;
}

#pragma mark - Tap Recognizer
- (void)tapped:(UIGestureRecognizer*)sender
{
    CGPoint tappedPoint = [sender locationInView:_theScrollView];
    if (CGRectContainsPoint(_theScrollView.bounds, tappedPoint)) {
        NSInteger tappedIndex = _currentPageIndex;
        if (self.delegate) {
            [self.delegate pageView:self selectedPageAtIndex:tappedIndex];
        }
    }
    
}

#pragma mark - layout and entries
- (void)reload{
    self.shouldReload = YES;
    [self setNeedsLayout];
}

- (void)enqueueReusableEntry:(UIView*)entry
{
    [self.reusableEntries addObject:entry];
}

- (UIView *)dequeueReusableEntry
{
    if ([self.reusableEntries lastObject]) {
        UIView *entry = [self.reusableEntries lastObject];
        [self.reusableEntries removeLastObject];
        return entry;
    }
    return nil;
}

- (void)removeEntryForIndex:(NSInteger)index
{
    UIView *entry = [self.entries objectAtIndex:index];
    if (entry && [self.entries objectAtIndex:index] != [NSNull null]){
        entry.layer.transform = CATransform3DIdentity;
        [entry removeFromSuperview];
        [self enqueueReusableEntry:entry];
        [self.entries replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}

#pragma mark - paging
- (void)scrollToPage:(NSInteger)index {
    if (index < self.pageCount) {
        [self.theScrollView setContentOffset:CGPointMake(_pageSize.width * index, 0) animated:YES];
        [self setPageAtOffset:self.theScrollView.contentOffset];
        [self reloadVisibleEntries];
    }
}

- (void)setPageForIndex:(NSInteger)index
{
    if (index >= 0 && index < [self.entries count]) {
        UIView *entry = [self.entries objectAtIndex:index];
        if ((!entry || [self.entries objectAtIndex:index] == [NSNull null]) && self.delegate) {
            entry = [self.delegate pageView:self entryForPageAtIndex:index];
            [self.entries replaceObjectAtIndex:index withObject:entry];
            entry.frame = CGRectMake(self.pageSize.width*index, 0.f, self.pageSize.width, self.pageSize.height);
        }
        
        if (![entry superview]) {
            [self.theScrollView addSubview:entry];
        }
    }
}

- (void)reloadVisibleEntries
{
    CGFloat offset = self.theScrollView.contentOffset.x;
    NSInteger start = self.visibleEntries.location;
    NSInteger stop = self.visibleEntries.location+self.visibleEntries.length;
    for (NSInteger i = start; i<stop; i++) {
        UIView *entry = [self.entries objectAtIndex:i];
        CGFloat xOrigin = CGRectGetMinX(entry.frame);
        CGFloat change = (xOrigin >= offset) ? xOrigin-offset : offset-xOrigin;
        
        [UIView beginAnimations:@"movement" context:nil];
        if (change < self.pageSize.width) {
            entry.alpha = 1.f - (change/self.pageSize.width)*(1-MINIMUM_ALPHA);
            
            CGFloat scale = 1.f - (change/self.pageSize.width)*(1-MINIMUM_SCALE);
            entry.layer.transform = CATransform3DMakeScale(scale, scale, 1.f);
        } else {
            [entry setAlpha:MINIMUM_ALPHA];
            entry.layer.transform = CATransform3DMakeScale(MINIMUM_SCALE, MINIMUM_SCALE, 1.f);
        }
        [UIView commitAnimations];
    }
}

- (void)setPageAtOffset:(CGPoint)offset
{
    if ([self.entries count] > 0) {
        CGPoint start = CGPointMake(offset.x - CGRectGetMinX(self.theScrollView.frame), offset.y -CGRectGetMinY(self.theScrollView.frame));
        
        CGPoint end = CGPointMake(MAX(0, start.x) + CGRectGetWidth(self.bounds), MAX(0, start.y) + CGRectGetHeight(self.bounds));
        
        //find entry
        NSInteger startIndex = 0;
        for (NSInteger i =0; i < [self.entries count]; i++) {
            if (_pageSize.width * (i +1) > start.x) {
                startIndex = i;
                break;
            }
        }
        
        NSInteger endIndex = startIndex;
        for (NSInteger i = startIndex; i < [self.entries count]; i++) {
            
            if ((_pageSize.width * (i + 1) < end.x && _pageSize.width * (i + 2) >= end.x) || i+2 == [self.entries count]) {
                endIndex = i + 1;
                break;
            }
        }
        
        startIndex = MAX(startIndex - 1, 0);
        endIndex = MIN(endIndex + 1, [self.entries count] - 1);
        CGFloat pagedLength = endIndex - startIndex + 1;
        
        if (self.visibleEntries.location != startIndex || self.visibleEntries.length != pagedLength) {
            _visibleEntries.location = startIndex;
            _visibleEntries.length = pagedLength;
            
            for (NSInteger i = startIndex; i <= endIndex; i++) {
                [self setPageForIndex:i];
            }
            
            for (NSInteger i = 0; i < startIndex; i ++) {
                [self removeEntryForIndex:i];
            }
            
            for (NSInteger i = endIndex + 1; i < [self.entries count]; i ++) {
                [self removeEntryForIndex:i];
            }
        }
    }
}

#pragma mark - UISCrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setPageAtOffset:scrollView.contentOffset];
    [self reloadVisibleEntries];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = (int)self.theScrollView.contentOffset.x / _pageSize.width;
    if (self.pageControl) {
        [self.pageControl setCurrentPage:page];
    }
    
    if (self.delegate && self.currentPageIndex != page) {
        [self.delegate pageView:self didScrollToPageAtIndex:page];
    }
    
    self.currentPageIndex = page;
}

@end

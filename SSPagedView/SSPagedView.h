//
//  SSPagedView.h
//  SSPagedView
//
//  Created by Stevenson on 3/9/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSPagedViewDelegate;

@interface SSPagedView : UIView<UIScrollViewDelegate>

@property (unsafe_unretained) id<SSPagedViewDelegate> delegate;
@property (nonatomic) CGSize pageSize;
@property (nonatomic) NSInteger pageCount;
@property (nonatomic) NSMutableArray *entries;
@property (nonatomic) NSRange visibleEntries;
@property (nonatomic) UIPageControl *pageControl;

- (void)reload;

- (void)scrollToPage:(NSInteger)index;

- (UIView *)dequeueReusableEntry;

@end

@protocol SSPagedViewDelegate

- (CGSize)sizeForPageInView:(SSPagedView*)pagedView;

- (void)pageView:(SSPagedView*) pagedView didScrollToPageAtIndex:(NSInteger) index;

- (void)pageView:(SSPagedView*)pagedView selectedPageAtIndex:(NSInteger)index;

- (NSInteger)numberOfPagesInView:(SSPagedView*)pagedView;

- (UIView*)pageView:(SSPagedView*)pagedView entryForPageAtIndex:(NSInteger)index;

@end
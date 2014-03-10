//
//  ViewController.m
//  SSPagedView
//
//  Created by Stevenson on 3/9/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "ViewController.h"
#import "SSPagedView.h"
#import "UIColor+CatColors.h"

@interface ViewController () <SSPagedViewDelegate>
@property (weak, nonatomic) IBOutlet SSPagedView *pagedView;
@property (weak, nonatomic) IBOutlet UIPageControl *thePageControl;
@property (nonatomic) NSMutableArray *views;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.pagedView.delegate = self;
    self.pagedView.pageControl = self.thePageControl;
    self.views = [[NSMutableArray alloc] init];
    for (int i=0;i<10;i++) {
        UIView *thisView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 150.f)];
        [self.views addObject:thisView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions Page Control
- (IBAction)pageControlChanged:(id)sender {
    [self.pagedView scrollToPage:[(UIPageControl*)sender currentPage]];
}

#pragma mark - paged delegate methods
- (void)pageView:(SSPagedView *)pagedView didScrollToPageAtIndex:(NSInteger)index
{
    
}

- (UIView *)pageView:(SSPagedView *)pagedView entryForPageAtIndex:(NSInteger)index
{
    UIView *thisView = [pagedView dequeueReusableEntry];
    if (!thisView) {
        thisView = [self.views objectAtIndex:index];
        thisView.backgroundColor = [UIColor getRandomColor];
        thisView.layer.cornerRadius = 5;
        thisView.layer.masksToBounds = YES;
    }
    return thisView;
}

- (CGSize)sizeForPageInView:(SSPagedView *)pagedView
{
    return CGSizeMake(200, 150);
}

- (void)pageView:(SSPagedView *)pagedView selectedPageAtIndex:(NSInteger)index
{
    NSLog(@"%i",(int)index);
}

- (NSInteger)numberOfPagesInView:(SSPagedView *)pagedView
{
    return [self.views count];
}
@end

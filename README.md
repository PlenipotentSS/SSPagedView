SSPagedView
===========

paging ability through several views. Very similar to many apps using media such as Facbeook's scrolling on posts. 

####Implementation:

Single class making use of UIScrollViewDelegate on a UIView. The goal of this demo is to contain an array of views and populate a nice "peak" scroll view dynamically. 

Required delegate methods for SSPagedView:
```

- (CGSize)sizeForPageInView:(SSPagedView*)pagedView;

- (void)pageView:(SSPagedView*) pagedView didScrollToPageAtIndex:(NSInteger) index;

- (void)pageView:(SSPagedView*)pagedView selectedPageAtIndex:(NSInteger)index;

- (NSInteger)numberOfPagesInView:(SSPagedView*)pagedView;

- (UIView*)pageView:(SSPagedView*)pagedView entryForPageAtIndex:(NSInteger)index;

```
Then, just pull in the view via IBOutlets or programatically and customize with the following: ```UIPageControl```, ```MINIMUM_SCALE``` and ```MINIMUM_SIZE```.

Take a look at the demo project for more details!


|                       |                       |
|  -------------------  |  ------------------- |
| ![](screenshot1.png)  | ![](screenshot2.png)  |
|                       |                       |


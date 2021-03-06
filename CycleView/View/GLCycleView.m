//
//  GLCycleView.m
//  GLCycleView
//
//  Created by 温国良 on 2016/10/28.
//  Copyright © 2016年 温国良. All rights reserved.
//

#import "GLCycleView.h"
#import "GLCycleViewCell.h"

@interface GLCycleView ()

/*内容数量*/
@property (nonatomic, assign) NSUInteger contentCount;

@property (nonatomic, strong) GLCycleViewCell *leftCycleViewCell;
@property (nonatomic, strong) GLCycleViewCell *currentCycleViewCell;
@property (nonatomic, strong) GLCycleViewCell *rightCycleViewCell;

/**
 三个视图point
 */
@property (nonatomic, assign) CGPoint leftContentViewPoint;
@property (nonatomic, assign) CGPoint currentContentViewPoint;
@property (nonatomic, assign) CGPoint rightContentViewPoint;

/**
 视图点击手势
 */
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

/**
 视图滑动手势
 */
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation GLCycleView

#pragma mark - Super

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addGestureRecognizer:self.tapGesture];
        
        self.margin      = 10;
        self.isCanScroll = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - Self

- (void)reloadData
{
    [self reloadDataWithIndex:0];
}

- (void)reloadDataWithIndex:(NSUInteger)index
{
    self.contentCount = [self.dataSource cycleViewViewContentCount:self];
    
    if (!self.contentCount)
        return;
    
    self.leftCycleViewCell = [[GLCycleViewCell alloc] initWithFrame:CGRectMake(-(CGRectGetWidth(self.frame) + self.margin), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:self.leftCycleViewCell];
    
    self.currentCycleViewCell = [[GLCycleViewCell alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:self.currentCycleViewCell];
    
    self.rightCycleViewCell = [[GLCycleViewCell alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) + self.margin, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:self.rightCycleViewCell];
    
    self.currentCycleViewCell.index = 0;
    self.leftCycleViewCell.index = [self cellLastIndex:self.currentCycleViewCell.index];
    self.rightCycleViewCell.index = [self cellNextIndex:self.currentCycleViewCell.index];
    
    UIView *leftContentView = [self.dataSource cycleViewView:self contentViewWithIndex:self.leftCycleViewCell.index];
    [self.leftCycleViewCell addSubview:leftContentView];
    
    UIView *currentContentView = [self.dataSource cycleViewView:self contentViewWithIndex:self.currentCycleViewCell.index];
    [self.currentCycleViewCell addSubview:currentContentView];
    
    UIView *rightContentView = [self.dataSource cycleViewView:self contentViewWithIndex:self.rightCycleViewCell.index];
    [self.rightCycleViewCell addSubview:rightContentView];
    
    leftContentView.frame    = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    currentContentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    rightContentView.frame   = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    self.leftContentViewPoint    = self.leftCycleViewCell.layer.position;
    self.currentContentViewPoint = self.currentCycleViewCell.layer.position;
    self.rightContentViewPoint   = self.rightCycleViewCell.layer.position;
}

- (void)updateContentViewPointX:(CGFloat)pointX
{
    CGPoint movePoint = self.currentCycleViewCell.layer.position;
    movePoint.x = pointX + self.currentContentViewPoint.x;
    self.currentCycleViewCell.layer.position = movePoint;
    
    movePoint = self.leftCycleViewCell.layer.position;
    movePoint.x = pointX + self.leftContentViewPoint.x;
    self.leftCycleViewCell.layer.position = movePoint;
    
    movePoint = self.rightCycleViewCell.layer.position;
    movePoint.x = pointX + self.rightContentViewPoint.x;
    self.rightCycleViewCell.layer.position = movePoint;
}

- (void)contentViewStopScrollPointX:(CGPoint)point
{
    if (point.x < -CGRectGetWidth(self.frame) / 2.) {
        NSLog(@"向左滑动");
        
        GLCycleViewCell *tempView = self.leftCycleViewCell;
        
        self.leftCycleViewCell    = self.currentCycleViewCell;
        self.currentCycleViewCell = self.rightCycleViewCell;
        self.rightCycleViewCell   = tempView;
        
        CGPoint point = self.rightCycleViewCell.layer.position;
        point.x = self.currentCycleViewCell.layer.position.x + self.bounds.size.width - self.margin;
        self.rightCycleViewCell.layer.position = point;
        
        self.rightCycleViewCell.index = [self cellNextIndex:self.currentCycleViewCell.index];
        
        UIView *rightContentView = [self.dataSource cycleViewView:self contentViewWithIndex:self.rightCycleViewCell.index];
        [self.rightCycleViewCell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.rightCycleViewCell addSubview:rightContentView];
        
        rightContentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.leftCycleViewCell.frame), CGRectGetHeight(self.leftCycleViewCell.frame));
        
        [self anmiationContentView:self.leftCycleViewCell position:self.leftContentViewPoint];
        [self anmiationContentView:self.currentCycleViewCell position:self.currentContentViewPoint];
        [self anmiationContentView:self.rightCycleViewCell position:self.rightContentViewPoint];
    }
    else if (point.x > CGRectGetWidth(self.frame) / 2.) {
        NSLog(@"向右滑动");
        
        GLCycleViewCell *tempView = self.rightCycleViewCell;
        
        self.rightCycleViewCell   = self.currentCycleViewCell;
        self.currentCycleViewCell = self.leftCycleViewCell;
        self.leftCycleViewCell    = tempView;
        
        CGPoint point = self.leftCycleViewCell.layer.position;
        point.x = self.currentCycleViewCell.layer.position.x - self.bounds.size.width + _margin;
        self.leftCycleViewCell.layer.position = point;
        
        self.leftCycleViewCell.index = [self cellLastIndex:self.currentCycleViewCell.index];
        
        UIView *leftContentView = [self.dataSource cycleViewView:self contentViewWithIndex:self.leftCycleViewCell.index];
        [self.leftCycleViewCell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.leftCycleViewCell addSubview:leftContentView];
        
        leftContentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.leftCycleViewCell.frame), CGRectGetHeight(self.leftCycleViewCell.frame));
        
        [self anmiationContentView:self.leftCycleViewCell position:self.leftContentViewPoint];
        [self anmiationContentView:self.currentCycleViewCell position:self.currentContentViewPoint];
        [self anmiationContentView:self.rightCycleViewCell position:self.rightContentViewPoint];
    }
    else
    {
        NSLog(@"停留原处");
        
        [self anmiationContentView:self.leftCycleViewCell position:self.leftContentViewPoint];
        [self anmiationContentView:self.currentCycleViewCell position:self.currentContentViewPoint];
        [self anmiationContentView:self.rightCycleViewCell position:self.rightContentViewPoint];
    }
}

-(void)anmiationContentView:(UIView *)view position:(CGPoint)position
{
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [positionAnimation setFromValue:[NSValue valueWithCGPoint:view.layer.position]];
    [positionAnimation setToValue:[NSValue valueWithCGPoint:position]];
    
    CAAnimationGroup* group = [CAAnimationGroup animation];
    group.animations = @[positionAnimation];
    group.duration   = .3;
    [view.layer addAnimation:group forKey:nil];
    view.layer.position = position;
}

- (NSInteger)cellNextIndex:(NSInteger)index
{
    if (index == self.contentCount - 1)
        return 0;
    
    return index + 1;
}

- (NSInteger)cellLastIndex:(NSInteger)index
{
    if (index == 0)
        return self.contentCount - 1;
    
    return index - 1;
}

#pragma mark - UIGestureRecognizer

- (void)tapClickGesture:(UITapGestureRecognizer *)gesture
{
    NSLog(@"tapClickGesture index = %ld",self.currentCycleViewCell.index);
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture
{
    NSLog(@">>>>>>>>>>>> = %@",gesture.view);
    
    CGPoint point = [gesture translationInView:self];
    NSLog(@"++++++++++++ = %@",NSStringFromCGPoint(point));
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            [self updateContentViewPointX:point.x];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [self contentViewStopScrollPointX:point];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Set

- (void)setDataSource:(id<GLCycleViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self reloadData];
}

- (void)setIsCanScroll:(BOOL)isCanScroll
{
    if (_isCanScroll == isCanScroll) return;
    
    _isCanScroll = isCanScroll;
    
    if (isCanScroll)
        [self addGestureRecognizer:self.panGesture];
    else
        [self removeGestureRecognizer:self.panGesture];
}

#pragma mark - Get

- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClickGesture:)];
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    }
    return _panGesture;
}

@end

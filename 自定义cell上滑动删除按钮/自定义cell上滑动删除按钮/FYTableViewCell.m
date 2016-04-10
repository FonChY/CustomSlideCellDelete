//
//  FYTableViewCell.m
//  自定义cell上滑动删除按钮
//
//  Created by FonChY on 16/4/10.
//  Copyright © 2016年 ChinaPan. All rights reserved.
//

#import "FYTableViewCell.h"
#import "PureLayout.h"
static CGFloat const kBounceValue = 20.0f;
@interface FYTableViewCell ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIButton *btn1;
@property (nonatomic, strong) UIButton *btn2;
@property (nonatomic, strong) UIView *myContentView;


@end
@implementation FYTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        
        
        UIButton *btn1 = [[UIButton alloc] init];
        [btn1 setTitle:@"btn1" forState:UIControlStateNormal];
        btn1.backgroundColor = [UIColor redColor];
        self.btn1 = btn1;
        [self.btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btn1];
        UIButton *btn2 = [[UIButton alloc] init];
        btn2.backgroundColor = [UIColor blueColor];
        [btn2 setTitle:@"btn2" forState:UIControlStateNormal];
        self.btn2 = btn2;
        [self.btn2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btn2];
        
        UIView *myContentView = [[UIView alloc] init];
        myContentView.backgroundColor = [UIColor whiteColor];
        self.myContentView = myContentView;
        
        [self.contentView addSubview:myContentView];
        
        self.myTextLabel = [[UILabel alloc]init];
        [self.myContentView addSubview:self.myTextLabel];
        
        
        
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
        self.panRecognizer.delegate = self;
        [self.myContentView addGestureRecognizer:self.panRecognizer];
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.btn1 autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.contentView];
    [self.btn1 autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView];
#warning 自定义选项键的大小,不要设置为与cell等高,一是如果要是这样就没必要自己重写了,二是在滑动的时候会显示一点点
    [self.btn1 autoSetDimension:ALDimensionWidth toSize:40];
    
    [self.btn1 autoSetDimension:ALDimensionHeight toSize:30];
    
    [self.btn2 autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.contentView];
    [self.btn2 autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.btn1];
    [self.btn2 autoSetDimension:ALDimensionWidth toSize:40];
    
    [self.btn2 autoSetDimension:ALDimensionHeight toSize:30];
    
    
    [self.myContentView autoConstrainAttribute:ALAttributeWidth toAttribute:ALAttributeWidth ofView:self.contentView];
    
    self.contentViewLeftConstraint = [self.myContentView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView withOffset:0];
    [self.myContentView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView];
    [self.myContentView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView];
    
    
    [self.myTextLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.myContentView];
    [self.myTextLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.contentView];
    
    [self layoutIfNeeded];
}
//恢复原来的状态
- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)notifyDelegate
{
    if (notifyDelegate) {
        [self.delegate cellDidClose:self];
    }
    //判断一下当前的状态
    if (self.startingLeftLayoutConstraintConstant == [self buttonTotalWidth]||self.startingLeftLayoutConstraintConstant == 0) {
        return;
    }
    
    self.contentViewLeftConstraint.constant = kBounceValue;
    //更新约束
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        
        self.contentViewLeftConstraint.constant = 0;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingLeftLayoutConstraintConstant = self.contentViewLeftConstraint.constant;
        }];
    }];
}

//设置移动之后的约束
- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
    if (notifyDelegate) {
        [self.delegate cellDidOpen:self];
    }
    
    //1
    if (self.startingLeftLayoutConstraintConstant == -[self buttonTotalWidth]) {
        return;
    }
    //2
    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
    
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        //3
        self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
        
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            //4
            self.startingLeftLayoutConstraintConstant = self.contentViewLeftConstraint.constant;
        }];
    }];
}
//给label赋值
- (void)setItemText:(NSString *)itemText {
    //Update the instance variable
    _itemText = itemText;
    
    //Set the text to the custom label.
    self.myTextLabel.text = _itemText;
}
//获取两个按钮的宽度
- (CGFloat)buttonTotalWidth {
    return CGRectGetWidth(self.contentView.frame) - CGRectGetMinX(self.btn2.frame);
}
//点击手势
- (void)panThisCell:(UIPanGestureRecognizer *)recognizer {
    
    
    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan:
            //获取开始点击的位置
            self.panStartPoint = [recognizer translationInView:self.myContentView];
            //记录左边的约束
            self.startingLeftLayoutConstraintConstant = self.contentViewLeftConstraint.constant;
            break;
            
            
        case UIGestureRecognizerStateChanged: {
            //获取手指的位置
            CGPoint currentPoint = [recognizer translationInView:self.myContentView];
            //手指移动了多少
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {  //1
                panningLeft = YES;
            }
            //cell还没动的时候
            if (self.startingLeftLayoutConstraintConstant == 0) { //2
                
                if (!panningLeft) {
                    //此时不允许往右移动
                    self.contentViewLeftConstraint.constant = 0;
                    
                }else{
                    CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]);
                    
                    if (constant == [self buttonTotalWidth]) {
                        //设置移动之后的约束
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    }else{
                        
                        //判断一下何时移动完成
                        if (constant > [self buttonTotalWidth] * 0.5) {
                            
                            
                            self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
                            [UIView animateWithDuration:0.25 animations:^{
                                [self.myContentView layoutIfNeeded];
                            }];
                            
                        }else {
                            
                            self.contentViewLeftConstraint.constant = deltaX;
                            
                        }
                        
                    }
                    
                    
                }
            }else{//cell已经被移动了
                if (panningLeft) {
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                }else{
                    CGFloat constant = MIN(deltaX, [self buttonTotalWidth]);
                    if (constant == [self buttonTotalWidth]) {
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                        
                    }else{//往右移动
                        
                        self.contentViewLeftConstraint.constant = -[self buttonTotalWidth]+deltaX;
                        
                    }
                }
            }
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            
            if (self.startingLeftLayoutConstraintConstant != 0) { //1
                
                //We were closing
                CGFloat buttonOnePlusHalfOfButton2 = CGRectGetWidth(self.btn1.frame) + (CGRectGetWidth(self.btn2.frame) / 2); //4
                if (self.contentViewLeftConstraint.constant >= buttonOnePlusHalfOfButton2) { //5
                    //Re-open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
                
            }else{
                CGFloat halfOfButtonOne = CGRectGetWidth(self.btn1.frame) ; //2
                if (-self.contentViewLeftConstraint.constant >= halfOfButtonOne) { //3
                    //Open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Re-close
                    [self updateConstraintsIfNeeded:YES completion:^(BOOL finished) {
                        
                        self.contentViewLeftConstraint.constant = 0;
                        
                        [self updateConstraintsIfNeeded:YES completion:^(BOOL finished) {
                            self.startingLeftLayoutConstraintConstant = self.contentViewLeftConstraint.constant;
                        }];
                    }];
                }
            }
            
            
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        default:
            break;
    }
    
    
}
//更新约束时的动画
- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.25;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}
//首先，你的 UIPanGestureRecognizer 有时候会影响 UITableView 的 Scroll 操作。由于你已经设置了 Cell 的 Pan 手势识别器 的 UIGestureRecognizerDelegate ，你只需要实现一个（有些滑稽且冗长命名的） delegate 方法即可将一切恢复正常。
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)btnClick:(UIButton *)btn{
    if (btn == self.btn1) {
        [self.delegate buttonOneActionForItemText:self.itemText];
    } else if (btn == self.btn2) {
        [self.delegate buttonTwoActionForItemText:self.itemText];
    } else {
        NSLog(@"Clicked unknown button!");
    }
    
}
- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
}
- (void)openCell {
    [self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
}

@end

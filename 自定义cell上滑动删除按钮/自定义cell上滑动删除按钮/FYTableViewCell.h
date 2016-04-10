//
//  FYTableViewCell.h
//  自定义cell上滑动删除按钮
//
//  Created by FonChY on 16/4/10.
//  Copyright © 2016年 ChinaPan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SwipeableCellDelegate <NSObject>
- (void)buttonOneActionForItemText:(NSString *)itemText;
- (void)buttonTwoActionForItemText:(NSString *)itemText;
- (void)cellDidOpen:(UITableViewCell *)cell;
- (void)cellDidClose:(UITableViewCell *)cell;
@end
@interface FYTableViewCell : UITableViewCell
@property (nonatomic, weak) id <SwipeableCellDelegate> delegate;
@property (nonatomic, strong) NSString *itemText;
@property (nonatomic, strong) UILabel *myTextLabel;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingLeftLayoutConstraintConstant;

@property (nonatomic, weak) NSLayoutConstraint *contentViewLeftConstraint;
- (void)openCell;
@end

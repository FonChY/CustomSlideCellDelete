//
//  FYTableViewController.m
//  自定义cell上滑动删除按钮
//
//  Created by FonChY on 16/4/10.
//  Copyright © 2016年 ChinaPan. All rights reserved.
//

#import "FYTableViewController.h"
#import "FYTableViewCell.h"
#import "PureLayout.h"

@interface FYTableViewController ()<SwipeableCellDelegate>
//可变数组
@property (nonatomic, strong) NSMutableArray *objects;

//可变集合
@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;
@end

@implementation FYTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.cellsCurrentlyEditing = [NSMutableSet new];
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.objects = [NSMutableArray array];
    

    NSInteger numberOfItems = 30;
    for (NSInteger i = 1; i <= numberOfItems; i++) {
        NSString *item = [NSString stringWithFormat:@"      Longer Title Item #%ld", i];
        [self.objects addObject:item];
    }
    [self.tableView registerClass:[FYTableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.objects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
#warning 不加载缓存池里的了.防止cell重用,这也是未解决的地方,希望得到宝贵的意见
    
    FYTableViewCell *cell = [[FYTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.delegate = self;
    NSString *item = self.objects[indexPath.row];
    cell.itemText = item;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
        [cell openCell];
    }
    
    return cell;
}
// 如果实现了这个方法， 就自动实现了滑动删除的功能，滑动的时候不会调用这个方法，在删除的时候才会调用这个方法（提交了一个删除操作会调用）
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        NSLog(@"Unhandled editing style! %ld", editingStyle);
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
#pragma mark - SwipeableCellDelegate
- (void)buttonOneActionForItemText:(NSString *)itemText {
    NSLog(@"In the delegate, Clicked button one for %@", itemText);
}

- (void)buttonTwoActionForItemText:(NSString *)itemText {
    NSLog(@"In the delegate, Clicked button two for %@", itemText);
}

- (void)cellDidOpen:(UITableViewCell *)cell {
    //记住打开的cell
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell {
    [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}

@end

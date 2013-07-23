//
//  TrashController.h
//  FileBox
//
//  Created by xuguolong on 13-7-23.
//  Copyright (c) 2013年 homein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrashController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
- (IBAction)onRecycle:(id)sender;
- (IBAction)onBack:(id)sender;

@property (nonatomic, strong) NSMutableArray* files;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) UIViewController* parent;

@end

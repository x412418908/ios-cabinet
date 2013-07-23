//
//  ViewController.h
//  FileBox
//
//  Created by xuguolong on 13-7-19.
//  Copyright (c) 2013年 homein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *fileitemTable;
- (IBAction)onWIFI:(id)sender;
- (IBAction)onTrash:(id)sender;

@property (retain, strong) NSMutableArray* files;

-(BOOL) refreshList;

@end

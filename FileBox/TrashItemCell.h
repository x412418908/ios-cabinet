//
//  TrashItemCell.h
//  FileBox
//
//  Created by xuguolong on 13-7-23.
//  Copyright (c) 2013年 homein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrashItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *Filename;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *filesize;
@end

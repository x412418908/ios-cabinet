//
//  TrashController.m
//  FileBox
//
//  Created by xuguolong on 13-7-23.
//  Copyright (c) 2013年 homein. All rights reserved.
//

#import "TrashController.h"
#import "TrashItemCell.h"
#import "ViewController.h"

@interface TrashController (){
    NSMutableDictionary* fileExtentionMap;
}

@end

@implementation TrashController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) != nil){
            self.files = [[NSMutableArray alloc] init];
            fileExtentionMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                @"avi", @"avi",
                                @"doc", @"doc",
                                @"doc", @"docx",
                                @"jpg", @"jpeg",
                                @"mp3", @"mp3",
                                @"pdf", @"pdf",
                                @"ppt", @"ppt",
                                @"ppt", @"pptx",
                                @"txt", @"txt",
                                @"xls", @"xls",
                                @"xls", @"xlsx", nil];
            
            
            return self;
        }
    }
    return self;
}

-(void)loadTrashItems{
    NSError *error;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Trash"];
    NSArray* documentsArray = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    self.files = [[NSMutableArray alloc] init];
    for (NSString* fileName in documentsArray){
        if ([fileName hasPrefix:@"."]){
            continue;
        }
        
        NSString *URL = [documentsDirectory stringByAppendingPathComponent: fileName];
        NSError *attributesError = nil;
        NSDictionary *fileAttributes = [fileMgr attributesOfItemAtPath:URL error:&attributesError];
        
        if ([[fileAttributes fileType] isEqualToString:NSFileTypeDirectory]){
            continue;
        }
        
        
        [self.files addObject:fileName];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.allowsMultipleSelection = YES;
    [self loadTrashItems];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIImage*) getImageByFilename:(NSString*)fileName{
    NSString* imageName = [fileExtentionMap objectForKey:[[fileName pathExtension] lowercaseString]];
    if (imageName == nil){
        return [UIImage imageNamed:@"otherfile.png"];
    }else{
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", imageName]];
    }
    
}


- (NSString*) getFileSize: (NSInteger) fileSize
{
    if (fileSize < 1024){
        return @"1K";
    }else if (fileSize < 1024*1024){
        return [[NSString alloc] initWithFormat:@"%dK", (fileSize/1024)];
    }else {
        return [[NSString alloc] initWithFormat:@"%dM", (fileSize/1024/1024)];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.files.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    TrashItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TrashItemCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[TrashItemCell class]]){
                cell =  (TrashItemCell *) currentObject;
                break;
            }
        }
    }
    
    
    
    NSUInteger row = [indexPath row];
    NSString* fileName = [self.files objectAtIndex:row];
    cell.Filename.text = fileName;
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *URL = [documentsDirectory stringByAppendingPathComponent: fileName];
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [fileMgr attributesOfItemAtPath:URL error:&attributesError];
    
    cell.filesize.text = [self getFileSize: [fileAttributes fileSize]];
    cell.icon.image = [self getImageByFilename:fileName];
    
    if([[tableView indexPathsForSelectedRows] containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

}


-(void) recycleFile:(NSString*)filename{

    NSString* filepath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]){
        [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
    }
    
    NSString* srcFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Trash/%@", filename];
    [[NSFileManager defaultManager] moveItemAtPath:srcFilePath toPath:filepath error:nil];
    

}

- (IBAction)onRecycle:(id)sender {
    NSString *actionSheetTitle = @"Recycle"; //Action Sheet Title
    //NSString *destructiveTitle = @"Cancel"; //Action Sheet Button Titles
    NSString *other1 = @"Recycle";
    NSString *other2 = @"Delete";
    NSString *other3 = @"Clean trash";
    NSString *cancelTitle = @"Cancel";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:other1, other2, other3, nil];
    [actionSheet showInView:self.view];
    

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
   // NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    //NSLog(@"index=%d", buttonIndex);
    if (buttonIndex == 0){
        NSArray* selectedIndex = [self.tableView indexPathsForSelectedRows];
        NSMutableArray* removedList = [NSMutableArray arrayWithArray:self.files];
        int removed = 0;
        for (NSIndexPath* index in selectedIndex){
            int row = index.row;
            NSString* filename = [self.files objectAtIndex:row];
            [self recycleFile:filename];
            [removedList removeObjectAtIndex:(row-removed)];
            removed++;
        }
        self.files = removedList;
        [self.tableView reloadData];
        
    }else if (buttonIndex == 1){
        NSArray* selectedIndex = [self.tableView indexPathsForSelectedRows];
        NSMutableArray* removedList = [NSMutableArray arrayWithArray:self.files];
        int removed = 0;
        for (NSIndexPath* index in selectedIndex){
            int row = index.row;
            NSString* filename = [self.files objectAtIndex:row];
            
            NSString* srcFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Trash/%@", filename];
            [[NSFileManager defaultManager] removeItemAtPath:srcFilePath error:nil];

            [removedList removeObjectAtIndex:(row-removed)];
            removed++;
        }
        self.files = removedList;
        [self.tableView reloadData];
    }else if (buttonIndex == 2){
       
        for (int i=0; i<self.files.count; i++){
            int row = i;
            NSString* filename = [self.files objectAtIndex:row];
            
            NSString* srcFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Trash/%@", filename];
            [[NSFileManager defaultManager] removeItemAtPath:srcFilePath error:nil];
 
        }
        self.files = [[NSMutableArray alloc] init];
        [self.tableView reloadData];
    }
             
    
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
//    ViewController* parent = self.parent;
//    [parent refreshList];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

@end

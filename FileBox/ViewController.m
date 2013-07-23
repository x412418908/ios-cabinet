//
//  ViewController.m
//  FileBox
//
//  Created by xuguolong on 13-7-19.
//  Copyright (c) 2013年 homein. All rights reserved.
//

#import "ViewController.h"
#import "TrashController.h"
#import "wifiFtpServerStartViewController.h"

@interface ViewController (){
    NSDictionary* fileExtentionMap;
   
}

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;


@end

@implementation ViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
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
    return nil;
}

-(void)loadLocalFilse{
    NSError *error;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
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
	
 
}

-(void)viewDidAppear:(BOOL)animated{
    [self loadLocalFilse];
    [self.fileitemTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload {
    [self setFileitemTable:nil];
    [super viewDidUnload];
}
- (IBAction)onWIFI:(id)sender {
    wifiFtpServerStartViewController* controller = [[wifiFtpServerStartViewController alloc] initWithNibName:@"wifiFtpServerStartViewController" bundle:nil];
    [self presentModalViewController:controller animated:YES ];
}

- (IBAction)onTrash:(id)sender {
    TrashController* controller = [[TrashController alloc] initWithNibName:@"TrashController" bundle:nil];
    controller.parent = self;
    [self presentViewController:controller animated:YES completion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.files.count;
}

-(BOOL) refreshList{
    [self loadLocalFilse];
    [self.fileitemTable reloadData];
    return YES;
}

-(void)refreshFiles{
    [self loadLocalFilse];
    [self.fileitemTable reloadData];
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




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    

    
    NSUInteger row = [indexPath row];
    NSString* fileName = [self.files objectAtIndex:row];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.text =  fileName;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *URL = [documentsDirectory stringByAppendingPathComponent: fileName];
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [fileMgr attributesOfItemAtPath:URL error:&attributesError];
    
    cell.detailTextLabel.text = [self getFileSize: [fileAttributes fileSize]];
    cell.imageView.image = [self getImageByFilename:fileName];
 
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;

}

-(void)writeUTF8File:(NSString*)content filepath:(NSString*)path{
    //0xEF,0xBB,0xBF
    unsigned char bom[3] = {0};
    bom[0] = (unsigned char)0xEF;
    bom[1] = (unsigned char)0xBB;
    bom[2] = (unsigned char)0xBF;
    NSMutableData* data = [[NSMutableData alloc] initWithCapacity:content.length*2];
    [data appendBytes:bom length:3];
    [data appendData: [content dataUsingEncoding:NSUTF8StringEncoding]];
    [data writeToFile:path atomically:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];
    NSString* fileName = [self.files objectAtIndex:row];
    NSString* imageName = [fileExtentionMap objectForKey:[[fileName pathExtension] lowercaseString]];
    
    NSString* path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
    NSURL* url = [NSURL  fileURLWithPath:path];
    
    [self.fileitemTable deselectRowAtIndexPath:indexPath animated:NO];
    
    if (imageName == nil){
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        [self.documentInteractionController setDelegate:self];

        [self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        
        return;
    }
    if ([imageName isEqualToString:@"txt"]){
        NSStringEncoding encoding =0;
        NSString* content = [[NSString alloc] initWithContentsOfFile:path usedEncoding:&encoding error:nil];
        if (content == nil){
            // convert gbk/gb2312 to utf-8
             NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *retStr = [[NSString alloc] initWithContentsOfFile:path encoding:enc error:nil];
            if (retStr != nil){
               // NSLog(@"content = %@", retStr);
               // [retStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
                [self writeUTF8File:retStr filepath:path];
            }

        }else{
    
            //detect BOM exist or not
            BOOL hasBom = NO;
            NSData* data = [[NSData alloc] initWithContentsOfFile:path];
            
          /*  Bytes	       Encoding Form
            00 00 FE FF	UTF-32, big-endian
            FF FE 00 00	UTF-32, little-endian
            FE FF	UTF-16, big-endian
            FF FE	UTF-16, little-endian
            EF BB BF	UTF-8*/
            const unsigned char* buf = data.bytes;
            
            
            if (buf[0] == 0xEF && buf[1] == 0xBB && buf[2] == 0xBF){
                hasBom = YES;
            }else if (buf[0] == 0xFF && buf[1] == 0xFE){
                hasBom = YES;
            }else if (buf[0] == 0xFE && buf[1] == 0xFF){
                hasBom = YES;
            }

            if (!hasBom){
                [self writeUTF8File:content filepath:path];
            }
        }
    }

    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    [self.documentInteractionController setDelegate:self];
    [self.documentInteractionController presentPreviewAnimated:YES];
    
    
}


// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        int row = indexPath.row;
        NSString* filename = [self.files objectAtIndex:row];
        NSString* filepath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Trash/%@", filename];
        //[[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
        
        NSString* trashFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Trash"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:trashFolder]){
            [[NSFileManager defaultManager] createDirectoryAtPath:trashFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]){
            [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
        }
        
        NSString* srcFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
        [[NSFileManager defaultManager] moveItemAtPath:srcFilePath toPath:filepath error:nil];
        
        
        [self.files removeObjectAtIndex:row];
        [self.fileitemTable reloadData];
    }
}


- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}



@end

//
//  AppDelegate.m
//  FileBox
//
//  Created by xuguolong on 13-7-19.
//  Copyright (c) 2013年 homein. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}




- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if (url != nil && [url isFileURL]){
        //NSLog(@"handle file url %@", url);
        NSString* path = [url path];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
            return NO;
        }
        NSString* filename = [url lastPathComponent];
        NSString* destFilepath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
        int index = 1;
        while ([[NSFileManager defaultManager] fileExistsAtPath:destFilepath]){
            NSString* readableFilename = [filename stringByDeletingPathExtension];
            NSString* extention = [filename pathExtension];
            NSString* newFilename = [readableFilename stringByAppendingFormat:@"(%d).%@", (++index), extention];
            filename = newFilename;
            destFilepath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
        }
        NSError* error = nil;
        if ([[NSFileManager defaultManager] copyItemAtPath:path toPath:destFilepath error:&error] != YES){
            NSString* message = [NSString stringWithFormat:@"Copy fail : %@", error.description];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Cabinet" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }else{
            [[self viewController] refreshList];
        }
        
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        
        return  YES;
    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

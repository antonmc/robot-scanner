//
//  AppDelegate.m
//  robots
//
//  Created by Anton McConville on 2014-12-31.
//  Copyright (c) 2014 IBM. All rights reserved.
//

#import "AppDelegate.h"
#import <TwitterKit/TwitterKit.h>
#import <Fabric/Fabric.h>

#import <IBMBluemix/IBMBluemix.h>
#import <IBMPush/IBMPush.h>
#import <IBMData/IBMData.h>

#import <CoreData/CoreData.h>

#import "RemoteHelp.h"
#import "Help.h"
#import "RobotRemote.h"
#import "Robot.h"
#import "ESTBeaconManager.h"
#import "ESTConfig.h"
#import "SBUIColor.h"
#import "ConfigData.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [ESTConfig setupAppID:nil andAppToken:nil];
    
    // Override point for customization after application launch.
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor colorwithHexString:@"b2e7ef" alpha:1];
    pageControl.currentPageIndicatorTintColor = [UIColor colorwithHexString:@"00b2ca" alpha:1];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    [[Twitter sharedInstance] startWithConsumerKey:@""
                                    consumerSecret:@""];
    [Fabric with:@[[Twitter sharedInstance]]];
    
    
    [[UITabBar appearance] setTintColor: [UIColor colorwithHexString:@"00B2CA" alpha:1] ];
    [[UITabBar appearance] setBarTintColor:[UIColor colorwithHexString:@"e5f7f9" alpha:1] ];
    self.viewController.tabBarController.tabBar.layer.borderColor = (__bridge CGColorRef)([UIColor colorwithHexString:@"00B2CA" alpha:1]);
    
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorwithHexString:@"00B2CA" alpha:1] ];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    
    [IBMBluemix initializeWithApplicationId: @""
                       andApplicationSecret: @""
                        andApplicationRoute: @""];
    
    
    [IBMData initializeService];
    
    IBMQuery *qry = [RobotRemote query];
    
    [[qry find] continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            NSLog(@"listItems failed with error: %@", task.error);
        } else {
            
            NSMutableArray* robotList = [NSMutableArray arrayWithArray: task.result];
            
            for( RobotRemote* remoteRobot in robotList ){
                
                NSLog(@"Name: %@", remoteRobot.name);
                
                
                Robot *newRobot = [NSEntityDescription insertNewObjectForEntityForName:@"Robot"
                                                                          inManagedObjectContext:self.managedObjectContext];
                
                newRobot.name = remoteRobot.name;
                newRobot.about = remoteRobot.description;
                newRobot.mugshot = remoteRobot.mugshotBase64;
                newRobot.fullshot = remoteRobot.fullBase64;
                newRobot.iBeacon = remoteRobot.beacon;
                newRobot.primaryColor = remoteRobot.primaryColor;
                newRobot.secondaryColor = remoteRobot.secondaryColor;
                
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                
                newRobot.disruption = [ f numberFromString: remoteRobot.disruption  ];
            }
        }
    
        return nil;
    }];
    
    
    qry = [ConfigData query];
    
    [[qry find] continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            NSLog(@"listItems failed with error: %@", task.error);
        } else {
            
            NSMutableArray* configList = [NSMutableArray arrayWithArray: task.result];
            
            for( ConfigData* configItem in configList ){
                
                NSLog( @"Disruption Range: %@", configItem.disruptionRange );
                
                self.config = configItem;
                
            }
        }
        
        return nil;
    }];


    
    return YES;
}


-(Player*) getPlayer{
    return self.player;
}

-(NSArray*)getRobots
{
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Robot"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error;
    
    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Returning Fetched Records
    return fetchedRecords;
}

-(NSArray*)getHelp
{
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Help"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error;
    
    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Returning Fetched Records
    return fetchedRecords;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RobotModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"robots.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

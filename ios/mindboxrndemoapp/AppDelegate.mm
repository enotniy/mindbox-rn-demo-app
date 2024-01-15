#import "AppDelegate.h"

@import Mindbox;
@import MindboxSdk;

#import <React/RCTBundleURLProvider.h>
#import <React/RCTLinkingManager.h>


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"main";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};
  
//  [[Mindbox logger] setLogLevel:LogLevelDebug];
  
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
      if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [[UIApplication sharedApplication] registerForRemoteNotifications];
          [[Mindbox shared] notificationsRequestAuthorizationWithGranted:granted];
        });
      }
      else {
        NSLog(@"NotificationsRequestAuthorization failed with error: %@", error.localizedDescription);
      }
    }];
  
  TrackVisitData *data = [[TrackVisitData alloc] init];
    data.launchOptions = launchOptions;
    [[Mindbox shared] trackWithData:data];
  
  if (@available(iOS 13.0, *)) {
        [[Mindbox shared] registerBGTasks];
      }
      else {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
      }

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  //print(@"Failed to register for remote notifications: \(error.localizedDescription)");
   NSLog(@"Failed to register for remote notifications: %@", error.localizedDescription);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
  completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [[Mindbox shared] apnsTokenUpdateWithDeviceToken:deviceToken];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {

  [[Mindbox shared] pushClickedWithResponse:response];
  [MindboxJsDelivery emitEvent:response];
  TrackVisitData *data = [[TrackVisitData alloc] init];
    data.push = response;
    [[Mindbox shared] trackWithData:data];
  completionHandler();
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
  TrackVisitData *data = [[TrackVisitData alloc] init];
  data.universalLink = userActivity;
  [[Mindbox shared] trackWithData:data];
  return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  [[Mindbox shared] application:application performFetchWithCompletionHandler:completionHandler];
}

@end

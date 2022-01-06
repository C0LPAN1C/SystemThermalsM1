//
//  AppDelegate.h
//  SystemThermals
//
//  Created by Apollo SOFTWARE on 2/1/21.
//

#import <Cocoa/Cocoa.h>
#import "M1Wrapper.h"

#define DELAY_T     2.5
//#define TJ_MIN      49.9
#define TJ_WARN1    50.0
#define TJ_WARN2    62.5
#define TJ_WARN3    70.0
#define TJ_MAX      77.5

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSStatusBar *statusBar;
@property (strong, nonatomic) NSMenu *menu;


- (NSString *) get_cpu_temperature;
- (float) get_cpu_temp;
@end


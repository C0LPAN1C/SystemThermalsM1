//
//  AppDelegate.h
//  SystemThermals
//
//  Created by Apollo SOFTWARE on 2/1/21.
//

#import <Cocoa/Cocoa.h>

#define DELAY_T     5.0
#define TJ_MID      50.0
#define TJ_WARN1    60.0
#define TJ_WARN2    70.0
#define TJ_WARN3    80.0
#define TJ_MAX      90.0

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong, nonatomic) NSStatusItem *statusItem;
- (NSString *) get_cpu_temperature;
- (float) get_cpu_temp;
@end


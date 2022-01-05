//
//  M1Wrapper.m
//  SystemThermals
//
//  Created by Amit Apollo Barman on 12/28/21.
//  Copyright © 2021 Apollo SOFTWARE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M1Wrapper.h"

int UNIT = CELC;

@implementation M1Wrapper

// Shared Instance (Singleton)
static M1Wrapper *sharedInstance = nil;

+(M1Wrapper *) sharedWrapper{
    if ( sharedInstance == nil ){
        sharedInstance = [[M1Wrapper alloc] init];
    }
    return sharedInstance;
}

CFDictionaryRef match(int page, int usage)
{
    CFNumberRef nums[2];
    CFStringRef keys[2];

    keys[0] = CFStringCreateWithCString(0, "PrimaryUsagePage", 0);
    keys[1] = CFStringCreateWithCString(0, "PrimaryUsage", 0);
    nums[0] = CFNumberCreate(0, kCFNumberSInt32Type, &page);
    nums[1] = CFNumberCreate(0, kCFNumberSInt32Type, &usage);

    CFDictionaryRef dict = CFDictionaryCreate(0, (const void**)keys, (const void**)nums, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return dict;
}

CFArrayRef getProductNames(CFDictionaryRef sensors) {
    IOHIDEventSystemClientRef system = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    IOHIDEventSystemClientSetMatching(system, sensors);
    CFArrayRef matchingsrvs = IOHIDEventSystemClientCopyServices(system);
    long count = CFArrayGetCount(matchingsrvs);
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);

    for (int i = 0; i < count; i++) {
        IOHIDServiceClientRef sc = (IOHIDServiceClientRef)CFArrayGetValueAtIndex(matchingsrvs, i);
        CFStringRef name = IOHIDServiceClientCopyProperty(sc, CFSTR("Product"));
        if (name) {
            CFArrayAppendValue(array, name);
        } else {
            CFArrayAppendValue(array, @"noname");
        }
    }
    return array;
}

CFArrayRef getThermalValues(CFDictionaryRef sensors) {
    IOHIDEventSystemClientRef system = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    IOHIDEventSystemClientSetMatching(system, sensors);
    CFArrayRef matchingsrvs = IOHIDEventSystemClientCopyServices(system);

    long count = CFArrayGetCount(matchingsrvs);
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);

    for (int i = 0; i < count; i++) {
        IOHIDServiceClientRef sc = (IOHIDServiceClientRef)CFArrayGetValueAtIndex(matchingsrvs, i);
        IOHIDEventRef event = IOHIDServiceClientCopyEvent(sc, kIOHIDEventTypeTemperature, 0, 0);
        CFNumberRef value;
        if (event != 0) {
            double temp = IOHIDEventGetFloatValue(event, IOHIDEventFieldBase(kIOHIDEventTypeTemperature));
            value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &temp);
        } else {
            double temp = 0;
            value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &temp);
        }
        CFArrayAppendValue(array, value);
    }
    return array;
}

NSString *get_temperature(CFArrayRef values)
{
    long count = CFArrayGetCount(values);
    if (count > 1)
    {
        CFNumberRef value = CFArrayGetValueAtIndex(values, 1);
        double temp = 0.0;
        CFNumberGetValue(value, kCFNumberDoubleType, &temp);
        return [NSString stringWithFormat:@"%.01f°C", temp];
    }
    else return @"0.0°C";
}

float get_temperature_float(CFArrayRef values) {
    long count = CFArrayGetCount(values);
    if (count > 1)
    {
        CFNumberRef value = CFArrayGetValueAtIndex(values, 1);
        double temp = 0.0;
        CFNumberGetValue(value, kCFNumberDoubleType, &temp);
        return temp;
    }
    return 0.0f;
}


-(float ) get_temp_float {
    CFDictionaryRef thermalSensors = match(SENSOR, 5);
    CFArrayRef thermalValues = getThermalValues(thermalSensors);
    return get_temperature_float(thermalValues);
}

- (NSString *) get_temp_values {
    CFDictionaryRef thermalSensors = match(SENSOR, 5);
    CFArrayRef thermalValues = getThermalValues(thermalSensors);
    NSLog(@"\n\n\tCPU Core 0 Temp:\n\t%@",get_temperature(thermalValues));
    if (UNIT == KELV)
        return [NSString stringWithFormat:@"%.01f°K", (get_temperature_float(thermalValues) + 273.15f)];
    if (UNIT == FAREN)
        return [NSString stringWithFormat:@"%.01f°F", ((get_temperature_float(thermalValues) * 9/5) + 32.0f)];
    return get_temperature(thermalValues);
}

-(BOOL) m1Open
{
    CFDictionaryRef thermalSensors = match(SENSOR, 5);
    CFArrayRef thermalValues = getThermalValues(thermalSensors);
    if (thermalValues)
    {
        CFRelease(thermalValues);
        return true;
    } else return false;
}


-(void) m1Close
{}

#pragma mark Init and Dealloc

-(id) init{
    if (self = [super init]){
        if (![self m1Open]){
            NSLog(@"Unable to open M1 SMC.");
        }
    }
    return self;
}

-(void) dealloc{
    [self m1Close];
}

@end

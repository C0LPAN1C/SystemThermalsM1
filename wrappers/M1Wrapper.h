//
//  M1Wrapper.h
//  SystemThermals
//
//  Created by Amit Apollo Barman on 12/28/21.
//  Copyright © 2021 Apollo SOFTWARE. All rights reserved.
//

#ifndef M1Wrapper_h
#define M1Wrapper_h

#include <IOKit/hidsystem/IOHIDEventSystemClient.h>
#include <Foundation/Foundation.h>
#include <stdio.h>

// Declarations from other IOKit source code
@interface M1Wrapper : NSObject

+(M1Wrapper *)sharedWrapper;

typedef struct __IOHIDEvent *IOHIDEventRef;
typedef struct __IOHIDServiceClient *IOHIDServiceClientRef;
#ifdef __LP64__
typedef double IOHIDFloat;
#else
typedef float IOHIDFloat;
#endif

#define IOHIDEventFieldBase(type)   (type << 16)
#define kIOHIDEventTypeTemperature  15
#define SENSOR  0xff00
#define CELC    0x0000
#define FAREN   0x0001
#define KELV    0x0010
#define NONE    0x0011

IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);
int IOHIDEventSystemClientSetMatching(IOHIDEventSystemClientRef client, CFDictionaryRef match);
int IOHIDEventSystemClientSetMatchingMultiple(IOHIDEventSystemClientRef client, CFArrayRef match);
IOHIDEventRef IOHIDServiceClientCopyEvent(IOHIDServiceClientRef, int64_t , int32_t, int64_t);
IOHIDFloat IOHIDEventGetFloatValue(IOHIDEventRef event, int32_t field);

- (NSString *) get_temp_values;
- (float) get_temp_float;

@end

#endif /* M1Wrapper_h */

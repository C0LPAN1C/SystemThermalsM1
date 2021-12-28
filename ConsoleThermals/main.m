//
//  main.m
//  SystemThermals
//
//  Created by Apollo SOFTWARE on 2/1/21.
//

#import <Foundation/Foundation.h>
#import "M1Wrapper.h"

NSString *get_cpu_temperature(void)
{
    M1Wrapper *m1smc = [M1Wrapper sharedWrapper];
    return [m1smc get_temp_values];
}

int main(int argc, const char * argv[]) {
    get_cpu_temperature();
    return 0;
}



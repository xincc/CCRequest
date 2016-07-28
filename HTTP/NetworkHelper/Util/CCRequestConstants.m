//
//  CCRequestConstants.m
//  CCRequest
//
//  Created by xincc.wang on 3/11/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#include "CCRequestConstants.h"

void CCLog(NSString* format, ...)
{
#ifdef DEBUG
    va_list argptr;
    va_start(argptr, format);
    NSLogv(format, argptr);
    va_end(argptr);
#endif
}


void blockCleanUp(__strong void(^*block)(void)) {
    (*block)();
}

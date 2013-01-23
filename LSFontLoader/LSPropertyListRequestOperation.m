//
//  LSPropertyListRequestOperation.m
//  LSFontLoader
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import "LSPropertyListRequestOperation.h"

@implementation LSPropertyListRequestOperation

+ (NSSet *)acceptableContentTypes {
	return [[super acceptableContentTypes] setByAddingObject:@"application/xml"];
}

@end

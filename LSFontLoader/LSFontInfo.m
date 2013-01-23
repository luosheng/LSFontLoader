//
//  LSFontInfo.m
//  LSFontLoader
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import "LSFontInfo.h"

@implementation LSFontInfo

- (id)initWithDictionary:(NSDictionary *)dictionary {
	self = [super init];
	if (self) {
		_info = dictionary;
	}
	return self;
}

- (NSString *)familyName {
	return _info[@"FontFamilyName"];
}

@end

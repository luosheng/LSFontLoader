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

- (NSString *)name {
	return _info[@"PostScriptFontName"];
}

- (NSString *)displayNameForLocale:(NSLocale *)locale {
	NSDictionary *displayNames = _info[@"DisplayNames"];
	NSString *displayName = displayNames[locale.localeIdentifier];
	if (!displayName) {
		displayName = displayNames[@"en"];
	}
	if (!displayName) {
		displayName = displayNames[displayNames.allKeys[0]];
	}
	return displayName;
}

@end

//
//  LSViewController.m
//  LSFontLoaderExample
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import "LSViewController.h"

@interface LSViewController ()

@end

@implementation LSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
	
	NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]];
	[self.webView loadRequest:request];
	
	_fontLoader = [LSFontLoader sharedLoader];
	[_fontLoader fetchManifestWithCompleteBlock:^{
		[self.tableView reloadData];
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _fontLoader.fontAssets.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	LSFontAsset *asset = _fontLoader.fontAssets[section];
	LSFontInfo *info = asset.infoList.lastObject;
	return info.familyName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	LSFontAsset *asset = _fontLoader.fontAssets[section];
	return asset.infoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	LSFontAsset *asset = _fontLoader.fontAssets[indexPath.section];
	NSString *designLanguage = asset.designLanguages[0];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:designLanguage];
	LSFontInfo *info = asset.infoList[indexPath.row];
	cell.textLabel.text = [info displayNameForLocale:locale];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	LSFontAsset *asset = _fontLoader.fontAssets[indexPath.section];
	
	void (^applyFonts)(void) = ^{
		[_fontLoader loadFont:asset];
		LSFontInfo *info = asset.infoList[indexPath.row];
		[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.style.fontFamily='%@'", info.name]];
	};
	
	if ([_fontLoader isFontDownloaded:asset]) {
		applyFonts();
	} else {
		[_fontLoader downloadFont:asset];
		applyFonts();
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

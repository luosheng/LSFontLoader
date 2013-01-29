//
//  LSViewController.m
//  LSFontLoaderExample
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import "LSViewController.h"
#import "LSWebViewController.h"

@interface LSViewController ()

@end

@implementation LSViewController

- (void)loadView {
	[super loadView];
	
	self.title = @"LSFontLoader Demo";
	
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
	
	_HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:_HUD];
	[_HUD show:YES];
	
	_fontLoader = [LSFontLoader sharedLoader];
	[_fontLoader fetchManifestWithCompleteBlock:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[_HUD hide:YES];
			[self.tableView reloadData];
		});
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
	cell.accessoryType = [_fontLoader isFontDownloaded:asset] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	LSFontAsset *asset = _fontLoader.fontAssets[indexPath.section];
	
	void (^applyFonts)(void) = ^{
		if (_selectedFontAsset) {
			[_fontLoader unloadFont:_selectedFontAsset];
		}
		_selectedFontAsset = asset;
		[_fontLoader loadFont:asset];
		
		LSWebViewController *webViewController = [[LSWebViewController alloc] init];
		webViewController.fontInfo = asset.infoList[indexPath.row];
		[self.navigationController pushViewController:webViewController animated:YES];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
			[_HUD hide:YES];
		});
	};
	
	if ([_fontLoader isFontDownloaded:asset]) {
		applyFonts();
	} else {
		_HUD.progress = 0.0;
		[_HUD show:YES];
		_HUD.mode = MBProgressHUDModeDeterminate;
		[_fontLoader downloadFont:asset withCompleteBlock:applyFonts downloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
			_HUD.progress = (float)totalBytesRead / totalBytesExpectedToRead;
		}];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

# LSFontLoader

According to [Apple's knowledge base](http://support.apple.com/kb/HT5484), it is now possible for apps to install the additional fonts as necessary in iOS 6.

LSFontLoader is a framework for downloading the additional fonts from Apple's server and loading them dynamically in your project.

Note that the framework is a work in progress at the moment and should be consider **alpha quality**. Breaking changes may happen during this time.

## Install

Install [CocoaPods](https://github.com/CocoaPods/CocoaPods) and add the following line to your `Podfile`:

```ruby
pod 'LSFontLoader', :git => 'https://github.com/luosheng/LSFontLoader.git'
```

## Example

Clone this repository recursively with all the submodules:

```bash
git clone --recursive https://github.com/luosheng/LSFontLoader.git
```

Look into `LSFontLoaderExample` directory for demonstration.

## License

LSFontLoader is licensed under [MIT License](https://github.com/luosheng/LSFontLoader/blob/master/LICENSE).

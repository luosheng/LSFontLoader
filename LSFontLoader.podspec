Pod::Spec.new do |s|
  s.name         = "LSFontLoader"
  s.version      = "0.1"
  s.summary      = "LSFontLoader will download and load additional fonts provided in iOS 6."
  s.homepage     = "https://github.com/luosheng/LSFontLoader"
  s.license      = 'MIT'
  s.author       = { "Sheng Luo" => "luosheng1986@gmail.com" }
  s.source       = { :git => "https://github.com/luosheng/LSFontLoader.git", :tag => '0.2' }
  s.platform     = :ios, '5.0'
  s.source_files = 'LSFontLoader'
  s.frameworks = 'CoreText'
  s.resources = 'LSFontLoader/*.xml'
  s.requires_arc = true
  s.dependency 'AFNetworking'
  s.dependency 'SSZipArchive'
  s.dependency 'AFDownloadRequestOperation'
end

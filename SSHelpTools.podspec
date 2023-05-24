#
# Be sure to run `pod lib lint SSHelpTools.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SSHelpTools'
  s.version          = '0.1.4'
  s.summary          = '常用工具'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 代码逐渐完善中，欢迎提出问题.
                       DESC

  s.homepage         = 'https://github.com/songzhibing/SSHelpTools'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'SSHELPTOOLSLICENSE' }
  s.author           = { '宋直兵' => '569204317@qq.com' }
  s.source           = { :git => 'https://github.com/songzhibing/SSHelpTools.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.ios.deployment_target = '13.0'
  
  # SSHelpTools 常用工具库
  s.subspec 'SSHelpTools' do |tools|
    tools.source_files = 'SSHelpTools/Classes/SSHelpTools/**/*.{h,m}'
    tools.public_header_files = 'SSHelpTools/Classes/SSHelpTools/**/*.h'
    tools.resource_bundles = {
      'SSHelpTools'=> ['SSHelpTools/Classes/SSHelpTools/Bundle/SSHelpTools.bundle','SSHelpTools/Classes/SSHelpTools/Bundle/SSHelpTools.xcassets']
    }
    tools.frameworks = 'UIKit','Foundation','CoreLocation','AVFoundation','PhotosUI','CoreTelephony','NetworkExtension','SystemConfiguration'
    tools.dependency 'Masonry'
    tools.dependency 'SDWebImage'
    tools.dependency 'UICKeyChainStore'
    tools.dependency 'MBProgressHUD'
    tools.dependency 'FMDB'
    tools.dependency 'YYKit'
    tools.dependency 'ReactiveObjC'
  end
  
  # SSHelpWebView 库
  s.subspec 'SSHelpWebView' do |web|
    web.source_files = 'SSHelpTools/Classes/SSHelpWebView/**/*'
    web.public_header_files = 'SSHelpTools/Classes/SSHelpWebView/*.h'
    web.frameworks = 'WebKit'
    web.dependency 'SSHelpTools/SSHelpTools'  #需要用到SSHelpTools库
    web.dependency 'WebViewJavascriptBridge'
  end
  
  # SSHelpLog 日志系统库
  s.subspec 'SSHelpLog' do |log|
    log.source_files = 'SSHelpTools/Classes/SSHelpLog/**/*'
    log.public_header_files = 'SSHelpTools/Classes/SSHelpLog/*.h'
    log.dependency 'CocoaLumberjack'
    log.dependency 'GCDWebServer', :configurations => ['Debug','Release']
  end
  
  # SSHelpNetwork 网络封装库
  s.subspec 'SSHelpNetwork' do |network|
    network.source_files = 'SSHelpTools/Classes/SSHelpNetwork/**/*'
    network.public_header_files = 'SSHelpTools/Classes/SSHelpNetwork/**/*.h'
    network.frameworks = 'CoreTelephony'
    network.dependency 'AFNetworking'
    network.dependency 'ReactiveObjC', :configurations => ['Debug']
  end
  
end

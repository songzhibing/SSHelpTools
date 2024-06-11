#
# Be sure to run `pod lib lint SSHelpTools.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SSHelpTools'
  s.version          = '0.3.01'
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
      'SSHelpTools'=> [
        'SSHelpTools/Classes/SSHelpTools/Bundle/SSHelpTools.bundle',
        'SSHelpTools/Classes/SSHelpTools/Bundle/SSHelpTools.xcassets'
      ]
    }
    tools.frameworks = 'UIKit','Foundation','CoreLocation','AVFoundation','PhotosUI','CoreTelephony','NetworkExtension','SystemConfiguration','QuickLook','MobileCoreServices'
    tools.dependency 'Masonry'
    tools.dependency 'SDWebImage'
    tools.dependency 'UICKeyChainStore'
    tools.dependency 'MBProgressHUD'
    tools.dependency 'ReactiveObjC', :configurations => ['Debug']
    # tools.dependency 'CocoaLumberjack'
    # tools.dependency 'GCDWebServer', :configurations => ['Debug']
  end
  
  # SSHelpWebView 库
  s.subspec 'SSHelpWebView' do |web|
    web.source_files = 'SSHelpTools/Classes/SSHelpWebView/**/*'
    web.public_header_files = 'SSHelpTools/Classes/SSHelpWebView/*.h'
    web.frameworks = 'WebKit'
    web.dependency 'SSHelpTools/SSHelpTools'
    web.dependency 'WebViewJavascriptBridge'
  end
    
  # SSHelpNetwork 网络封装库
  s.subspec 'SSHelpNetwork' do |network|
    network.source_files = 'SSHelpTools/Classes/SSHelpNetwork/**/*'
    network.public_header_files = 'SSHelpTools/Classes/SSHelpNetwork/**/*.h'
    network.frameworks = 'CoreTelephony'
    network.dependency 'AFNetworking'
    network.dependency 'ReactiveObjC', :configurations => ['Debug']
  end
  
  # DLAN 投屏
  s.subspec 'SSHelpDLAN' do |dlan|
    dlan.source_files = 'SSHelpTools/Classes/SSHelpDLAN/**/*.{h,m}'
    dlan.dependency 'SSHelpTools/SSHelpTools'
    dlan.dependency 'CocoaAsyncSocket'
    dlan.dependency 'KissXML'
    #dlan.frameworks = 'QuartzCore','UIKit'
  end
  
  # alibaba/BeeHive 改写
  s.subspec 'SSHelpBeeHive' do |beehive|
    beehive.source_files = 'SSHelpTools/Classes/SSHelpBeeHive/*.{h,m}'
    #beehive.resource = 'SSHelpTools/Classes/SSHelpBeeHive/*.bundle'
    beehive.frameworks = 'QuartzCore','UIKit'
  end
  
end

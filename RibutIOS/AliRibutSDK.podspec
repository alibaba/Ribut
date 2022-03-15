Pod::Spec.new do |s|

  s.name         = "AliRibutSDK"
  s.version      = "1.0.0"
  s.summary      = "AliRibutSDK"
  s.description  = "Ribut可视化Debug架构"
  s.license      = "MIT"
  

  s.homepage     = "https://github.com/alibaba/Ribut"


  s.author             = { "weixiao" => "weixiao.yz@alibaba-inc.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/alibaba/Ribut.git", :tag => "#{s.version}" }
  s.public_header_files = "AliRibutSDK/AliRibutSDK.h",
  s.source_files = 'AliRibutSDK/**/*.{h,m,mm,c}'
  s.xcconfig = { "ENABLE_BITCODE" => "NO" }
  s.requires_arc = true
  s.dependency  'AFNetworking'
  s.dependency 'SocketRocket'
  
  
end

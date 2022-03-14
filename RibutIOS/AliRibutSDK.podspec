Pod::Spec.new do |s|

  s.name         = "AliRibutSDK"
  s.version      = "1.0.0"
  s.summary      = "AliRibutSDK"
  s.description  = "AliRibutSDK"



  s.homepage     = "http://gitlab.alibaba-inc.com/weixiao.yz/AliRibutSDK"


  s.author             = { "weixiao" => "weixiao.yz@alibaba-inc.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "git@gitlab.alibaba-inc.com:weixiao.yz/AliRibutSDK.git", :tag => "#{s.version}" }

  s.source_files = 'AliRibutSDK/**/*.{h,m,mm,c}'
  s.resources = 'AliRibutSDK/Resources/**'
  s.xcconfig = { "ENABLE_BITCODE" => "NO" }
  s.requires_arc = true
  s.dependency  'AFNetworking'
  s.dependency  'WindVane'
  s.dependency 'SocketRocket'
  s.dependency  'AliUserTrackInterface'
  
  
end

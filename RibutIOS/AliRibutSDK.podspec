Pod::Spec.new do |s|

  s.name         = "AliRibutSDK"
  s.version      = "1.0.0"
  s.summary      = "AliRibutSDK"
  s.description  = "AliRibutSDK"


  s.homepage     = "https://github.com/alibaba/Ribut"


  s.author             = { "weixiao" => "weixiao.yz@alibaba-inc.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/alibaba/Ribut.git", :tag => "#{s.version}" }

  s.source_files = 'RibutIOS/**/*.{h,m,mm,c}'
  s.resources = 'AliRibutSDK/Resources/**'
  s.xcconfig = { "ENABLE_BITCODE" => "NO" }
  s.requires_arc = true
  s.dependency  'AFNetworking'
  s.dependency 'SocketRocket'
  
  
end

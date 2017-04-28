
Pod::Spec.new do |s|
  s.name         = "VIC_NetworkRequest"
  s.version      = "0.0.8"
  s.summary      = "VIC_NetworkRequest"
  s.homepage     = "https://github.com/Venus-Software/objective_c_Network"
  s.license      = "MIT"
  s.author       = { "sswimp" => "754612130@qq.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/Venus-Software/objective_c_Network.git", :tag => s.version }
  s.source_files = "VIC_NetworkRequest/VICNetWorkHeader.h"
  s.public_header_files = 'VIC_NetworkRequest/VICNetWorkHeader.h'
  s.requires_arc = true
  # s.dependency "JSONKit", "~> 1.4"

  s.subspec 'BaseRequest' do |ss|
    ss.dependency 'VIC_NetworkRequest/VICNetworking'
    ss.dependency 'VIC_NetworkRequest/ThirdSuppter/MBProgressHUD'
    ss.source_files = 'VIC_NetworkRequest/BaseRequest/*.{h,m}'
    ss.public_header_files = 'VIC_NetworkRequest/BaseRequest/*.h'
  end
  s.subspec 'ThirdSuppter' do |ss|
    ss.source_files = 'VIC_NetworkRequest/ThirdSuppter/**/*.{h,m}'
    ss.public_header_files = 'VIC_NetworkRequest/ThirdSuppter/**/*.h'  
  end
  s.subspec 'VICNetworking' do |ss|
    ss.dependency 'VIC_NetworkRequest/ThirdSuppter/AFNetworking'
    ss.source_files = 'VIC_NetworkRequest/VICNetworking/*.{h,m}'
    ss.public_header_files = 'VIC_NetworkRequest/VICNetworking/*.h'  
  end
end
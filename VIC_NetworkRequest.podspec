
Pod::Spec.new do |s|
  s.name         = "VIC_NetworkRequest"
  s.version      = "0.0.7"
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
    ss.source_files = 'VIC_NetworkRequest/BaseRequest/**/*.{h,m}'
    ss.public_header_files = 'VIC_NetworkRequest/BaseRequest/**/*.h'

    ss.subspec 'ThirdSuppter' do |sss|
       sss.source_files = 'BaseRequest/ThirdSuppter/**/*.{h,m}'
       sss.public_header_files = 'BaseRequest/ThirdSuppter/**/*.h'
    end   
  end
end
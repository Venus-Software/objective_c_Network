
Pod::Spec.new do |s|
  s.name         = "NetworkRequest"
  s.version      = "0.0.1"
  s.summary      = "NetworkRequest"
  s.homepage     = "https://github.com/Venus-Software/objective_c_Network"
  s.license      = "MIT"
  s.author       = { "sswimp" => "754612130@qq.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/Venus-Software/objective_c_Network.git", :tag => s.version }
  s.source_files = "NetworkRequest/**/*.{h,m}"
  s.public_header_files = 'NetworkRequest/**/*.h'
  s.requires_arc = true
  # s.dependency "JSONKit", "~> 1.4"

end

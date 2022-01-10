Pod::Spec.new do |s|

  s.name         = "AFNetworking"
  s.version      = "4.0.1"
  s.summary      = "ManageLocalCode desc"

  s.homepage     = "https://github.com/AFNetworking/AFNetworking"
  s.license         = { type: 'MIT', file: 'LICENSE' }

  s.author       = { "abuglife" => "abuglife@qq.com" }

  s.platform     = :ios, "10.0"
  s.source       = { :git => "/Users/jungao/Desktop/weibo.dev.code/Zoomed/Zoomed/AFNetworking" }
  s.source_files  = "AFNetworking/*.{h,m}"
  s.requires_arc = true

end

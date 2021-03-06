#
# Be sure to run `pod lib lint HPKDateFormatter.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "HPKDateFormatter"
  s.version          = "0.2.0"
  s.summary          = "An high perfomance, thread safe, efficient date formatter"
  s.description      = <<-DESC
			The basic implementation wraps `NSDateFormatter` and avoid contiuous 
			allocations of expensive objects, a faster implementation is based 
			on an high performance C routine
                       DESC
  s.homepage         = "https://github.com/epacces/HPKDateFormatter"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Eriprando Pacces" => "eriprando.pacces@gmail.com" }
  s.source           = { :git => "https://github.com/epacces/HPKDateFormatter.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hepaKKes'

  s.platform     = :ios, '5.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'HPKDateFormatter' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

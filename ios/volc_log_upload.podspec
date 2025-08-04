#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint volc_log_upload.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'volc_log_upload'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files        = 'Classes/**/*.{h,m,swift}'
  s.exclude_files       = 'Classes/VeTLSiOSSDK.xcframework/**/*'

  s.public_header_files = 'Classes/**/*.h'

  # 引入 vendored framework（VeTLSiOSSDK）
  s.vendored_frameworks = 'Classes/VeTLSiOSSDK.xcframework'
  
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'volc_log_upload_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end

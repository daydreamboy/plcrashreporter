Pod::Spec.new do |spec|
  spec.cocoapods_version = '>= 1.10'
  spec.name        = 'PLCrashReporter'
  spec.version     = '1.11.0'
  spec.summary     = 'Reliable, open-source crash reporting for iOS, macOS and tvOS.'
  spec.description = 'PLCrashReporter is a reliable open source library that provides an in-process live crash reporting framework for use on iOS, macOS and tvOS. The library detects crashes and generates reports to help your investigation and troubleshooting with the information of application, system, process, thread, etc. as well as stack traces.'

  spec.homepage    = 'https://github.com/microsoft/plcrashreporter'
  spec.license     = { :type => 'MIT', :file => 'LICENSE.txt' }
  spec.authors     = { 'Microsoft' => 'appcentersdk@microsoft.com' }

  spec.source      = { :git => "git@github.com:daydreamboy/plcrashreporter.git", :tag => spec.version.to_s }

  spec.ios.deployment_target    = '11.0'
  spec.osx.deployment_target    = '10.9'
  spec.tvos.deployment_target   = '11.0'
  spec.source_files = [
    'Source/**/*.{h,hpp,m,mm,c,cpp,S}',
  ]
  spec.pod_target_xcconfig = { 
    'GCC_PREPROCESSOR_DEFINITIONS' => 'PLCR_PRIVATE PLCRASHREPORTER_PREFIX=',
  }
  spec.library = 'c++'
  spec.dependency 'protobuf-c'
end

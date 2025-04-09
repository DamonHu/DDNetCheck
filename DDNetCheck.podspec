Pod::Spec.new do |s|
s.name = 'DDNetCheck'
s.swift_version = '5.0'
s.version = '1.0.6'
s.license= { :type => "MIT", :file => "LICENSE" }
s.summary = "iOS Ping tool, based on Apple's simplePing project"
s.homepage = 'https://github.com/DamonHu/DDNetCheck'
s.authors = { 'DamonHu' => 'dong765@qq.com' }
s.source = { :git => "https://github.com/DamonHu/DDNetCheck", :tag => s.version}
s.requires_arc = true
s.ios.deployment_target = '12.0'
s.subspec 'core' do |cs|
    cs.resource_bundles = {
      'DDNetCheck' => ['Pods/assets/**/*']
    }
    cs.source_files = "Pods/*.swift", "Pods/model/*.swift", "Pods/view/*.swift"
    cs.dependency 'DDPingTools'
end

s.default_subspecs = "core"
s.frameworks = 'Foundation'
s.documentation_url = 'hhttps://dongge.org/blog/1296.html'
end

Pod::Spec.new do |s|
    s.name = 'WMScrollPageView'
    s.version = '1.1'
    s.license = 'MIT'
    s.summary = '这是一个分页导航视图控件'
    s.homepage = 'https://github.com/wmelon/WMScrollPageView.git'
    s.authors = { '陈仕家' => '511863244@qq.com' }
    s.source = { :git => "https://github.com/wmelon/WMScrollPageView.git", :tag => "#{s.version}"}
    s.resources    = "WMScrollPageView/*.{png,xib,nib,bundle}"
    s.requires_arc = true
    s.ios.deployment_target = '8.0'
    s.source_files = "WMScrollPageView", "*.{h,m}"
end


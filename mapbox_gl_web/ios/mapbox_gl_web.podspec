
Pod::Spec.new do |s|
    s.name             = 'mapbox_gl_web'
    s.version          = '0.1.0'
    s.summary          = 'No-op implementation of mapbox_gl_web web plugin to avoid build issues on iOS'
    s.description      = <<-DESC
  temp fake mapbox_gl_web plugin
                         DESC
    s.homepage         = 'http://example.com'
    s.license          = { :file => '../LICENSE' }
    s.author           = { 'Your Company' => 'email@example.com' }
    s.source           = { :path => '.' }
    s.source_files = 'Classes/**/*'
    s.public_header_files = 'Classes/**/*.h'
    s.dependency 'Flutter'

    s.ios.deployment_target = '8.0'
end
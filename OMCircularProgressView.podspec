Pod::Spec.new do |s|
  s.name = 'OMCircularProgressView'
  s.version = '0.1.1'
  s.license = 'APACHE'
  s.summary = 'Custom circular progress UIControl with steps, images, text and individual animations in Swift'
  s.homepage = 'https://github.com/jaouahbi/OMCircularProgressView'
  s.social_media_url = 'https://twitter.com/a_c_r_a_t_a'
  s.authors = { 'Jorge Ouahbi' => 'jorgeouahbi@gmail.com' }
  s.source = { :git => 'https://github.com/jaouahbi/OMCircularProgressView.git', :tag => s.version }

  s.platform      = :ios, '8.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'OMCircularProgressView/*.swift'

  s.requires_arc = true
end
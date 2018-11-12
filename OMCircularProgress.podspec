#
# Be sure to run `pod lib lint OMCircularProgress.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OMCircularProgress'
  s.version          = '0.4.0'
  s.summary          = 'Circular progress UIControl with steps, images, text and individual animations.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description     = 'Custom circular progress UIControl with steps, images, text and individual animations.'

  s.homepage         = 'https://github.com/jaouahbi/OMCircularProgress'
  #s.screenshots     = 'https://github.com/jaouahbi/OMCircularProgress/blob/master/ScreenShot/ScreenShot_1.png'
  s.license          = { :type => 'APACHE 2.0', :file => 'LICENSE' }
  s.author           = { 'Jorge Ouahbi' => 'jorgeouahbi@gmail.com' }
  s.source           = { :git => 'https://github.com/jaouahbi/OMCircularProgress.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/a_c_r_a_t_a'
  s.ios.deployment_target = '8.0'
  s.source_files = 'OMCircularProgress/Classes/**/*'
end

#FlowSlideMenu.podspec
Pod::Spec.new do |s|
  s.name         = "FlowSlideMenu"
  s.version      = "0.1.1"
  s.summary      = "a light weight and easy to use tableview slide effect."

  s.homepage     = "https://github.com/MatrixHero/FlowSlideMenu"
  s.license      = 'MIT'
  s.author       = { "MatrixHero" => "matrixhero211@gmail.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/MatrixHero/FlowSlideMenu.git", :tag => s.version}
  s.source_files  = 'FlowDrawerCore/*.{swift}'
  s.requires_arc = true
end
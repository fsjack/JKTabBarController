Pod::Spec.new do |s|
  s.name         = "JKTabBarController"
  s.version		 = "1.0.0"
  s.summary      = "Super fixible tab bar controller."

  s.homepage     = "https://github.com/fsjack/JKTabBarController"
  s.license      = 'MIT'
  s.author       = { "Jackie" => "fsjack@gmil.com" }

  s.source       = { :git => "https://github.com/fsjack/JKTabBarController.git"}
  s.source_files = 'JKTabBarController'
  s.framework    = 'Foundation'

  s.requires_arc = true
end

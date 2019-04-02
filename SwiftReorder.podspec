Pod::Spec.new do |s|
  s.name = 'SwiftReorder'
  s.version = '3.1.1'
  s.license = 'MIT'
  s.summary = 'Easy drag-and-drop reordering for UITableViews'
  s.homepage = 'https://github.com/adamshin/SwiftReorder'
  s.author = 'Adam Shin'

  s.platform = :ios, '9.0'
  s.swift_version = '5.0'
  s.source = { :git => 'https://github.com/adamshin/SwiftReorder.git', :tag => s.version }
  s.source_files = 'Source/*'
end

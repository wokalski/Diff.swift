Pod::Spec.new do |s|
  s.name         = "Diff"
  s.version      = "0.6"
  s.summary      = "The fastest Diff library in Swift. Includes UICollectionView/UITableView utils."
  s.homepage     = "https://github.com/tonyarnold/Diff"
  s.description  = <<-DESC
This library generates differences between any two Collections (and Strings). It uses a fast algorithm (O((N+M)*D)). It also includes utilities for UICollectionView/UITableView.
                   DESC

  s.license = { :type => "MIT", :file => "LICENSE" }
  s.authors = {
    "Wojtek Czekalski" => "me@wczekalski.com",
    "Tony Arnold" => "tony@thecocoabots.com"
  }

  s.platforms = { :ios => "8.0", :osx => "10.10", :tvos => "9.0", :watchos => "3.0" }
  s.osx.exclude_files = "Sources/Diff/Diff+UIKit.swift"
  s.watchos.exclude_files = "Sources/Diff/Diff+UIKit.swift"

  s.source = { :git => "https://github.com/tonyarnold/Diff.swift.git", :tag => "0.6" }

  s.source_files = "Sources/Diff"

  post_install do |installer|
    targets = ['Diff']

    installer.pods_project.targets.each do |target|
      if targets.include? target.name
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '4.0'
        end
      end
    end
  end
end

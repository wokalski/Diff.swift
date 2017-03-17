Pod::Spec.new do |s|
  s.name         = "Diff"
  s.version      = "0.5.3"
  s.summary      = "The fastest Diff library in Swift. Includes UICollectionView/UITableView utils."
  s.homepage     = "https://github.com/wokalski/Diff.swift"
  s.description  = <<-DESC
This library generates differences between any two Collections (and Strings). It uses a fast algorithm (O((N+M)*D)). It also includes utilities for UICollectionView/UITableView.
                   DESC

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Wojtek Czekalski" => "me@wczekalski.com" }
  s.social_media_url   = "https://twitter.com/wokalski"

  s.platforms = { :ios => "8.0", :osx => "10.10", :tvos => "9.0", :watchos => "3.0" }
  s.osx.exclude_files = "Sources/Diff+UIKit.swift"
  s.watchos.exclude_files = "Sources/Diff+UIKit.swift"

  s.source       = { :git => "https://github.com/wokalski/Diff.swift.git", :tag => "0.5.3" }

  s.source_files  = "Sources"
end

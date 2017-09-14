Pod::Spec.new do |s|
  s.name         = "Diff"
  s.version      = "0.6"
  s.summary      = "The fastest Diff library written Swift."
  s.homepage     = "https://github.com/tonyarnold/Diff"
  s.description  = <<-DESC
This library generates the differences between `Collection` instances (this includes Strings!).

It uses a fast algorithm `(O((N+M)*D))` to do this.

Also included are utilities for easily applying diffs and patches to `UICollectionView`/`UITableView`.
                   DESC

  s.license = { :type => "MIT", :file => "LICENSE" }
  s.authors = {
    "Tony Arnold" => "tony@thecocoabots.com",
    "Wojtek Czekalski" => "me@wczekalski.com"
  }

  s.source = { :git => "https://github.com/tonyarnold/Diff.git", :tag => "0.6" }
  s.source_files = "Sources/Diff"

  s.platforms = { :ios => "8.0", :osx => "10.10", :tvos => "9.0", :watchos => "3.0" }
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
  s.osx.exclude_files = "Sources/Diff/Diff+UIKit.swift"
  s.watchos.exclude_files = "Sources/Diff/Diff+UIKit.swift"
end

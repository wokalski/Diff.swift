Pod::Spec.new do |s|
  s.name         = "Differ"
  s.version      = "1.2.0"
  s.summary      = "A very fast difference calculation library written in Swift."
  s.homepage     = "https://github.com/tonyarnold/Diff"
  s.description  = <<-DESC
Differ generates the differences between `Collection` instances (this includes Strings!).

It uses a fast algorithm `(O((N+M)*D))` to do this.

Also included are utilities for easily applying diffs and patches to `UICollectionView`/`UITableView`.
                   DESC

  s.license = { :type => "MIT", :file => "LICENSE.md" }
  s.authors = {
    "Tony Arnold" => "tony@thecocoabots.com"
  }

  s.source = { :git => "https://github.com/tonyarnold/Differ.git", :tag => "1.2.0" }
  s.source_files = "Sources/Differ"

  s.platforms = { :ios => "8.0", :osx => "10.11", :tvos => "9.0", :watchos => "3.0" }
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }
  s.ios.exclude_files = [
    "Sources/Differ/Diff+AppKit.swift"
  ]
  s.osx.exclude_files = [
    "Sources/Differ/Diff+UIKit.swift"
  ]
  s.tvos.exclude_files = [
    "Sources/Differ/Diff+AppKit.swift"
  ]
  s.watchos.exclude_files = [
    "Sources/Differ/Diff+UIKit.swift",
    "Sources/Differ/Diff+AppKit.swift",
    "Sources/Differ/NestedBatchUpdate.swift"
  ]
end

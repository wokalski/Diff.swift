Pod::Spec.new do |s|
  s.name         = "Diffy"
  s.version      = "1.0"
  s.summary      = "A very fast difference calculation library written in Swift."
  s.homepage     = "https://github.com/tonyarnold/Diff"
  s.description  = <<-DESC
Diffy generates the differences between `Collection` instances (this includes Strings!).

It uses a fast algorithm `(O((N+M)*D))` to do this.

Also included are utilities for easily applying diffs and patches to `UICollectionView`/`UITableView`.
                   DESC

  s.license = { :type => "MIT", :file => "LICENSE.md" }
  s.authors = {
    "Tony Arnold" => "tony@thecocoabots.com"
  }

  s.source = { :git => "https://github.com/tonyarnold/Diffy.git", :tag => "1.0" }
  s.source_files = "Sources/Diffy"

  s.platforms = { :ios => "8.0", :osx => "10.10", :tvos => "9.0", :watchos => "3.0" }
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
  s.osx.exclude_files = "Sources/Diffy/Diff+UIKit.swift"
  s.watchos.exclude_files = "Sources/Diffy/Diff+UIKit.swift"
end

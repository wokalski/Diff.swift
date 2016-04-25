//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

let viewController = GraphViewController(string1: "Playground", string2: "Playful")
viewController.view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
XCPlaygroundPage.currentPage.liveView = viewController.view

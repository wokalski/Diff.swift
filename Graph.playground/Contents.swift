//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let viewController = GraphViewController(string1: "kitten", string2: "sitting")
viewController.view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
PlaygroundPage.current.liveView = viewController.view

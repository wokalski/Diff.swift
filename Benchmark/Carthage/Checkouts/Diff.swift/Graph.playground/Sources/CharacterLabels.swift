//
//  CharacterLabels.swift
//  Graph
//
//  Created by Wojciech Czekalski on 25.03.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import UIKit

public extension String {
    func length() -> Int {
        return lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    }
    
    func characterLabels(withFrames frames: [CGRect]) -> [UILabel] {
        let characters = self.characters
        
        guard characters.count == frames.count else {
            return []
        }
        
        let labels = characters.map { $0.label() }
        let sizes = labels.map { $0.frame.size }
        let frames = inset(rects: frames, to: sizes)
        zip(labels, frames).forEach { label, frame in label.frame = frame }
        return labels
    }
}

extension Character {
    func label() -> UILabel {
        let l = UILabel()
        l.textColor = .whiteColor()
        l.text = String(self)
        l.sizeToFit()
        return l
    }
}

func inset(rects rects:[CGRect], to: [CGSize]) -> [CGRect] {
    return zip(to, rects).map { size, rect -> CGRect in
        return rect.inset(to: size)
    }
}

extension CGRect {
    func inset(to size: CGSize) -> CGRect {
        return CGRectStandardize(CGRectInset(self, (self.width-size.width)/2, (self.height-size.height)/2))
    }
}

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
        return lengthOfBytes(using: String.Encoding.utf8)
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
        l.textColor = .white
        l.text = String(self)
        l.sizeToFit()
        return l
    }
}

func inset(rects: [CGRect], to: [CGSize]) -> [CGRect] {
    return zip(to, rects).map { size, rect -> CGRect in
        rect.inset(to: size)
    }
}

extension CGRect {
    func inset(to size: CGSize) -> CGRect {
        return insetBy(dx: (width - size.width) / 2, dy: (height - size.height) / 2).standardized
    }
}

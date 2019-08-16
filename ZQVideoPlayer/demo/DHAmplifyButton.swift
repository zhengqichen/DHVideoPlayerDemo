//
//  DHPlayerButton.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/13.
//  Copyright © 2019 CZQ. All rights reserved.
//

import UIKit

class DHAmplifyButton: UIButton {
    /// 扩大button点击范围
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin:CGFloat = -20
        let clickArea = bounds.insetBy(dx: margin, dy: margin)
        return clickArea.contains(point)
    }
}

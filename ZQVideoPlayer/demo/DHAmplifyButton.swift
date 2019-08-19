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


/*** 回调处理点击事件的 UIButton */
class DHButton: UIButton {
    typealias btnClickBlock = (UIButton)->Void
    private var btnClick : btnClickBlock!

    override  init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(selfClick(_ : )), for: .touchUpInside)
    }

    @objc func selfClick(_ btn:UIButton) {
        if self.btnClick != nil {
            self.btnClick(self)
        }
    }
    /** button点击事件*/
    func dh_ButtonClick(_ btnClick:@escaping btnClickBlock){
        self.btnClick = btnClick
    }
    
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

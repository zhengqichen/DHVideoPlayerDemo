//
//  Const.swift
//  DHApp
//
//  Created by DH on 2019/4/18.
//  Copyright © 2019 CZQ. All rights reserved.
//

import UIKit
import StoreKit
import CoreTelephony
import SafariServices


/**********************************************************************************************/
let kWidth = UIScreen.main.bounds.width
let kHeight = UIScreen.main.bounds.height
let kTabBarHeight:CGFloat  = DHConst.deviceTabBarHeight()
let kNaviBarHeight:CGFloat = DHConst.deviceNaviBarHeight()
let kStatusBarHeight:CGFloat = kNaviBarHeight - 44
/**********************************************************************************************/
/// 相对宽度（设计图）
func W(_ width:CGFloat) -> CGFloat {
    let  r = kWidth*1.0/750
    return width*r
}

/// 相对高度（设计图）
func H(_ height:CGFloat) -> CGFloat {
    let  r = kHeight*1.0/1334
    return height*r
}
/// 服务器域名
let BASE_URL = "http://goo.seegif.com"
/// 服务器域名
let BASEIMAGE_URL = "http://goo.static.seegif.com/"


/// MARK- 导航栏和容器栏
struct  DHConst{
    /// 获取设备导航栏高度
    static func  deviceNaviBarHeight() -> CGFloat{
        var tempNaviHeight:CGFloat!
        switch kHeight {
        case 812.0,896.0:
            tempNaviHeight = 88.0
            break
        default:
            tempNaviHeight = 64.0
            break
        }
        return tempNaviHeight
    }
    
    /// 获取设TabBar高度
    static func  deviceTabBarHeight() -> CGFloat{
        var tempTabBarHeight:CGFloat!
        switch kHeight {
        case 812.0,896.0:
            tempTabBarHeight = 83.0
            break
        default:
            tempTabBarHeight = 49.0
            break
        }
        return tempTabBarHeight
    }
}



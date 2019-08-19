//
//  DHMediaTool.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/12.
//  Copyright © 2019 CZQ. All rights reserved.
//

import UIKit
/// 媒体信息实体
class DHMdeiaInfoMapEntry:NSObject {
    //标识
    var ident:String = ""
    //当前时间
    var current:TimeInterval = 0
    //总时长
    var total:TimeInterval = 0
}

class DHMediaTool: NSObject {
    var mapper:Dictionary<String,DHMdeiaInfoMapEntry> = Dictionary()
    /// 静态单例
    static let shared:DHMediaTool = DHMediaTool()
    /// 记录暂停
    func record(ident:String,current:TimeInterval,total:TimeInterval) {
        //是否忽略(余时3秒内不在记录)
        let ignored = current > total - 3
        if let element = mapper[ident] {
            if ignored {
                remove(ident: ident)
            }else {
                element.current = current
                mapper[ident] = element
            }
        }else {
            //不能忽略
            if !ignored {
                let element = DHMdeiaInfoMapEntry()
                element.ident = ident
                element.current = current
                element.total = total
                mapper[ident] = element
            }
        }
    }
    
    /// 上次中断时间，如果是新资源，返回-1
    func lastBreakTime(ident:String) ->TimeInterval{
        if let element = mapper[ident] {
            if element.current > 1 {
                return element.current - 1
            }
        }
        return -1
    }
    
    /// 移除一项标识
    func remove(ident:String){
        mapper.removeValue(forKey: ident);
    }
}

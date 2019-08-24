//
//  DHPlayerViewDelegate.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/12.
//  Copyright © 2019 CZQ. All rights reserved.
//

import Foundation

protocol DHPlayerViewDelegate:NSObjectProtocol {

    /// 当视频播放时
    ///
    /// - Parameter player: player description
    func onPlay(player:DHPlayerView)

    /// 当播放被暂停
    ///
    /// - Parameter player: player description
    func onPause(player:DHPlayerView)

    /// 当播放被停止
    ///
    /// - Parameter player: player description
    func onStop(player:DHPlayerView)

    /// 当视频播放出现错误
    ///
    /// - Parameter player: player description
    func onError(player:DHPlayerView)
}

/// 包装层代理
protocol DHPlayerWrapDelegate: NSObjectProtocol {

    /// 当视频播放时
    ///
    /// - Parameter player: player description
    func onPlay()
    
    /// 当播放被暂停
    ///
    /// - Parameter player: player description
    func onPause()
    
    /// 当播放被停止
    ///
    /// - Parameter player: player description
    func onStop()
    
    /// 当视频播放出现错误
    ///
    /// - Parameter player: player description
    func onError()
}



//  ViewController.swift
//  ZQVideoPlayer
//
//  Created by 雷丹 on 2019/8/16.
//  Copyright © 2019 CZQ. All rights reserved.


import UIKit
/// 视频操作区
import AssetsLibrary
import AVKit
import MobileCoreServices
class ViewController: UIViewController{
    /**懒加载列表控件*/
    private lazy var tableView:UITableView = {
        // FireOrg滚动控件
        let frame = CGRect(x: 0, y: 40, width: view.frame.width, height: view.frame.height-40)
        let table = UITableView(frame: frame, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = UIColor.white
        // FireOrg注册cell
        return table
    }()
    var cellDatas = [String]()
    var selectedIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        cellDatas = ["net","location"]
        view.addSubview(tableView)
    }
    
    //  拍照或者选择
    func pickerVideo(){
        //判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //表示操作为进入系统相册
            picker.sourceType = .photoLibrary
            //允许用户编辑选择的图片
            picker.allowsEditing = true
            //只显示视频类型的文件
            picker.mediaTypes = [kUTTypeMovie as String]
            //弹出控制器，显示界面
            present(picker, animated: true, completion: nil)
        }else{
            print("没有权限操作")
        }
    }
    
    
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = cellDatas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        if selectedIndex == 1 {
            let alert = UIAlertController(title: "选取视频?", message: "从相册选中视频进行播放", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .cancel) { (action) in}
            let ok = UIAlertAction(title: "选取", style: .default) { (action) in
                self.pickerVideo()
            }
            alert.addAction(cancel)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }else{
            let vc = DHVideoViewController()
            guard let resource  = URL(string: "http://video.pearvideo.com/mp4/adshort/20190808/cont-1587931-14237006_adpkg-ad_sd.mp4") else { return  }
            let posterImageString  = "http://goo.image.seegif.com/i/190812/100338334876.png"
            let title  = "网络视频"
            vc.setResourceDataForNet(resource: resource, title: title, posterImageString: posterImageString)
            self.present(vc, animated: true, completion: nil)
        }
    }
}


extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    /// 选择视频上传
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let videoURL = info[UIImagePickerController.InfoKey.mediaURL],videoURL is URL {
                //                let pathString = videoURL.relativePath
                let videoURL = videoURL as! URL
                let vc = DHVideoViewController()
                let posterImage = self.thumbnailImageForVideo(videoURL: videoURL)
                vc.setResourceDataForLocation(resource: videoURL, title: "本地视频", posterImage: posterImage)
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    /// 生成封面
    func thumbnailImageForVideo(videoURL:URL) -> UIImage{
        let avAsset = AVAsset(url: videoURL)
        //生成视频截图
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0,preferredTimescale: 600)
        var actualTime:CMTime = CMTimeMake(value: 0,timescale: 0)
        let imageRef:CGImage = try! generator.copyCGImage(at: time, actualTime: &actualTime)
        return UIImage(cgImage: imageRef)
    }
}


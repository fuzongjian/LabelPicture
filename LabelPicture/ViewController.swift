//
//  ViewController.swift
//  LabelPicture
//
//  Created by 付宗建 on 2018/4/24.
//  Copyright © 2018年 youran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
    let SCREENWIDTH = UIScreen.main.bounds.size.width
    let SCREENHEIGHT = UIScreen.main.bounds.size.height
    lazy var labelPicture = { return LabelPictureView(frame: CGRect(x: 0, y: 0, width: SCREENWIDTH, height: 300)) }()
    lazy var displayImage = { return UIImageView(frame: CGRect(x: 10, y: SCREENHEIGHT*0.5+160, width: 200, height: SCREENHEIGHT*0.5-170)) }()
    override func viewDidLoad() {
        super.viewDidLoad()
        labelPicture.center = view.center
        labelPicture.backgroundColor = UIColor.white
        labelPicture.imageName = "test"
        view.addSubview(labelPicture)
        
        
        
        let reset = UIButton(type: .system)
        reset.frame = CGRect(x: 0, y: 100, width: SCREENWIDTH/3, height: 40)
        
        reset.setTitle("下一个", for: .normal)
        reset.addTarget(self, action: #selector(resetButtonClicked(_:)), for: .touchUpInside)
        view.addSubview(reset)
        
        
        let reset1 = UIButton(type: .system)
        reset1.frame = CGRect(x: SCREENWIDTH/3, y: 100, width: SCREENWIDTH/3, height: 40)
        
        reset1.setTitle("完成", for: .normal)
        reset1.addTarget(self, action: #selector(finish(_:)), for: .touchUpInside)
        view.addSubview(reset1)
        
        
        
        let reset2 = UIButton(type: .system)
        reset2.frame = CGRect(x: SCREENWIDTH*2/3, y:100, width: SCREENWIDTH/3, height: 40)
        
        reset2.setTitle("获取图片", for: .normal)
        reset2.addTarget(self, action: #selector(getImage(_:)), for: .touchUpInside)
        view.addSubview(reset2)
        
        displayImage.contentMode = .scaleAspectFit
        view.addSubview(displayImage)
        
    }
    @objc func resetButtonClicked(_ sender: UIButton) -> Void {
        labelPicture.saveAndNext()
    }
    @objc func finish(_ sender: UIButton) -> Void {
        print("\(labelPicture.finishDraw())")
    }
    @objc func getImage(_ sender: UIButton) ->Void{
        labelPicture.getPicture { (frame, image) -> () in
            print("\(frame)---\(image)")
            self.displayImage.image = image
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  ViewController.swift
//  LabelPicture
//
//  Created by 付宗建 on 2018/4/24.
//  Copyright © 2018年 youran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var labelPicture = { return LabelPictureView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 300)) }()
    override func viewDidLoad() {
        super.viewDidLoad()
        labelPicture.center = view.center
        labelPicture.backgroundColor = UIColor.white
        labelPicture.imageName = "test"
        view.addSubview(labelPicture)
        
        let reset = UIButton(type: .system)
        reset.frame = CGRect(x: 0, y: 100, width: 100, height: 40)
        reset.center.x = view.center.x
        reset.setTitle("下一个", for: .normal)
        reset.addTarget(self, action: #selector(resetButtonClicked(_:)), for: .touchUpInside)
        view.addSubview(reset)
        
        
        let reset1 = UIButton(type: .system)
        reset1.frame = CGRect(x: 0, y: 150, width: 100, height: 40)
        reset1.center.x = view.center.x
        reset1.setTitle("完成", for: .normal)
        reset1.addTarget(self, action: #selector(finish(_:)), for: .touchUpInside)
        view.addSubview(reset1)
    }
    @objc func resetButtonClicked(_ sender: UIButton) -> Void {
        labelPicture.saveAndNext()
    }
    @objc func finish(_ sender: UIButton) -> Void {
        print("\(labelPicture.finishDraw())")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


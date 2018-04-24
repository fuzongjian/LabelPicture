//
//  ViewController.swift
//  LabelPicture
//
//  Created by 付宗建 on 2018/4/24.
//  Copyright © 2018年 youran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var pictureView = { return PictureView() }()
    override func viewDidLoad() {
        super.viewDidLoad()
        pictureView.frame = CGRect(x: 0, y: 0, width: 240, height: 300)
        pictureView.center = view.center
        pictureView.backgroundColor = UIColor.gray
        view.addSubview(pictureView)
        
        let reset = UIButton(type: .system)
        reset.frame = CGRect(x: 0, y: 100, width: 100, height: 40)
        reset.center.x = view.center.x
        reset.setTitle("下一个", for: .normal)
        reset.addTarget(self, action: #selector(resetButtonClicked(_:)), for: .touchUpInside)
        view.addSubview(reset)
    }
    @objc func resetButtonClicked(_ sender: UIButton) -> Void {
       
        pictureView.saveAndNext()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


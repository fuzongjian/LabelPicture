//
//  LabelPictureView.swift
//  LabelPicture
//
//  Created by 付宗建 on 2018/4/25.
//  Copyright © 2018年 youran. All rights reserved.
//

import UIKit
typealias BlcokImage = () -> (CGRect,UIImage)
class LabelPictureView: UIView,UIScrollViewDelegate {
    var imageName : String? {
        willSet{}
        didSet{
            imageScrollView.zoomScale = 1.0
            imageView.image = UIImage(named: imageName!)
            
            guard let size =  imageView.image?.size else { return }
            // 获取缩小系数
            scale = self.frame.width / size.width * size.height < self.frame.height ? self.frame.width / size.width : self.frame.height / size.height
            // 添加蒙版
            originX = (self.frame.width-scale!*size.width)*0.5
            originY = (self.frame.height-scale!*size.height)*0.5
            let frame = CGRect(x: originX!, y: originY!, width: size.width*scale!, height: size.height*scale!)
            overPictureView = PictureView(frame: frame)
            self.addSubview(overPictureView!)
            
        }
    }
    private lazy var imageScrollView = { return UIScrollView() }() // 容器
    private lazy var imageView = { return UIImageView() }()  // 要标注的图片
    private lazy var rectArray = { return NSMutableArray() }()
    private lazy var colorArray = { return NSMutableArray() }()
    private  var overPictureView :PictureView?
    var originX : CGFloat?
    var originY : CGFloat?
    var scale : CGFloat?
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func saveAndNext() -> Void {
        guard let rect = overPictureView?.currentRect else { return }
        print("\(rectArray)")
        // 排除空的数值以及重复保存问题
        if rect == CGRect.zero || rectArray.contains(rect) == true{
            print("请开始画图")
            drawImage()
            overPictureView?.saveAndNext()
            return
        }
        rectArray.add(rect)
        colorArray.add(randomColor())
        // 画图
        drawImage()
        // 再次初始化蒙版
        overPictureView?.saveAndNext()
    }
    public func getPicture(complete: @escaping((CGRect,UIImage) ->())) -> Void{
        // 这里只截取第一张
        if rectArray.count != 0 {
            print("origin image size \(String(describing: imageView.image?.size))")
            var frame = rectArray[0] as! CGRect
            frame.origin.x /= scale!
            frame.origin.y /= scale!
            frame.size.width /= scale!
            frame.size.height /= scale!
            
            UIGraphicsBeginImageContext((frame.size))
            imageView.image?.draw(in: CGRect(x: -frame.minX, y: -frame.minY, width: (imageView.image?.size.width)!, height: (imageView.image?.size.height)!))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            complete(frame,newImage!)
        }
    }
    
    public func finishDraw() -> NSMutableArray {
        // 保存最后一个标注信息
        let rect = overPictureView?.currentRect
        if rect != CGRect.zero && rectArray.contains(rect!) == false {
            rectArray.add(rect!)
            colorArray.add(randomColor())
            drawImage()
            overPictureView?.saveAndNext()
        }
        if rectArray.count == 0 { return NSMutableArray() }
        let resultArray = NSMutableArray()
        for (_,value) in rectArray.enumerated() {
            var newRect = value as! CGRect
            newRect.origin.x /= scale!
            newRect.origin.y /= scale!
            newRect.size.width /= scale!
            newRect.size.height /= scale!
            resultArray.add(newRect)
        }
        return resultArray
    }
    private func configUI() -> Void {
        // 容器
        imageScrollView.frame = self.bounds
        imageScrollView.delegate = self
        // 放大缩小倍数
        imageScrollView.maximumZoomScale = 2
        imageScrollView.minimumZoomScale = 1
        imageScrollView.bounces = false
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.showsVerticalScrollIndicator = false
        // 图片
        imageView.frame = imageScrollView.bounds
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        imageScrollView.contentSize = imageView.frame.size
        imageScrollView.addSubview(imageView)
        imageView.center = imageScrollView.center
        self.addSubview(imageScrollView)
    }
    // scroll  预留之后扩展伸缩
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offSetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0
        // 放大之后，需要更新图片的中心点
        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offSetY)
    }
    private func drawImage() -> Void {
        for (index,value) in rectArray.enumerated(){
            let layer = CALayer()
            let color = colorArray.object(at: index) as! UIColor
            layer.borderColor = color.cgColor
            layer.borderWidth = 2
            var newRect = value as! CGRect
            newRect.origin.x += originX!
            newRect.origin.y += originY!
            layer.frame = newRect
            imageView.layer.addSublayer(layer)
        }
    }
    // 随机颜色
    private func randomColor() -> UIColor {
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

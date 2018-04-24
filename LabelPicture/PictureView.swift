//
//  PictureView.swift
//  LabelPicture
//
//  Created by 付宗建 on 2018/4/24.
//  Copyright © 2018年 youran. All rights reserved.
//

import UIKit
enum PanningMode {
    case none
    case left
    case right
    case top
    case bottom
    case topLeft
    case bottomLeft
    case topRight
    case bottomRight
}
class PictureView: UIView {
    /*************************** 配置相关***********************/
    let RATE: CGFloat = 40 // 灵敏度
    var panningMode: PanningMode = .none
    lazy var currentRect = {return CGRect(x: 20, y: 20, width: 150, height: 150) }() // 当前的操作的矩形框
    lazy var currentPoint = {return CGPoint() }() // 记录第一次触摸点
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 手势添加
        addGesture()
        // 关闭多点触摸
        self.isMultipleTouchEnabled = false
        
        let topLeft = UIView()
        topLeft.frame = topLeftCorner
        topLeft.backgroundColor = UIColor.red
        self.addSubview(topLeft)
        
        let topRight = UIView()
        topRight.frame = topRightCorner
        topRight.backgroundColor = UIColor.yellow
        self.addSubview(topRight)
        
        let bottomLeft = UIView()
        bottomLeft.frame = bottomLeftCorner
        bottomLeft.backgroundColor = UIColor.blue
        self.addSubview(bottomLeft)
        
        let bottomRight = UIView()
        bottomRight.frame = bottomRightCorner
        bottomRight.backgroundColor = UIColor.green
        self.addSubview(bottomRight)
        
        let center = UIView()
        center.frame = centerRect
        center.backgroundColor = UIColor.black
        self.addSubview(center)
        
        let ee = UIView()
        ee.frame = bottomEdgeRect
        ee.backgroundColor = UIColor.brown
        self.addSubview(ee)
    }
    override func draw(_ rect: CGRect) {
        //创建一个画布,用于将我们所画的东西在这个上面展示出来
        let context = UIGraphicsGetCurrentContext()
        //画一个矩形
        context?.addRect(currentRect)
//        context?.setFillColor(red: 1, green: 0, blue: 0, alpha: 1)
//        context?.fillPath()
        //边框宽度
        context?.setLineWidth(2)
        //边框颜色
        context?.setStrokeColor(red: 0, green: 1, blue: 0, alpha: 1)
        context?.stroke(currentRect)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // 记录第一个触摸点
        if touches.count == 1{
            guard let p = touches.first?.location(in: self)else{ return }
            currentPoint = p
        }
    }
    // 添加手势
    func addGesture() -> Void {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureClick(_:)))
        self.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureClick(_:)))
        pan.maximumNumberOfTouches = 1
        self.addGestureRecognizer(pan)
    }
    @objc func tapGestureClick(_ sender: UITapGestureRecognizer) -> Void {
        print("tap\(currentRect)")
    }
    @objc func panGestureClick(_ sender: UIPanGestureRecognizer) -> Void {
        // 在这里应该先判断在那个区域，然后在根据情况进行拉长或收缩
        let point = sender.location(in: self)
        if isInCenterContainsPoint(point) {// 整体移动
            panCenter(sender)
        } else if isCornerContainsPoint(point){// 边角处移动
            panningMode = getPannigModeByPoint(point)
            panCorner(sender)
        }else if isEdgeContainsPoint(point){ // 边边移动
            panningMode = getPannigModeByPoint(point)
            panEdge(sender)
        }
   
        
//        sender.setTranslation(CGPoint.zero, in: self)
        
    }
    func panCorner(_ sender: UIPanGestureRecognizer) -> Void {
        if panningMode == .topLeft {
            print("topLeft")
        }else if panningMode == .topRight{
            print("topRight")
        }else if panningMode == .bottomLeft {
            print("bottomLeft")
        }else{
            print("bottomRight")
        }
    }
    func panEdge(_ sender: UIPanGestureRecognizer) -> Void {
        var new_currentRect = currentRect
        let point = sender.translation(in: self)
        print("point === \(point)")
        if panningMode == .top || panningMode == .bottom {
            print("top-bottom")
            if(new_currentRect.maxY < self.frame.height){
                new_currentRect.size.height += point.y
            }else{
                new_currentRect.size.height = self.frame.height - new_currentRect.minY
            }
        }else if panningMode == .bottom {
            print("bottom---1\(currentRect)")
            if(new_currentRect.maxY < self.frame.height){
                new_currentRect.size.height += point.y
            }else{
                new_currentRect.size.height = self.frame.height - new_currentRect.minY
            }
            currentRect = new_currentRect
            print("bottom---2\(currentRect)")
        }else if panningMode == .left {
            print("left")
        }else if panningMode == .right {
            print("right")
        }
        setNeedsDisplay()
    }
    func panCenter(_ sender: UIPanGestureRecognizer) -> Void {
        print("center")
        return
        print("\(self.frame.width)---\(currentRect.minX)")
        let point = sender.translation(in: self)
        currentRect.origin.x += point.x
        currentRect.origin.y += point.y
        
        if currentRect.minX < self.bounds.minX {
            currentRect.origin.x = self.bounds.minX
        }else if currentRect.maxX > self.frame.width {
            currentRect.size.width = self.frame.width - currentRect.origin.x
        }
        
        if currentRect.minY < self.bounds.minY {
            currentRect.origin.y = self.frame.minY
        }else if currentRect.maxY > self.frame.height{
            currentRect.size.height = self.frame.height - currentRect.origin.y
        }
        
        print("\(point)")
        setNeedsDisplay()
    }
    // 画出来的框框不能超过大框框
    func isDrawRect() -> Bool {
        return self.frame.size.width > currentRect.maxX+2 && self.frame.size.height > currentRect.maxY+2
    }
    // 判断触摸的点是否在四个角落
    func isCornerContainsPoint(_ point: CGPoint) -> Bool {
        return topLeftCorner.contains(point) || topRightCorner.contains(point) || bottomLeftCorner.contains(point) || bottomRightCorner.contains(point)
    }
    func isEdgeContainsPoint(_ point: CGPoint) -> Bool {
        return topEdgeRect.contains(point) || bottomEdgeRect.contains(point) || leftEdgeRect.contains(point) || rightEdgeRect.contains(point)
    }
    func isInCenterContainsPoint(_ point: CGPoint) -> Bool {
        return centerRect.contains(point)
    }
    // 获得手势状态
    func getPannigModeByPoint(_ point: CGPoint) -> PanningMode {
        if topLeftCorner.contains(point){
            return .topLeft
        }else if topRightCorner.contains(point){
            return .topRight
        }else if bottomLeftCorner.contains(point){
            return .bottomLeft
        }else if bottomRightCorner.contains(point){
            return .bottomRight
        }else if topEdgeRect.contains(point){
            return .top
        }else if bottomEdgeRect.contains(point){
            return .bottom
        }else if leftEdgeRect.contains(point){
            return .left
        }else if rightEdgeRect.contains(point){
            return .right
        }
        return .none
    }
    // lazy load
    /*****************************************四个角****************************************/
    lazy var topLeftCorner = {
        return CGRect(x: currentRect.minX - RATE / 2, y: currentRect.minY - RATE / 2, width: RATE, height: RATE)
    }()
    lazy var topRightCorner = {
        return CGRect(x: currentRect.maxX - RATE / 2, y: currentRect.minY - RATE / 2, width: RATE, height: RATE)
    }()
    lazy var bottomLeftCorner = {
        return CGRect(x: currentRect.minX - RATE / 2, y: currentRect.maxY - RATE / 2, width: RATE, height: RATE)
    }()
    lazy var bottomRightCorner = {
        return CGRect(x: currentRect.maxX - RATE / 2, y: currentRect.maxY - RATE / 2, width: RATE, height: RATE)
    }()
    /*****************************************四条边****************************************/
    lazy var topEdgeRect = {
        return CGRect(x: RATE, y: 0, width: currentRect.width - RATE, height: RATE)
    }()
    lazy var bottomEdgeRect = {
        return CGRect(x: RATE, y: currentRect.height, width: currentRect.width - RATE, height: RATE)
    }()
    lazy var leftEdgeRect = {
        return CGRect(x: 0, y: RATE, width: RATE, height: currentRect.height - RATE)
    }()
    lazy var rightEdgeRect = {
        return CGRect(x: currentRect.width, y: RATE, width: RATE, height: currentRect.height - RATE)
    }()
    /*****************************************中间区域****************************************/
    lazy var centerRect = {
        return CGRect(x: RATE , y: RATE, width: currentRect.width - RATE, height: currentRect.height - RATE)
    }()
}

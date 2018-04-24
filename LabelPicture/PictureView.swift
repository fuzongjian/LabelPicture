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
    let RATE: CGFloat = 30 // 灵敏度
    var isInitStart = false // 首个坐标初始化
    let LINEWIDTH: CGFloat = 2 // 线的宽度
    var panningMode: PanningMode = .none // 手指所点的区域
    lazy var rectArray = { return NSMutableArray() }() // 记录所画框的坐标
    lazy var colorArray = { return NSMutableArray() }() // 记录随机颜色
    lazy var currentRect = {return CGRect() }() // 当前的操作的矩形框
    lazy var currentPoint = {return CGPoint() }() // 记录第一次触摸点
    lazy var testView = { return UIView() }()
    lazy var bottomLeft = { return UIView() }()
    lazy var bottomRight = { return UIView() }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 手势添加
        addGesture()
        // 关闭多点触摸
        self.isMultipleTouchEnabled = false
    }
    override func draw(_ rect: CGRect) {
        //创建一个画布,用于将我们所画的东西在这个上面展示出来
        let context = UIGraphicsGetCurrentContext()
        //边框宽度
        context?.setLineWidth(LINEWIDTH)
        if rectArray.count != 0 {
            for (index,value) in rectArray.enumerated(){
                context?.addRect(value as! CGRect)
                let color = colorArray.object(at: index) as! UIColor
                context?.setStrokeColor(color.cgColor)
                context?.stroke(value as! CGRect)
            }
        }
        //画一个矩形
        context?.addRect(currentRect)
        //边框颜色
        context?.setStrokeColor(red: 0, green: 1, blue: 0, alpha: 1)
        context?.stroke(currentRect)

    }
    // 保存当前并开始下一个
    public func saveAndNext() -> Void {
        print("save --- next")
        rectArray.add(currentRect)
        colorArray.add(randomColor())
        // 重置初始化状态
        isInitStart = false
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
            if isInitStart == false{
                currentRect = CGRect(origin: p, size: CGSize(width: 30, height: 30))
                isInitStart = true
            }
            
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
        // 非常重要
        sender.setTranslation(CGPoint.zero, in: self)
        
    }
    private func panCorner(_ sender: UIPanGestureRecognizer) -> Void {
        var new_currentRect = currentRect
        let point = sender.translation(in: self)
        if panningMode == .topLeft {
            if new_currentRect.maxX < self.bounds.width{
                new_currentRect.origin.x += point.x
                new_currentRect.size.width -= point.x
            }
            if new_currentRect.maxY < self.bounds.height{
                new_currentRect.origin.y += point.y
                new_currentRect.size.height -= point.y
            }
            currentRect = new_currentRect
        }else if panningMode == .topRight{
            if new_currentRect.maxX < self.bounds.width{
                new_currentRect.size.width += point.x
            }
            if new_currentRect.maxY < self.bounds.height{
                new_currentRect.origin.y += point.y
                new_currentRect.size.height -= point.y
            }
            currentRect = new_currentRect
        }else if panningMode == .bottomLeft {
            if new_currentRect.maxX < self.bounds.width{
                new_currentRect.origin.x += point.x
                new_currentRect.size.width -= point.x
            }
            if new_currentRect.maxY < self.bounds.height{
                new_currentRect.size.height += point.y
            }
            currentRect = new_currentRect
        }else{
            if new_currentRect.maxX < self.bounds.width{
                new_currentRect.size.width += point.x
            }
            if new_currentRect.maxY < self.bounds.height{
                new_currentRect.size.height += point.y
            }
            currentRect = new_currentRect
        }
        if isRevertX() == true {
            new_currentRect.size.width = self.frame.width - new_currentRect.minX - LINEWIDTH
            currentRect = new_currentRect
        }
        if isRevertY() == true {
            new_currentRect.size.height = self.frame.height - new_currentRect.minY - LINEWIDTH
            currentRect = new_currentRect
        }
        setNeedsDisplay()
    }
    private func panEdge(_ sender: UIPanGestureRecognizer) -> Void {
        var new_currentRect = currentRect
        let point = sender.translation(in: self)
        
        if panningMode == .top{
            if(new_currentRect.maxY < self.frame.height){
                new_currentRect.origin.y += point.y
                new_currentRect.size.height -= point.y
            }else{
                new_currentRect.size.height = self.frame.height - new_currentRect.minY + LINEWIDTH
            }
            currentRect = new_currentRect
        }else if panningMode == .bottom {
            if new_currentRect.maxY < self.frame.height{
                new_currentRect.size.height += point.y
            }else{
                new_currentRect.size.height = self.frame.height - new_currentRect.minY - LINEWIDTH
            }
            currentRect = new_currentRect
        }else if panningMode == .left {
            if new_currentRect.maxX < self.frame.width{
                new_currentRect.origin.x += point.x
                new_currentRect.size.width -= point.x
            }else{
                new_currentRect.size.width = self.frame.width - new_currentRect.minX - LINEWIDTH
            }
            currentRect = new_currentRect
        }else if panningMode == .right {
            if new_currentRect.maxX < self.frame.width{
                new_currentRect.size.width += point.x
            }else{
                new_currentRect.size.width = self.frame.width - new_currentRect.minX - LINEWIDTH
            }
            currentRect = new_currentRect
        }
        if isRevertX() == true {
            new_currentRect.size.width = self.frame.width - new_currentRect.minX - LINEWIDTH
            currentRect = new_currentRect
        }
        if isRevertY() == true {
            new_currentRect.size.height = self.frame.height - new_currentRect.minY - LINEWIDTH
            currentRect = new_currentRect
        }
        setNeedsDisplay()
    }
    private func panCenter(_ sender: UIPanGestureRecognizer) -> Void {
        var new_currentRect = currentRect
        let point = sender.translation(in: self)
        guard new_currentRect.minY > 0 else {
            new_currentRect.origin.y = LINEWIDTH
            currentRect = new_currentRect
            setNeedsDisplay()
            return
        }
        currentRect.origin.x += point.x
        currentRect.origin.y += point.y
        if isRevertX() == true{
            new_currentRect.size.width = self.frame.width - new_currentRect.minX - LINEWIDTH
            currentRect = new_currentRect
        }
        if isRevertY() == true {
            new_currentRect.size.height = self.frame.height - new_currentRect.minY - LINEWIDTH
            currentRect = new_currentRect
        }
        setNeedsDisplay()
    }
    // 画出来的框框不能超过大框框
    private func isRevertX() -> Bool {
        overHidden()
        return self.currentRect.maxX > self.frame.width
    }
    private func isRevertY() -> Bool {
        overHidden()
        return self.currentRect.maxY > self.frame.height
    }
    private  func overHidden() -> Void {
        var new_currentRect = currentRect
        if new_currentRect.minY < 0 {
            new_currentRect.origin.y = LINEWIDTH
            currentRect = new_currentRect
        }
        if new_currentRect.minX < 0 {
            new_currentRect.origin.x = LINEWIDTH
            currentRect = new_currentRect
        }
        setNeedsDisplay()
    }
    // 判断触摸的点是否在四个角落
    private func isCornerContainsPoint(_ point: CGPoint) -> Bool {
        return topLeftCorner().contains(point) || topRightCorner().contains(point) || bottomLeftCorner().contains(point) || bottomRightCorner().contains(point)
    }
    private func isEdgeContainsPoint(_ point: CGPoint) -> Bool {
        return topEdgeRect().contains(point) || bottomEdgeRect().contains(point) || leftEdgeRect().contains(point) || rightEdgeRect().contains(point)
    }
    private func isInCenterContainsPoint(_ point: CGPoint) -> Bool {
        return centerRect().contains(point)
    }
    // 获得手势状态
    private func getPannigModeByPoint(_ point: CGPoint) -> PanningMode {
        if topLeftCorner().contains(point){
            return .topLeft
        }else if topRightCorner().contains(point){
            return .topRight
        }else if bottomLeftCorner().contains(point){
            return .bottomLeft
        }else if bottomRightCorner().contains(point){
            return .bottomRight
        }else if topEdgeRect().contains(point){
            return .top
        }else if bottomEdgeRect().contains(point){
            return .bottom
        }else if leftEdgeRect().contains(point){
            return .left
        }else if rightEdgeRect().contains(point){
            return .right
        }
        return .none
    }
    /*****************************************四个角****************************************/
    private func topLeftCorner() -> CGRect {
        return CGRect(x: currentRect.minX - RATE, y: currentRect.minY - RATE, width: RATE*2, height: RATE*2)
    }
    private func topRightCorner() -> CGRect {
        return CGRect(x: currentRect.maxX - RATE, y: currentRect.minY - RATE, width: RATE*2, height: RATE*2)
    }
    private func bottomLeftCorner() -> CGRect {
        let frame = CGRect(x: currentRect.minX - RATE, y: currentRect.maxY - RATE, width: RATE*2, height: RATE*2)
        bottomLeft.frame = frame
        testView.frame = bottomEdgeRect()
        return frame
    }
    private func bottomRightCorner() -> CGRect {
        let frame = CGRect(x: currentRect.maxX - RATE, y: currentRect.maxY - RATE, width: RATE*2, height: RATE*2)
        bottomRight.frame = frame
        testView.frame = bottomEdgeRect()
        return frame
    }
    /*****************************************四条边****************************************/
    private func topEdgeRect() -> CGRect {
        return CGRect(x: currentRect.minX + RATE, y: currentRect.minY - RATE, width: currentRect.width - RATE*2, height: RATE*2)
    }
    private func bottomEdgeRect() -> CGRect {
        let frame = CGRect(x: currentRect.minX + RATE, y: currentRect.maxY - RATE , width: currentRect.width - RATE*2, height: RATE*2)
        testView.frame = frame
        return frame
    }
    private func leftEdgeRect() -> CGRect {
        return CGRect(x: currentRect.minX - RATE, y: currentRect.minY + RATE, width: currentRect.minY + RATE, height: currentRect.height - RATE*2)
    }
    private func rightEdgeRect() -> CGRect {
        return CGRect(x:currentRect.maxX - RATE, y: currentRect.minY + RATE, width: RATE*2, height: currentRect.height - RATE*2)
    }
    /*****************************************中间区域****************************************/
    private func centerRect() -> CGRect {
        return CGRect(x: currentRect.minX + RATE , y: currentRect.minY + RATE, width: currentRect.width - RATE*2, height: currentRect.height - RATE*2)
    }
    // 随机颜色
    private func randomColor() -> UIColor {
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

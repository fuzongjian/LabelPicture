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
class PictureView: UIView,UIScrollViewDelegate {
    /*************************** 配置相关***********************/
    private let RATE: CGFloat = 20 // 灵敏度
    let MINSIZE : CGSize = CGSize(width: 10, height: 10) // 最小宽度
    lazy var rectArray = { return NSMutableArray() }() // 记录所画框的坐标
    lazy var colorArray = { return NSMutableArray() }() // 记录随机颜色
    let SMALLCIRCLE : CGFloat = 10
    
    private var isInitStart = false // 首个坐标初始化
    private let LINEWIDTH: CGFloat = 2 // 线的宽度
    private var panningMode: PanningMode = .none // 手指所点的区域
    public lazy var currentRect = { return CGRect() }() // 当前的操作的矩形框
    private lazy var currentPoint = {return CGPoint() }() // 记录第一次触摸点
    var oldRect = CGRect.zero
    var topView = UIView()
    var bottomView = UIView()
    var bottomCorner = UIView()
    var bottomLeftCornerView = UIView()
    var topLeftSmall = UIView()
    var topRightSmall = UIView()
    var bottomLeftSmall = UIView()
    var bottomRightSmall = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 关闭多点触摸
        self.isMultipleTouchEnabled = false
        
        self.backgroundColor = UIColor.clear
//        currentRect = CGRect(x: 100, y: 100, width: 150, height: 150)
        
//        topView.backgroundColor = UIColor.blue
//        self.addSubview(topView)
//        bottomView.backgroundColor = UIColor.brown
//        self.addSubview(bottomView)
//        bottomCorner.backgroundColor = UIColor.black
//        self.addSubview(bottomCorner)
//        bottomLeftCornerView.backgroundColor = UIColor.green
//        self.addSubview(bottomLeftCornerView)
        
        self.addSubview(topLeftSmall)
        topLeftSmall.backgroundColor = UIColor.red
        topLeftSmall.layer.cornerRadius = SMALLCIRCLE*0.5;
        topLeftSmall.layer.masksToBounds = true
        
        self.addSubview(topRightSmall)
        topRightSmall.backgroundColor = UIColor.red
        topRightSmall.layer.cornerRadius = SMALLCIRCLE*0.5;
        topRightSmall.layer.masksToBounds = true
        
        self.addSubview(bottomLeftSmall)
        bottomLeftSmall.backgroundColor = UIColor.red
        bottomLeftSmall.layer.cornerRadius = SMALLCIRCLE*0.5;
        bottomLeftSmall.layer.masksToBounds = true
        
        self.addSubview(bottomRightSmall)
        bottomRightSmall.backgroundColor = UIColor.red
        bottomRightSmall.layer.cornerRadius = SMALLCIRCLE*0.5;
        bottomRightSmall.layer.masksToBounds = true
        
//        setRadius()
        
        // 手势添加
        addGesture()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        
        overHidden()
        //创建一个画布,用于将我们所画的东西在这个上面展示出来
        let context = UIGraphicsGetCurrentContext()
        //边框宽度
        context?.setLineWidth(LINEWIDTH)
        //画一个矩形
        context?.addRect(currentRect)
        //边框颜色 默认为红色
        context?.setStrokeColor(red: 1, green: 0, blue: 0, alpha: 1)
        context?.stroke(currentRect)
        
//
//        topView.frame = topEdgeRect()
//        bottomView.frame = bottomEdgeRect()
//
//        bottomCorner.frame = topRightCorner()
//        bottomLeftCornerView.frame = topLeftCorner()
        
        
        if currentRect != CGRect.zero{
            topLeftSmall.frame = topLeft()
            topRightSmall.frame = topRight()
            bottomLeftSmall.frame = bottomLeft()
            bottomRightSmall.frame = bottomRight()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    // 保存当前并开始下一个  同时还需要更新界面
    public func saveAndNext() -> Void {
        currentRect = CGRect.zero
        topLeftSmall.frame = CGRect.zero
        topRightSmall.frame = CGRect.zero
        bottomLeftSmall.frame = CGRect.zero
        bottomRightSmall.frame = CGRect.zero
        setNeedsDisplay()
        // 重置初始化状态
        isInitStart = false
    }
    // touch事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // 记录第一个触摸点
        if touches.count == 1{
            guard let p = touches.first?.location(in: self)else{ return }
            currentPoint = p
            if isInitStart == false{
                currentRect = CGRect(origin: p, size: CGSize(width: 5, height: 5))
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
//        print("tap\(currentRect)")
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
        print("\(panningMode)")
        // 设置手势的偏移量（非常重要）
        sender.setTranslation(CGPoint.zero, in: self)
    }
    // 角运动
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
        }else if panningMode == .topRight{
            if new_currentRect.maxX < self.bounds.width{
                new_currentRect.size.width += point.x
            }
            if new_currentRect.maxY < self.bounds.height{
                new_currentRect.origin.y += point.y
                new_currentRect.size.height -= point.y
            }
        }else if panningMode == .bottomLeft {
            if new_currentRect.maxX < self.bounds.width{
                new_currentRect.origin.x += point.x
                new_currentRect.size.width -= point.x
            }
            if new_currentRect.maxY < self.bounds.height{
                new_currentRect.size.height += point.y
            }
        }else{
            if new_currentRect.maxX < self.bounds.width{
                new_currentRect.size.width += point.x
            }
            if new_currentRect.maxY < self.bounds.height{
                new_currentRect.size.height += point.y
            }
        }
        if isRevertX() == true {
            new_currentRect.size.width = self.frame.width - new_currentRect.minX - LINEWIDTH
        }
        if isRevertY() == true {
            new_currentRect.size.height = self.frame.height - new_currentRect.minY - LINEWIDTH
        }
        if currentRect.width < MINSIZE.width{
            new_currentRect.size.width = MINSIZE.width
        }
        if currentRect.height < MINSIZE.height{
            new_currentRect.size.height = MINSIZE.height
        }
        currentRect = new_currentRect
        setNeedsDisplay()
    }
    // 边运动
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
        }else if panningMode == .left {
            if new_currentRect.maxX < self.frame.width{
                new_currentRect.origin.x += point.x
                new_currentRect.size.width -= point.x
            }else{
                new_currentRect.size.width = self.frame.width - new_currentRect.minX - LINEWIDTH
            }
        }else if panningMode == .right {
            if new_currentRect.maxX < self.frame.width{
                new_currentRect.size.width += point.x
            }else{
                new_currentRect.size.width = self.frame.width - new_currentRect.minX - LINEWIDTH
            }
        }
        if currentRect.width < MINSIZE.width{
            new_currentRect.size.width = MINSIZE.width
        }
        if currentRect.height < MINSIZE.height{
            new_currentRect.size.height = MINSIZE.height
        }
        if isRevertX() == true {
            new_currentRect.size.width = self.frame.width - new_currentRect.minX - LINEWIDTH
        }
        if isRevertY() == true {
            new_currentRect.size.height = self.frame.height - new_currentRect.minY - LINEWIDTH
        }
        currentRect = new_currentRect
        setNeedsDisplay()
    }
    // 中心运动
    private func panCenter(_ sender: UIPanGestureRecognizer) -> Void {
        var new_currentRect = currentRect
        let point = sender.translation(in: self)
        guard new_currentRect.minY >= 0 else {
            new_currentRect.origin.y = 0
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
    // 超出隐藏
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
        if currentRect.width <= RATE * 4 {
            return CGRect(x: currentRect.minX - RATE*2, y: currentRect.minY - RATE*3, width: currentRect.width*0.5+RATE*2, height: RATE*4)
        }
        return CGRect(x: currentRect.minX - RATE*2, y: currentRect.minY - RATE*3, width: RATE*4, height: RATE*4)
    }
    private func topRightCorner() -> CGRect {
        if currentRect.width <= RATE * 4 {
            return CGRect(x: currentRect.maxX - currentRect.width*0.5, y: currentRect.minY - RATE*3, width: currentRect.width*0.5+RATE*2, height: RATE*4)
        }
        return CGRect(x: currentRect.maxX - RATE*2, y: currentRect.minY - RATE*3, width: RATE*4, height: RATE*4)
    }
    private func bottomLeftCorner() -> CGRect {
        if currentRect.width <= RATE * 4 {
            return CGRect(x: currentRect.minX - RATE * 2, y: currentRect.maxY - RATE, width: RATE * 2 + currentRect.width * 0.5, height: RATE * 4)
        }
        return CGRect(x: currentRect.minX - RATE*2, y: currentRect.maxY - RATE, width: RATE*4, height: RATE*4)
    }
    private func bottomRightCorner() -> CGRect {
        if currentRect.width <= RATE * 4 {
            return CGRect(x: currentRect.maxX - currentRect.width*0.5, y: currentRect.maxY - RATE, width: RATE * 4, height: RATE * 4)
        }
        return CGRect(x: currentRect.maxX - RATE*2, y: currentRect.maxY - RATE, width: RATE*4, height: RATE*4)
    }
    /*****************************************四条边****************************************/
    private func topEdgeRect() -> CGRect {
        return CGRect(x: currentRect.minX + RATE*2, y: currentRect.minY - RATE, width: currentRect.width - RATE*4, height: RATE*2)
    }
    private func bottomEdgeRect() -> CGRect {
        return CGRect(x: currentRect.minX + RATE*2, y: currentRect.maxY - RATE , width: currentRect.width - RATE*4, height: RATE*2)
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
    /*****************************************四个角****************************************/
    private func topLeft() -> CGRect{
        return CGRect(x: currentRect.minX - SMALLCIRCLE*0.5, y: currentRect.minY - SMALLCIRCLE*0.5, width: SMALLCIRCLE, height: SMALLCIRCLE)
    }
    private func topRight() -> CGRect {
        return CGRect(x: currentRect.maxX - SMALLCIRCLE*0.5, y: currentRect.minY-SMALLCIRCLE*0.5, width: SMALLCIRCLE, height: SMALLCIRCLE)
    }
    private func bottomLeft() -> CGRect {
        return CGRect(x: currentRect.minX - SMALLCIRCLE*0.5, y: currentRect.maxY - SMALLCIRCLE*0.5, width: SMALLCIRCLE, height: SMALLCIRCLE)
    }
    private func bottomRight() -> CGRect {
        return CGRect(x: currentRect.maxX - SMALLCIRCLE*0.5, y: currentRect.maxY-SMALLCIRCLE*0.5, width: SMALLCIRCLE, height: SMALLCIRCLE)
    }
}
extension UIView{
    func setRadius() -> Void {
        print("hello world")
    }
}

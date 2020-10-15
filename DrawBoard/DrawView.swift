//
//  DrawView.swift
//  DrawBoard
//
//  Created by xiaoyuan on 2020/10/10.
//  Copyright © 2020 xiaoyuan. All rights reserved.
//

import UIKit

private var MAX_UNDO_COUNT: Int = 10

extension UIColor {
    ///16进制转rgb
    public convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString.replacingOccurrences(of: "0x", with: "")
        formatted = formatted.replacingOccurrences(of: "#", with: "")
        if let hex = Int(formatted, radix: 16) {
            let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16)/255.0)
            let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8)/255.0)
            let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0)/255.0)
            self.init(red: red, green: green, blue: blue, alpha: alpha)        }
        else {
            return nil
        }
    }
}


class DrawCanvas: UIView {
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    // 绘制
    func setBrush(_ brush: DrawBrush?) {
        let shapeLayer = self.layer as! CAShapeLayer
        if let brush = brush {
            shapeLayer.strokeColor = UIColor(hexString: brush.brushColor)?.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineJoin = CAShapeLayerLineJoin.round
            shapeLayer.lineCap = CAShapeLayerLineCap.round;
            shapeLayer.lineWidth = brush.brushWidth
            
            if brush.isEraser == false {
                shapeLayer.path = brush.bezierPath?.cgPath
            }
        }
        else {
            shapeLayer.path = nil
        }
    }
    
}

public class DrawView: UIView {
    
    //颜色
    public var brushColor: String = "dd3626"
    //是否是橡皮擦
    public var isEraser: Bool = false
    //宽度
    public var brushWidth: CGFloat = 5.0
    //形状
    public var shapeType: DrawShapeType = .curve
    //背景图
    public var backgroundImage: UIImage? {
        didSet {
            self.bgImgView.image = backgroundImage
        }
    }
    
    private var pts = Array(arrayLiteral: CGPoint.zero, CGPoint.zero, CGPoint.zero, CGPoint.zero, CGPoint.zero)
    private var ctr: Int = 0
    
    //背景View
    private lazy var bgImgView = UIImageView()
    // 画布view
    private lazy var canvasView = DrawCanvas()
    // 合成view
    private lazy var composeView = UIImageView()
    //画笔容器
    private lazy var brushArray = [DrawBrush]()
    //撤销容器
    private lazy var undoArray = [String]()
    //重做容器
    private lazy var redoArray = [String]()
    //linyl
    //记录脚本用
    private lazy var dwawFile = DrawFile(packageArray: [])
    //每次touchsbegin的时间，后续为计算偏移量用
    private var beginDate: Date?
    //绘制记录的脚本用的
    private var recPackageArray: [DrawPackageModel]?
    
    deinit {
        clean()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        self.backgroundColor = .clear
        self.bgImgView.frame = self.bounds
        self.bgImgView.contentMode = .scaleAspectFill
        self.addSubview(self.bgImgView)
        
        self.composeView.frame = self.bounds
        self.addSubview(self.composeView)
        
        self.canvasView.frame = self.bounds
        self.composeView.addSubview(self.canvasView)
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        bgImgView.frame = self.bounds
        composeView.frame = self.bounds
        canvasView.frame = self.bounds
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: point)
        let brush = DrawBrush(brushColor: self.brushColor, brushWidth: self.brushWidth, isEraser: self.isEraser, shapeType: self.shapeType, bezierPath: bezierPath, beginPoint: point)
        self.brushArray.append(brush)
        
        //每次画线前，都清除重做列表。
        self.cleanRedoArray()
        
        self.ctr = 0
        self.pts[0] = point
        
        // 保存当前操作，为了录制
        self.beginDate = Date()
        
        let model = DrawBrushModel(brushColor: self.brushColor, brushWidth: self.brushWidth, shapeType: self.shapeType, isEraser: self.isEraser, beginPoint: DrawPointModel(xPoint: point.x, yPoint: point.y, timeOffset: 0), endPoint: nil)
        self.addModelToPackage(model)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        guard var brush = self.brushArray.last else { return }
        var drawPackage = self.dwawFile.packageArray.last
        let pointModel = DrawPointModel(xPoint: point.x, yPoint: point.y, timeOffset: fabs(self.beginDate?.timeIntervalSinceNow ?? 0.0))
        
        drawPackage?.pointOrBrushArray.append(pointModel)
        
        if isEraser == true {
            brush.bezierPath?.addLine(to: point)
            self.setEraserMode(brush: brush)
        }
        else {
            switch self.shapeType {
            case .curve:
                self.ctr += 1
                self.pts[self.ctr] = point
                if self.ctr == 4 {
                    pts[3] = CGPoint(x: (pts[2].x + pts[4].x)/2.0, y: (pts[2].y + pts[4].y)/2.0)
                    brush.bezierPath?.move(to: pts[0])
                    brush.bezierPath?.addCurve(to: pts[3], controlPoint1: pts[1], controlPoint2: pts[2])
                    pts[0] = pts[3]
                    pts[1] = pts[4]
                    ctr = 1
                }
            case .line:
                brush.bezierPath?.removeAllPoints()
                brush.bezierPath?.move(to: brush.beginPoint ?? .zero)
                brush.bezierPath?.addLine(to: point)
            case .ellipse:
                brush.bezierPath = UIBezierPath(ovalIn: self.getRectWithStartPoint(brush.beginPoint ?? .zero, endPoint: point))
                self.brushArray.removeLast()
                self.brushArray.append(brush)
            case .rect:
                brush.bezierPath = UIBezierPath(rect: self.getRectWithStartPoint(brush.beginPoint ?? .zero, endPoint: point))
                self.brushArray.removeLast()
                self.brushArray.append(brush)
            }
        }
        
        //在画布上画线
        canvasView.setBrush(brush)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let count = self.ctr
        if count <= 4 && self.shapeType == .curve {
            
            for _ in stride(from: count, through: 0, by: -1) {
                self.touchesMoved(touches, with: event)
            }
            ctr = 0
        }
        else {
            self.touchesMoved(touches, with: event)
        }
        
        //画布view与合成view 合成为一张图（使用融合卡）
        let img = composeBrushToImage()
        
        //清空画布
        canvasView.setBrush(nil)
        
        //保存到存储，撤销用。
        
        self.saveTempPic(image: img)
        
        
        // 录制用的
        guard let point = touches.first?.location(in: self) else {
            return
        }
        
        let endPoint = DrawPointModel(xPoint: point.x, yPoint: point.y, timeOffset: abs(self.beginDate?.timeIntervalSinceNow ?? 0))
        let brushModel = DrawBrushModel(brushColor: self.brushColor, brushWidth: self.brushWidth, shapeType: self.shapeType, isEraser: self.isEraser, beginPoint: nil, endPoint: endPoint)
        if var drawPackage = self.dwawFile.packageArray.last {
            drawPackage.pointOrBrushArray.append(brushModel)
            self.dwawFile.packageArray.removeLast()
            self.dwawFile.packageArray.append(drawPackage)
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    
    
    // 删除临时生成图片
    private func deleteTempPicPath(_ path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }
    
    private func cleanUndoArray() {
        undoArray.forEach { (path) in
            self.deleteTempPicPath(path)
        }
        undoArray.removeAll()
    }
    
    private func cleanRedoArray() {
        redoArray.forEach { (path) in
            self.deleteTempPicPath(path)
        }
        redoArray.removeAll()
    }
    
    private func addModelToPackage(_ drawModel: XYDrawable) {
        let drawPackage = DrawPackageModel(pointOrBrushArray: [drawModel])
        var packageArray = self.dwawFile.packageArray
        packageArray.append(drawPackage)
        self.dwawFile.packageArray = packageArray
    }
    
    // 设置为橡皮擦模式
    fileprivate func setEraserMode(brush: DrawBrush) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        composeView.image?.draw(in: self.bounds)
        
        UIColor.clear.set()
        
        brush.bezierPath?.lineWidth = brushWidth
        brush.bezierPath?.stroke(with: .clear, alpha: 1.0)
        
        brush.bezierPath?.stroke()
        
        composeView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    fileprivate func composeBrushToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext();
            return nil
        }
        composeView.layer.render(in: context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        composeView.image = image
        
        return image
    }
    
    private func getRectWithStartPoint(_ startPoint: CGPoint, endPoint: CGPoint) -> CGRect {
        let x = startPoint.x <= endPoint.x ? startPoint.x: endPoint.x
        let y = startPoint.y <= endPoint.y ? startPoint.y : endPoint.y
        let width = abs(startPoint.x - endPoint.x)
        let height = abs(startPoint.y - endPoint.y)
        
        return CGRect(x: x , y: y , width: width, height: height)
    }
    
    private func saveTempPic(image: UIImage?) {
        guard let img = image else {
            return
        }
        
        //这里切换线程处理
        DispatchQueue.global(qos: .default).async {
            let date = Date()
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "HHmmssSSS"
            let now = dateformatter.string(from: date)
            let picPath = NSHomeDirectory() + "/tmp/" + now
            
            if let imgData = img.pngData() {
                do {
                    try imgData.write(to: URL(fileURLWithPath: picPath), options: .atomic)
                    DispatchQueue.main.async {
                        self.undoArray.append(picPath)
                    }
                }
                catch let ex {
                    print(ex.localizedDescription)
                }
            }
        }
    }
    
    private func updateDrawBrush(_ model: DrawBrushModel) {
        self.brushColor = model.brushColor
        self.brushWidth = model.brushWidth
        self.shapeType = model.shapeType
        self.isEraser = model.isEraser
    }
    
    //linyl
//    fileprivate func drawNextPackage() {
//        if recPackageArray == nil {
//            // 当需要绘制的_recPackageArray为nil时，读取本地已录制的线，将其设置为待绘画的线
//            let object = UserDefaults.standard.object(forKey: "recPackageArray")
//            //解档
//            let decoder = JSONDecoder()
//            if let data = object as? Data {
//                let objectA = try? decoder.decode(DrawFile.self, from: data)
//                print(String(describing: objectA))
//            }
//        }
//    }
//    - (void)drawNextPackage
//    {
//        if(!_recPackageArray)
//        {
//            // 当需要绘制的_recPackageArray为nil时，读取本地已录制的线，将其设置为待绘画的线
//            NSString *filePath = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(), @"drawFile"];
//            LSDrawFile *drawFile = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//            if (drawFile)
//            {
//                _recPackageArray = drawFile.packageArray;
//            }
//        }
//
//        if (_recPackageArray.count > 0)
//        {
//            LSDrawPackage *pack = [_recPackageArray firstObject];
//            [_recPackageArray removeObjectAtIndex:0];
//
//            for (LSDrawModel *drawModel in pack.pointOrBrushArray)
//            {
//                if (drawModel)
//                {
//
//    //                dispatch_async(dispatch_get_main_queue(), ^{
//
//                        double packageOffset = 0.0;
//                        if ([drawModel isKindOfClass:[LSPointModel class]])
//                        {
//                            LSPointModel *pointModel = (LSPointModel *)drawModel;
//                            [self performSelector:@selector(drawWithPointModel:) withObject:drawModel afterDelay:pointModel.timeOffset];
//                        }
//                        else if([drawModel isKindOfClass:[LSBrushModel class]])
//                        {
//                            LSBrushModel *brushModel = (LSBrushModel*)drawModel;
//
//                            if (brushModel.beginPoint)
//                            {
//                                packageOffset = brushModel.beginPoint.timeOffset;
//                            }
//                            else
//                            {
//                                packageOffset = brushModel.endPoint.timeOffset;
//                            }
//                            [self performSelector:@selector(drawWithBrushModel:) withObject:drawModel afterDelay:packageOffset];
//                        }
//                        else if([drawModel isKindOfClass:[LSActionModel class]])
//                        {
//                            LSActionModel *actionModel = (LSActionModel*)drawModel;
//                            switch (actionModel.ActionType)
//                            {
//                                case LSDrawActionRedo:
//                                    [self performSelector:@selector(actionReDo) withObject:nil afterDelay:0.5];
//                                    break;
//
//                                case LSDrawActionUndo:
//                                    [self performSelector:@selector(actionUnDo) withObject:nil afterDelay:0.5];
//                                    break;
//                                case LSDrawActionSave:
//                                    [self performSelector:@selector(actionSave) withObject:nil afterDelay:0.5];
//                                    break;
//                                case LSDrawActionClean:
//                                    [self performSelector:@selector(actionClean) withObject:nil afterDelay:0.5];
//                                    break;
//
//                                default:
//                                    break;
//                            }
//                        }
//
//
//    //                });
//
//
//                }
//            }
//        }
//    }

}

extension DrawView {
    
    //撤销
    public func undo() {
        if self.undoArray.count <= 0 {
            return
        }
        
        let lastPath = undoArray.last!
        undoArray.removeLast()
        self.redoArray.append(lastPath)
        
        DispatchQueue.global(qos: .default).async {
            var undoImage: UIImage?
            if self.undoArray.count > 0 {
                let undoPicPath = self.undoArray.last!
                do {
                    let imgData = try Data(contentsOf: URL(fileURLWithPath: undoPicPath))
                    undoImage = UIImage(data: imgData)
                } catch let ex {
                    print(ex.localizedDescription)
                }
                
                DispatchQueue.main.async {
                    self.composeView.image = undoImage
                }
            }
        }
        
        self.addModelToPackage(DrawAction.undo)
    }
    
    //重做
    public func redo() {
        if self.redoArray.count <= 0 {
            return
        }
        let lastPath = redoArray.last!
        redoArray.removeLast()
        undoArray.append(lastPath)
        
        DispatchQueue.global(qos: .default).async {
            var redoImage: UIImage?
            do {
                let imgData = try Data(contentsOf: URL(fileURLWithPath: lastPath))
                redoImage = UIImage(data: imgData)
                DispatchQueue.main.async {
                    self.composeView.image = redoImage
                }
            } catch let ex {
                print(ex.localizedDescription)
            }
        }
        
        self.addModelToPackage(DrawAction.redo)
    }
    
    
    //保存到相册
    public func save() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        self.layer.render(in: context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        UIGraphicsEndImageContext()
        
        self.addModelToPackage(DrawAction.save)
        
    }
    
    //清除绘制
    public func clean() {
        self.composeView.image = nil
        self.brushArray.removeAll()
        // 删除存储的文件
        self.cleanUndoArray()
        self.cleanRedoArray()
        
        self.addModelToPackage(DrawAction.clean)
    }

    
    //录制脚本
    public func testRecToFile() {
        
//        NSString *filePath = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(), @"drawFile"];
//
//        NSLog(@"drawfile:%@",filePath);
//
//        BOOL bRet = [NSKeyedArchiver archiveRootObject:_dwawFile toFile:filePath];
//
//        if (bRet)
//        {
//            NSLog(@"archive Succ");
//        }

    }
    
    //绘制已录制的脚本
    public func testPlayFromFile() {
        
    }
}

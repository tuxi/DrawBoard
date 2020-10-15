//
//  DrawModel.swift
//  DrawBoard
//
//  Created by xiaoyuan on 2020/10/10.
//  Copyright © 2020 xiaoyuan. All rights reserved.
//

import UIKit

// 画笔形状
public enum DrawShapeType: Int, Codable {
    // 曲线
    case curve = 0
    // 直线
    case line
    // 椭圆
    case ellipse
    // 矩形
    case rect
}

enum DrawAction: Int, XYDrawable, Codable {
    case unknow = 1
    // 撤销
    case undo
    // 重做
    case redo
    // 保存
    case save
    // 清空
    case clean
    // 其他
    case other
}

protocol XYDrawable: Codable {
    
}

struct DrawPointModel: XYDrawable {
    var xPoint: CGFloat
    var yPoint: CGFloat
    var timeOffset: Double
}

struct DrawBrushModel: XYDrawable {
 
    var brushColor: String
    var brushWidth: CGFloat
    var shapeType: DrawShapeType
    var isEraser: Bool
    var beginPoint: DrawPointModel?
    var endPoint: DrawPointModel?
}

struct DrawPackageModel  {
    var pointOrBrushArray: [XYDrawable]
    
}

class DrawFile {
    var packageArray: [DrawPackageModel]

    init(packageArray: [DrawPackageModel]) {
        self.packageArray = packageArray
    }
}


//封装的画笔类
struct DrawBrush {
    //画笔颜色
    var brushColor: String
    //画笔宽度
    var brushWidth: CGFloat
    //是否是橡皮擦
    var isEraser: Bool
    //形状
    var shapeType: DrawShapeType
    //贝塞尔路径
    var bezierPath: UIBezierPath?
    // 起点
    var beginPoint: CGPoint?
    // 终点
    var endPoint: CGPoint?
    
    mutating func updateBezierPath(_ bezierPath: UIBezierPath) {
        self.bezierPath = bezierPath
    }
     
}

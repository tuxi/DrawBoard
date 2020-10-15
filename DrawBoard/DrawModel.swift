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

enum DrawAction: Int, Codable {
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

struct DrawBrushModel: Codable {
    
    struct Point: Codable {
        var x: CGFloat
        var y: CGFloat
        var timeOffset: Double
    }
    
    struct Brush: Codable {
        var brushColor: String
        var brushWidth: CGFloat
        var shapeType: DrawShapeType
        var isEraser: Bool
        var beginPoint: Point?
        var endPoint: Point?
    }
    
    /// 三个属性代表三种类型，用于记录用户操作的
    
    // 画笔
    var brush: Brush?
    // 其他事件，如果action 不为nil，不使用以上属性
    var action: DrawAction?
    // 点事件
    var point: Point?
    
    init(brush: Brush) {
        self.brush = brush
    }
    
    init(point: Point) {
        self.point = point
    }
    
    init(action: DrawAction) {
        self.action = action
    }
    
}

struct DrawPackageModel: Codable  {
    var pointOrBrushArray: [DrawBrushModel]
    
}

class DrawFile: Codable {
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

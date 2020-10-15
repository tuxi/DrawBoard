//
//  ViewController.swift
//  DrawBoard
//
//  Created by xiaoyuan on 2020/10/10.
//  Copyright © 2020 xiaoyuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private lazy var drawView = DrawView(frame: self.view.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawView.brushColor = "dd3626"
        drawView.brushWidth = 6
        drawView.shapeType = .curve
        
        drawView.backgroundImage = UIImage(named: "20130616030824963")
        
        self.view.addSubview(drawView)
        
        //工具栏
        let btnUndo = UIButton(type: .custom)
        btnUndo.backgroundColor = .orange
        btnUndo.frame = CGRect(x: 20, y: 20, width: 60, height: 20)
        btnUndo.setTitle("撤销", for: .normal)
        btnUndo.addTarget(self, action: #selector(btnUndoClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnUndo)
        
        let btnRedo = UIButton(type: .custom)
        btnRedo.backgroundColor = .orange
        btnRedo.frame = CGRect(x: 100, y: 20, width: 60, height: 20)
        btnRedo.setTitle("重做", for: .normal)
        btnRedo.addTarget(self, action: #selector(btnRedoClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnRedo)
        
        let btnSave = UIButton(type: .custom)
        btnSave.backgroundColor = .orange
        btnSave.frame = CGRect(x: 180, y: 20, width: 60, height: 20)
        btnSave.setTitle("保存", for: .normal)
        btnSave.addTarget(self, action: #selector(btnSaveClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnSave)

        let btnClean = UIButton(type: .custom)
        btnClean.backgroundColor = .orange
        btnClean.frame = CGRect(x: 260, y: 20, width: 60, height: 20)
        btnClean.setTitle("清除", for: .normal)
        btnClean.addTarget(self, action: #selector(btnCleanClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnClean)
        
        let btnCurve = UIButton(type: .custom)
        btnCurve.backgroundColor = .orange
        btnCurve.frame = CGRect(x: 20, y: 50, width: 60, height: 20)
        btnCurve.setTitle("曲线", for: .normal)
        btnCurve.addTarget(self, action: #selector(btnCurveClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnCurve)
        
        let btnLine = UIButton(type: .custom)
        btnLine.backgroundColor = .orange
        btnLine.frame = CGRect(x: 100, y: 50, width: 60, height: 20)
        btnLine.setTitle("直线", for: .normal)
        btnLine.addTarget(self, action: #selector(btnLineClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnLine)
        
        let btnEllipse = UIButton(type: .custom)
        btnEllipse.backgroundColor = .orange
        btnEllipse.frame = CGRect(x: 180, y: 50, width: 60, height: 20)
        btnEllipse.setTitle("椭圆", for: .normal)
        btnEllipse.addTarget(self, action: #selector(btnEllipseClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnEllipse)
        
        let btnRect = UIButton(type: .custom)
        btnRect.backgroundColor = .orange
        btnRect.frame = CGRect(x: 260, y: 50, width: 60, height: 20)
        btnRect.setTitle("矩形", for: .normal)
        btnRect.addTarget(self, action: #selector(btnRectClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnRect)
        
        
        let btnRec = UIButton(type: .custom)
        btnRec.backgroundColor = .orange
        btnRec.frame = CGRect(x: 20, y: 80, width: 60, height: 20)
        btnRec.setTitle("录制", for: .normal)
        btnRec.addTarget(self, action: #selector(btnRecClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnRec)
        
        let btnPlay = UIButton(type: .custom)
        btnPlay.backgroundColor = .orange
        btnPlay.frame = CGRect(x: 100, y: 80, width: 60, height: 20)
        btnPlay.setTitle("绘制", for: .normal)
        btnPlay.addTarget(self, action: #selector(btnPlayClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnPlay)
        
        let btnEraser = UIButton(type: .custom)
        btnEraser.backgroundColor = .orange
        btnEraser.frame = CGRect(x: 180, y: 80, width: 60, height: 20)
        btnEraser.setTitle("橡皮擦", for: .normal)
        btnEraser.setTitle("画笔", for: .selected)
        btnEraser.addTarget(self, action: #selector(btnEraserClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnEraser)
        
        
    }

    @objc func btnUndoClicked(sender: UIButton) {
        drawView.undo()
    }
    
    @objc func btnRedoClicked(sender: UIButton) {
        drawView.redo()
    }
    
    @objc func btnSaveClicked(sender: UIButton) {
        drawView.save()
    }

    @objc func btnCleanClicked(sender: UIButton) {
        drawView.clean()
    }
    
    @objc func btnCurveClicked(sender: UIButton) {
        drawView.shapeType = .curve
    }
    
    @objc func btnLineClicked(sender: UIButton) {
        drawView.shapeType = .line
    }
    
    @objc func btnEllipseClicked(sender: UIButton) {
        drawView.shapeType = .ellipse
    }
    
    @objc func btnRectClicked(sender: UIButton) {
        drawView.shapeType = .rect
    }
    @objc func btnRecClicked(sender: UIButton) {
        drawView.testRecToFile()
    }
    
    @objc func btnPlayClicked(sender: UIButton) {
        drawView.testPlayFromFile()
    }
    @objc func btnEraserClicked(sender: UIButton) {
        let btn = sender
        if btn.isSelected {
            btn.isSelected = false
            
            //使用画笔
            drawView.isEraser = false
        }
        else {
            btn.isSelected = true
            
            //使用橡皮擦
            drawView.isEraser = true
        }
    }
}


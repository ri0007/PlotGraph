//
//  ViewController.swift
//  PlotGraph
//
//  Created by 井上 龍一 on 2016/01/31.
//  Copyright © 2016年 Ryuichi Inoue. All rights reserved.
//

import UIKit
import CorePlot

class ViewController: UIViewController, CPTBarPlotDelegate, CPTPieChartDelegate, CPTScatterPlotDelegate {

    var graphModel = Graph()
    var mainView:MainView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView = view as! MainView
        graphModel.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        graphModel.configurePieChart(mainView.hostingView)
        graphModel.addAnimation((mainView.hostingView.hostedGraph?.plotAtIndex(0))!)
    }
    
    // MARK: - デリゲート
    
    func pieChart(plot: CPTPieChart, sliceTouchDownAtRecordIndex idx: UInt) {
        print(graphModel.graphData[Int(idx)])
    }
    
    func barPlot(plot: CPTBarPlot, barTouchDownAtRecordIndex idx: UInt) {
        print(graphModel.graphData[Int(idx)])
    }
    
    // MARK: - アクション
    
    @IBAction func clickSegmentedControl(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            graphModel.configurePieChart(mainView.hostingView)
        case 1:
            graphModel.configureBarGraph(mainView.hostingView)
        case 2:
            graphModel.configureLineGraph(mainView.hostingView)
        default:
            break
        }
        graphModel.addAnimation((mainView.hostingView.hostedGraph?.plotAtIndex(0))!)
    }
    
    @IBAction func clickReloadButton(sender: UIButton) {
        graphModel.reloadData(mainView.hostingView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


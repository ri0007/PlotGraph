//
//  ViewController.swift
//  PlotGraph
//
//  Created by 井上 龍一 on 2016/01/31.
//  Copyright © 2016年 Ryuichi Inoue. All rights reserved.
//

import UIKit
import CorePlot

class ViewController: UIViewController, CPTPlotDataSource, CPTBarPlotDelegate, CPTBarPlotDataSource, CPTPieChartDelegate, CPTPieChartDataSource {

    var graphData: [Float] = []
    var hostingView: CPTGraphHostingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGraphData()

        var frame = UIScreen.mainScreen().bounds
        frame.size.height = frame.size.height / 2
        frame.origin.y += 20
        
        hostingView = CPTGraphHostingView(frame: frame)
        
        configurePieChart()

        view.addSubview(hostingView)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - グラフ設定
    
    func initGraphData(){
        let item = Int(arc4random_uniform(5) + 5)
        var data: [Float] = []
        
        for var i = 0; i <= item; i++ {
            data.append( 1.0 + ( Float( arc4random_uniform(UINT32_MAX) ) / Float(UINT32_MAX) ) * 6 )
        }
        
        graphData = data
    }
    
    func configurePieChart(){
        let graph = CPTXYGraph(frame: hostingView.bounds)
        hostingView.hostedGraph = graph
        
        graph.axisSet = nil
        
        let pieChart = CPTPieChart()
        pieChart.pieRadius = 100
        pieChart.dataSource = self
        pieChart.delegate = self
        
        addAnimation(pie: pieChart)
        
        graph.addPlot(pieChart)
    }
    
    func configureBarGraph(){
        let graph = CPTXYGraph(frame: hostingView.bounds)
        hostingView.hostedGraph = graph
        
        graph.plotAreaFrame!.paddingLeft   = 60.0
        graph.plotAreaFrame!.paddingTop    = 20.0
        graph.plotAreaFrame!.paddingRight  = 20.0
        graph.plotAreaFrame!.paddingBottom = 60.0
        
        let plotSpace = graph.defaultPlotSpace! as! CPTXYPlotSpace
        plotSpace.xRange = CPTPlotRange(location: 0, length: Float(graphData.count) + 0.1)
        plotSpace.yRange = CPTPlotRange(location: 0, length: 11)
        
        let barGraph = CPTBarPlot()
        barGraph.barWidth = 1
        barGraph.barOffset = (barGraph.barWidth?.floatValue)! / 2.0
        barGraph.fill = CPTFill(color: CPTColor(componentRed: 0.9, green: 0.2, blue: 0.2, alpha: 1.0))
        barGraph.dataSource = self
        barGraph.delegate = self
        
        addAnimation(bar: barGraph)
        
        graph.addPlot(barGraph)
    }
    
    func configureLineGraph(){
        let graph = CPTXYGraph(frame: hostingView.bounds)
        hostingView.hostedGraph = graph
        
        graph.plotAreaFrame!.paddingLeft   = 60.0
        graph.plotAreaFrame!.paddingTop    = 20.0
        graph.plotAreaFrame!.paddingRight  = 20.0
        graph.plotAreaFrame!.paddingBottom = 60.0
        
        let plotSpace = graph.defaultPlotSpace! as! CPTXYPlotSpace
        plotSpace.xRange = CPTPlotRange(location: 0, length: Float(graphData.count) + 0.1)
        plotSpace.yRange = CPTPlotRange(location: 0, length: 11)
        
        let lineGraph = CPTScatterPlot()
        lineGraph.dataSource = self
        lineGraph.delegate = self
        
        addAnimation(line: lineGraph)

        graph.addPlot(lineGraph)
    }
    
    // MARK: - デリゲートメソッド
    
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return UInt(graphData.count)
    }
    
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        if plot.dynamicType === CPTPieChart.self {
            var data = graphData
            data.sortInPlace()
            data = data.reverse()
            return data[Int(idx)]
        } else if plot.dynamicType === CPTBarPlot.self {
            switch fieldEnum {
            case UInt(CPTBarPlotField.BarLocation.rawValue):
                return idx
            case UInt(CPTBarPlotField.BarTip.rawValue):
                return graphData[Int(idx)]
            default:
                break
            }
        } else if plot.dynamicType === CPTScatterPlot.self {
            switch fieldEnum {
            case UInt(CPTScatterPlotField.X.rawValue):
                return idx
            case UInt(CPTScatterPlotField.Y.rawValue):
                return graphData[Int(idx)]
            default:
                break
            }
        }
        
        return nil
    }
    
    // MARK: - アクション
    
    @IBAction func clickSegmentedControl(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            configurePieChart()
        case 1:
            configureBarGraph()
        case 2:
            configureLineGraph()
        default:
            break
        }
    }
    
    @IBAction func clickReloadButton(sender: UIButton) {
        initGraphData()
        
        if let graph = hostingView.hostedGraph {
            let plotSpace = graph.defaultPlotSpace! as! CPTXYPlotSpace
            plotSpace.xRange = CPTPlotRange(location: 0, length: Float(graphData.count) + 0.1)
        }
        
        hostingView.hostedGraph?.reloadData()
        
        addAnimation((hostingView.hostedGraph?.plotAtIndex(0))!)
    }
    
    // MARK: - アニメーション
    
    func addAnimation(plot: AnyObject){
        if plot.dynamicType === CPTPieChart.self {
            addAnimation(pie: plot as! CPTPieChart)
        }
        else if plot.dynamicType === CPTScatterPlot.self {
            addAnimation(line: plot as! CPTPlot)
        }
        else if plot.dynamicType === CPTBarPlot.self {
            addAnimation(bar: plot as! CPTPlot)
        }
    }
    
    func addAnimation(pie plot:CPTPieChart) {
        let duration = CGFloat(1.5)
        let curve = CPTAnimationCurve.ExponentialInOut
        CPTAnimation.animate(plot,
            property: "endAngle",
            from:CGFloat(M_PI / 2.0) + CGFloat(M_PI * 2.0),
            to: CGFloat(M_PI / 2.0),
            duration: duration,
            animationCurve: curve,
            delegate: nil)
    }
    
    func addAnimation(bar plot:CPTPlot) {
        let duration = CGFloat(1.5)
        let curve = CPTAnimationCurve.Linear
        plot.contentsGravity = kCAGravityBottom
        CPTAnimation.animate(plot,
            property: "contentsRect",
            fromRect: CGRect(x: 0, y: 0, width: 1, height: 0),
            toRect: CGRect(x: 0, y: 1, width: 1, height: -1),
            duration: duration,
            animationCurve: curve,
            delegate: nil)
    }
    
    func addAnimation(line plot:CPTPlot) {
        let duration = CGFloat(1.5)
        let curve = CPTAnimationCurve.Linear
        plot.contentsGravity = kCAGravityLeft // contentsRectで切り取ったものを左寄せする
        CPTAnimation.animate(plot,
            property: "contentsRect", // どこからどこまで描画するかをCGRectで指定する
            fromRect: CGRect(x: 0, y: 0, width: 0, height: 1),
            toRect: CGRect(x: 1, y: 0, width: -1, height: 1),
            duration: duration,
            animationCurve: curve,
            delegate: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


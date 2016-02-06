//
//  Graph.swift
//  PlotGraph
//
//  Created by 井上 龍一 on 2016/02/05.
//  Copyright © 2016年 Ryuichi Inoue. All rights reserved.
//

import UIKit
import CorePlot

class Graph: NSObject, CPTPlotDataSource, CPTBarPlotDataSource, CPTPieChartDataSource {
    var graphData: [Float] = []
    
    var delegate: AnyObject!
    
    override init(){
        super.init()
        initGraphData()
    }
    
    func initGraphData(){
        let item = Int(arc4random_uniform(5) + 5)
        var data: [Float] = []
        
        for var i = 0; i <= item; i++ {
            data.append( 1.0 + ( Float( arc4random_uniform(UINT32_MAX) ) / Float(UINT32_MAX) ) * 6 )
        }
        
        graphData = data
    }
    
    func reloadData(hostingView:CPTGraphHostingView){
        initGraphData()
        
        if let graph = hostingView.hostedGraph {
            let plotSpace = graph.defaultPlotSpace! as! CPTXYPlotSpace
            plotSpace.xRange = CPTPlotRange(location: 0, length: Float(graphData.count) + 0.1)
        }
        
        hostingView.hostedGraph?.reloadData()
        
        addAnimation((hostingView.hostedGraph?.plotAtIndex(0))!)
    }
    
    // MARK: - グラフ設定
    
    func configurePieChart(hostingView:CPTGraphHostingView){
        let graph = CPTXYGraph(frame: hostingView.bounds)
        hostingView.hostedGraph = graph
        
        graph.axisSet = nil
        
        let pieChart = CPTPieChart()
        pieChart.pieRadius = 100
        pieChart.dataSource = self
        pieChart.delegate = delegate
        
        addAnimation(pie: pieChart)
        
        graph.addPlot(pieChart)
    }
    
    func configureBarGraph(hostingView:CPTGraphHostingView){
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
        barGraph.delegate = delegate

        addAnimation(bar: barGraph)
        
        graph.addPlot(barGraph)
    }
    
    func configureLineGraph(hostingView:CPTGraphHostingView){
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
        lineGraph.delegate = delegate

        addAnimation(line: lineGraph)
        
        graph.addPlot(lineGraph)
    }
    
    // MARK: - 各種データソース系プロトコルのデリゲートメソッド
    
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return UInt(graphData.count)
    }
    
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        if plot.dynamicType === CPTPieChart.self {
            //graphData.sortInPlace()
            //graphData = graphData.reverse()
            return graphData[Int(idx)]
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
    
    func dataLabelForPlot(plot: CPTPlot, recordIndex idx: UInt) -> CPTLayer? {
        let label = CPTTextLayer(text: NSString(format: "%.2f", graphData[Int(idx)]) as String)
        
        let textStyle = label.textStyle?.mutableCopy() as! CPTMutableTextStyle
        textStyle.color = CPTColor.lightGrayColor()
        
        label.textStyle = textStyle
        return label
    }
    
    // MARK: - グラフアニメーション
    
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
}

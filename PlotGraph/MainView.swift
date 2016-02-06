//
//  MainView.swift
//  PlotGraph
//
//  Created by 井上 龍一 on 2016/02/05.
//  Copyright © 2016年 Ryuichi Inoue. All rights reserved.
//

import UIKit
import CorePlot

class MainView: UIView/*, CPTPlotDataSource, CPTBarPlotDataSource, CPTPieChartDataSource */{
    var hostingView: CPTGraphHostingView!
    
    @IBOutlet weak var graphModeControl: UISegmentedControl!
    @IBOutlet weak var reloadButton: UIButton!
    
    override init(var frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        
        frame.size.height = frame.size.height / 2
        frame.origin.y += 20
        
        hostingView = CPTGraphHostingView(frame: frame)
        addSubview(hostingView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        var frame = UIScreen.mainScreen().bounds
        frame.size.height = frame.size.height / 2
        frame.origin.y += 20
        
        hostingView = CPTGraphHostingView(frame: frame)
        addSubview(hostingView)
    }
}

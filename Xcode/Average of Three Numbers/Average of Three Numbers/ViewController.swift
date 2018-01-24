//
//  ViewController.swift
//  Swift is Even Dumber
//
//  Created by Cooper Anderson on 1/23/18.
//  Copyright © 2018 Cooper Anderson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var gridViews: UIStackView!
    @IBOutlet weak var label: CountingLabel!
    
    var grids: Array<Array<Bool>> = []
    var average: Double = 0.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for grid in 0...2 {
            grids.append([])
            for _ in 0...15 {
                grids[grid].append(false);
            }
        }
        
        for gridRaw in gridViews.subviews {
            if let grid = gridRaw as? UIStackView {
                for rowRaw in grid.subviews {
                    if let row = rowRaw as? UIStackView {
                        for buttonRaw in row.subviews {
                            if let button = buttonRaw as? UIButton {
                                button.backgroundColor = UIColor(red: 114/255, green: 137/255, blue: 218/225, alpha: 1.0)
                                button.alpha = 0.5
                                button.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
                            }
                        }
                    }
                }
            }
        }
        
        label.decimalPoints = .two
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAverage() {
        var total = 0
        for grid in grids {
            for (index, value) in grid.enumerated() {
                if value {
                    total += Int(pow(2, Double(index)))
                }
            }
        }
        label.countFromCurrent(to: Float(Double(total) / 3.0), duration: 0.25)
    }
    
    @objc func buttonClicked(button: UIButton!) {
        let x: Int = button.superview!.subviews.index(of: button)!
        let y: Int = button.superview!.superview!.subviews.index(of: button.superview!)!
        let grid: Int = button.superview!.superview!.superview!.subviews.index(of: button.superview!.superview!)!
        let index: Int = 15 - (y*4 + x)
        
        grids[grid][index] = !grids[grid][index]
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            button.alpha = self.grids[grid][index] ? 1 : 0.5
        })
        
        updateAverage()
    }
}


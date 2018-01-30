//
//  ViewController.swift
//  Coin Machine
//
//  Created by Cooper Anderson on 1/25/18.
//  Copyright © 2018 Cooper Anderson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var costText: UITextField!
    @IBOutlet weak var amountText: UITextField!
    
    @IBOutlet weak var labelQuarter: CountingLabel!
    @IBOutlet weak var labelDime: CountingLabel!
    @IBOutlet weak var labelNickel: CountingLabel!
    @IBOutlet weak var labelPenny: CountingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func calculate(_ sender: Any) {
        if let cost = Double(costText.text!) {
            if let amount = Double(amountText.text!) {
                var coins = (amount - cost) * 100
                let quarters = floor(coins / 25)
                coins = coins.truncatingRemainder(dividingBy: 25)
                let dimes = floor(coins / 10)
                coins = coins.truncatingRemainder(dividingBy: 10)
                let nickels = floor(coins / 5)
                coins = coins.truncatingRemainder(dividingBy: 5)
                
                labelQuarter.countFromCurrent(to: Float(quarters), duration: 0.25)
                labelDime.countFromCurrent(to: Float(dimes), duration: 0.25)
                labelNickel.countFromCurrent(to: Float(nickels), duration: 0.25)
                labelPenny.countFromCurrent(to: Float(coins), duration: 0.25)
            }
        }
    }
    
}


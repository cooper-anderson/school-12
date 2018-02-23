//
//  ViewController.swift
//  ATM
//
//  Created by Cooper Anderson on 2/20/18.
//  Copyright © 2018 Cooper Anderson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var balance:Double = 5000
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "$" + String(Int(balance))
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DepositViewController {
            vc.balanceStart = balance
        } else if let vc = segue.destination as? WithdrawViewController {
            vc.balanceStart = balance
        }
    }

}


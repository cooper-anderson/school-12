//
//  WithdrawViewController.swift
//  ATM
//
//  Created by Cooper Anderson on 2/20/18.
//  Copyright © 2018 Cooper Anderson. All rights reserved.
//

import UIKit

class WithdrawViewController: UIViewController {
    
    var balanceStart:Double = 0
    var balance:Double = 0
    
    @IBOutlet weak var stepperThousands: UIStepper!
    @IBOutlet weak var stepperHundreds: UIStepper!
    @IBOutlet weak var stepperTens: UIStepper!
    @IBOutlet weak var stepperOnes: UIStepper!
    
    @IBOutlet weak var labelThousands: UILabel!
    @IBOutlet weak var labelHundreds: UILabel!
    @IBOutlet weak var labelTens: UILabel!
    @IBOutlet weak var labelOnes: UILabel!
    
    @IBAction func actionThousands(_ sender: Any) {
        labelThousands.text = String(Int(stepperThousands.value))
    }
    @IBAction func actionHundreds(_ sender: Any) {
        labelHundreds.text = String(Int(stepperHundreds.value))
    }
    @IBAction func actionTens(_ sender: Any) {
        labelTens.text = String(Int(stepperTens.value))
    }
    @IBAction func actionOnes(_ sender: Any) {
        labelOnes.text = String(Int(stepperOnes.value))
    }
    @IBAction func withdraw(_ sender: Any) {
        balance += stepperThousands.value * 1000
        balance += stepperHundreds.value * 100
        balance += stepperTens.value * 10
        balance += stepperOnes.value
        print("Withdraw")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepperThousands.maximumValue = 9;
        stepperHundreds.maximumValue = 9;
        stepperTens.maximumValue = 9;
        stepperOnes.maximumValue = 9;

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ViewController {
            print("Prepare")
            if balance <= balanceStart {
                vc.balance = balanceStart - balance
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

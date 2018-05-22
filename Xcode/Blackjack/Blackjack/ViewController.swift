//
//  ViewController.swift
//  Blackjack
//
//  Created by Cooper Anderson on 4/10/18.
//  Copyright © 2018 Cooper Anderson. All rights reserved.
//

import UIKit

extension Card {
    func createImage(_ parent:UIStackView)->UIImageView {
        parent.addSubview(self.image)
        return self.image
    }
    func draw() {

    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var handPlayer: UIStackView!
    @IBOutlet weak var valuePlayer: UILabel!
    @IBAction func Hit(_ sender: Any) {
        var card = player.hand.popCard();
        if let cardUnwrapped = card {
            handPlayer.addSubview(cardUnwrapped.image)
            valuePlayer.text = String(handPlayer.subviews.count)
        }
        print("test")
    }
    @IBAction func Stand(_ sender: Any) {
        handPlayer.spacing = 1
        if (handPlayer.subviews.count != 0) {
            handPlayer.spacing = CGFloat(300.0 - Double(handPlayer.subviews.count) * 80.0)
        }
    }
    var deck: Deck = Deck(shuffle: true)
    var player: Player = Player()

    override func viewDidLoad() {
        player.hand.addCards(deck.popCards(count: 3)!)
        print(player.hand.cards)
        print(player.value)
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

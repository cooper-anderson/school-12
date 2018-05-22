//
//  ViewController.swift
//  Blackjack
//
//  Created by Cooper Anderson on 4/10/18.
//  Copyright © 2018 Cooper Anderson. All rights reserved.
//

import UIKit

/*extension Card {
    func createImage(_ parent:UIStackView)->UIImageView {
        parent.addSubview(self.image)
        return self.image
    }
    func draw() {

    }
}*/

class ViewController: UIViewController {
    
    @IBOutlet weak var waypointDealer: UIImageView!
    @IBOutlet weak var waypointPlayer: UIImageView!
    @IBOutlet weak var waypointDeck: UIImageView!
    @IBOutlet weak var valueDealer: UILabel!
    @IBOutlet weak var valuePlayer: UILabel!
    @IBAction func Hit(_ sender: Any) {
        let card = player.hand.cards[getRandom(min: 0, max: player.hand.cards.count-1)]
        card.move(waypointDeck)
        card.animate(waypointPlayer)
    }
    @IBAction func Stand(_ sender: Any) {
        for card in player.hand.cards {
            card.move(waypointDeck)
            card.animate(waypointPlayer)
        }
    }
    var deck: Deck = Deck(shuffle: true)
    var player: Player = Player()

    override func viewDidLoad() {
        player.hand.addCards(deck.popCards(count: 3)!)
        for card in player.hand.cards {
            card.draw(self.view)
        }
        print(player.hand.cards)
        print(player.value)
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

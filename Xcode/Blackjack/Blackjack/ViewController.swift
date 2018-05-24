//
//  ViewController.swift
//  Blackjack
//
//  Created by Cooper Anderson on 4/10/18.
//  Copyright © 2018 Cooper Anderson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var waypointDealer: UIImageView!
    @IBOutlet weak var waypointPlayer: UIImageView!
    @IBOutlet weak var waypointDeck: UIImageView!
    @IBOutlet weak var waypointPile: UIImageView!
    @IBOutlet weak var valueDealer: CountingLabel!
    @IBOutlet weak var valuePlayer: CountingLabel!
    @IBOutlet weak var buttonHit: UIButton!
    @IBOutlet weak var buttonStand: UIButton!
    @IBOutlet weak var winDealer: UIImageView!
    @IBOutlet weak var winPlayer: UIImageView!
    @IBAction func Hit(_ sender: Any) {
        play("hit")
    }
    @IBAction func Stand(_ sender: Any) {
        play("stand")
    }
    @IBAction func Reset(_ sender: Any) {
        reset()
    }
    
    var screen: Screen?
    var blackjack: Blackjack?
    var playable: Bool = false
    
    /*var screen
    var blackjack = Blackjack(screen: screen)*/
    
    override func viewDidLoad() {
        screen = Screen(view: self.view, deck: waypointDeck, dealer: waypointDealer, player: waypointPlayer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.reset()
        }
        //blackjack: Blackjack
        super.viewDidLoad()
    }
    
    func reset() {
        if let _ = blackjack {
            for card in blackjack!.dealer.hand.cards + blackjack!.player.hand.cards {
                card.animate(waypointPile)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    card.imageView.removeFromSuperview()
                }
            }
        }
        blackjack = Blackjack(screen: screen!)
        blackjack!.deal()
        playable = true
        buttonHit.isEnabled = true
        buttonStand.isEnabled = true
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.buttonHit.alpha = 1
            self.buttonStand.alpha = 1
            self.winDealer.alpha = 0
            self.winPlayer.alpha = 0
        })
        updateNumbers()
    }
    
    func play(_ action: String) {
        if (playable) {
            blackjack!.play(action)
            blackjack!.round()
            updateNumbers()
            if max(blackjack!.dealer.value, blackjack!.player.value) >= 21 || blackjack!.player.standing {
                blackjack!.dealer.hand.cards.last!.imageView.image = blackjack!.dealer.hand.cards.last!.image
                buttonHit.isEnabled = false
                buttonStand.isEnabled = false
                var didDealerWin: Bool = false
                var didPlayerWin: Bool = false
                if blackjack!.player.hasBusted && blackjack!.dealer.hasBusted {
                    didDealerWin = true
                    didPlayerWin = true
                } else if blackjack!.player.hasBusted {
                    didDealerWin = true
                } else if blackjack!.dealer.hasBusted {
                    didPlayerWin = true
                } else if blackjack!.dealer.hasBlackjack {
                    didDealerWin = true
                } else if blackjack!.player.hasBlackjack {
                    didPlayerWin = true
                } else if blackjack!.dealer.value > blackjack!.player.value {
                    didDealerWin = true
                } else if blackjack!.player.value > blackjack!.dealer.value {
                    didPlayerWin = true
                } else if blackjack!.player.value == blackjack!.dealer.value {
                    didDealerWin = true
                    didPlayerWin = true
                }
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.buttonHit.alpha = 0.5
                    self.buttonStand.alpha = 0.5
                    self.winDealer.alpha = didDealerWin ? 1 : 0
                    self.winPlayer.alpha = didPlayerWin ? 1 : 0
                })
            }
        }
    }
    
    func updateNumbers() {
        if (!blackjack!.player.playing) {
            if let value = blackjack?.dealer.value {
                valueDealer.countFromCurrent(to: Float(value), duration: 0.5)
            } else {
                valueDealer.countFromCurrent(to: 0, duration: 0.5)
            }
        } else {
            valueDealer.text = "?"
        }
        if let value = blackjack?.player.value {
            valuePlayer.countFromCurrent(to: Float(value), duration: 0.5)
        } else {
            valuePlayer.countFromCurrent(to: 0, duration: 0.5)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

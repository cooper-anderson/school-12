//
//  Blackjack.swift
//  Blackjack
//
//  Created by Cooper Anderson on 4/17/18.
//  Copyright © 2018 Cooper Anderson. All rights reserved.
//

import Foundation

class Player {
    var hand: Deck
    var value: Int {
        get {
            var value: Int = 0
            var aces: Int = 0
            for card in self.hand.cards {
                value += card.rank.value
                aces += card.rank.value == 11 ? 1 : 0
            }
            while value > 21 && aces > 0 {
                value -= 10
                aces -= 1
            }
            return value
        }
    }
    
    init(cards: Array<Card>?=nil) {
        if let c = cards {
            self.hand = Deck(full: false, cards: c)
        } else {
            self.hand = Deck(full: false)
        }
    }
}

class Blackjack {
    var deck: Deck
    var dealer: Player
    var player: Player
    
    init() {
        self.deck = Deck(shuffle: true)
        self.dealer = Player()
        self.player = Player()
    }
}

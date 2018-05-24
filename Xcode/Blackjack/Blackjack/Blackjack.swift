//
//  Blackjack.swift
//  Blackjack
//
//  Created by Cooper Anderson on 4/17/18.
//  Copyright © 2018 Cooper Anderson. All rights reserved.
//

import Foundation
import UIKit

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
    var standing: Bool = false
    var playing: Bool = true
    var hasBlackjack: Bool = false
    var hasBusted: Bool = false
    
    init(cards: Array<Card>?=nil) {
        if let c = cards {
            self.hand = Deck(full: false, cards: c)
        } else {
            self.hand = Deck(full: false)
        }
    }
}

class Screen {
    var view: UIView
    var deck: UIImageView
    var dealer: UIImageView
    var player: UIImageView
    
    init(view: UIView, deck: UIImageView, dealer: UIImageView, player: UIImageView) {
        self.view = view
        self.deck = deck
        self.dealer = dealer
        self.player = player
    }
}

class Blackjack {
    var screen: Screen
    var deck: Deck
    var pile: Deck
    var dealer: Player
    var player: Player
    
    init(screen:Screen) {
        self.screen = screen
        self.deck = Deck(shuffle: true)
        self.pile = Deck(full: false)
        self.dealer = Player()
        self.player = Player()
    }
    
    func deal_card() -> Card {
        if self.deck.count == 0 {
            self.deck = self.pile.shuffle()
            self.pile = Deck(full: false)
        }
        return self.deck.popCard()!
    }
    
    func deal() {
        for _ in 1...2 {
            let cardPlayer = self.deal_card()
            let cardDealer = self.deal_card()
            cardPlayer.draw(self.screen.view).move(self.screen.deck)
            cardDealer.draw(self.screen.view).move(self.screen.deck)
            self.player.hand.addCard(cardPlayer)
            self.dealer.hand.addCard(cardDealer)
        }
        self.dealer.hand.cards.last!.imageView.image = Card.back
        moveCards()
    }
    
    func play_dealer() {
        while self.dealer.value < 17 {
            let cardDealer = self.deal_card()
            cardDealer.draw(self.screen.view).move(self.screen.deck)
            self.dealer.hand.addCard(cardDealer)
        }
        let total = self.dealer.value
        if total == 21 {
            self.dealer.hasBlackjack = true
        } else if total > 21 {
            self.dealer.hasBusted = true
        }
    }
    
    func round() {
        let total = self.player.value
        if total == 21 {
            self.player.playing = false
            self.player.hasBlackjack = true
        } else if total > 21 {
            self.player.playing = false
            self.player.hasBusted = true
        }
        if self.player.playing == false {
            self.play_dealer()
        }
        moveCards()
    }
    
    func play(_ entry: String) {
        if entry.lowercased().contains("h") {
            if self.player.playing {
                let cardPlayer = self.deal_card()
                cardPlayer.draw(self.screen.view).move(self.screen.deck)
                self.player.hand.addCard(cardPlayer)
            }
        } else if entry.lowercased().contains("s") {
            self.player.standing = true
            self.player.playing = false
        }
    }
    
    func moveCards() {
        let offset: CGFloat = -16;
        /*if (self.dealer.hand.cards.count > 0) {
            self.dealer.hand.cards.last!.imageView.image = (self.player.standing) ? self.dealer.hand.cards.last!.image : Card.back
        }*/
        for (index, card) in self.dealer.hand.cards.enumerated() {
            card.animate(x: self.screen.dealer.center.x + offset*CGFloat(index) - (offset * CGFloat(self.dealer.hand.cards.count-1))/2, y: self.screen.dealer.center.y)
            //card.imageView.sendSubview(toBack: self.screen.view)
        }
        for (index, card) in self.player.hand.cards.enumerated() {
            card.animate(x: self.screen.player.center.x + offset*CGFloat(index) - (offset * CGFloat(self.player.hand.cards.count-1))/2, y: self.screen.player.center.y)
            //card.imageView.sendSubview(toBack: self.screen.view)
        }
    }
}

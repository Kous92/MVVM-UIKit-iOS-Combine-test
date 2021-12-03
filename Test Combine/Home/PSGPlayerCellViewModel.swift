//
//  PSGPlayerViewModel.swift
//  Test Combine
//
//  Created by Koussaïla Ben Mamar on 12/11/2021.
//

import Foundation

// MARK: - PSG Player view model
final class PSGPlayerCellViewModel: PSGPlayerCell {
    let player: PSGPlayer
    let image: String
    let number: Int
    let name: String
    let position: String
    let fromPSGformation: Bool
    
    // Dependency injection
    init(player: PSGPlayer) {
        self.player = player
        self.image = player.imageURL
        self.number = player.number
        self.name = player.name
        self.position = player.position
        self.fromPSGformation = player.fromPSGformation
    }
}

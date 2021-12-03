//
//  Player.swift
//  Test Combine
//
//  Created by Koussaïla Ben Mamar on 01/11/2021.
//

import Foundation

struct PSGPlayersResponse: Decodable, Hashable {
    var players: [PSGPlayer]
}

struct PSGPlayer: Decodable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: PSGPlayer, rhs: PSGPlayer) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int
    var name: String
    var number: Int
    var country: String
    var size, weight: Int
    var birthDate: String
    var position: String
    var goals, matches: Int
    var fromPSGformation: Bool
    var imageURL: String
}

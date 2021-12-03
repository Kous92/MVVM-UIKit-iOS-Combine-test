//
//  PlayerFilter.swift
//  Test Combine
//
//  Created by Koussaïla Ben Mamar on 21/11/2021.
//

import Foundation

enum PlayerFilter: String {
    case noFilter = "No filter"
    case goalkeepers = "Goalkeepers"
    case defenders = "Defenders"
    case midfielders = "Midfielders"
    case forwards = "Forwards"
    case fromPSGFormation = "Players trained at PSG"
    case numberOrder = "By number in ascending order"
    case alphabeticalOrder = "Alphabetical order"
}

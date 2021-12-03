//
//  PlayerViewModel.swift
//  Test Combine
//
//  Created by Koussaïla Ben Mamar on 01/11/2021.
//

import Foundation
import Combine

final class PSGPlayersViewModel {
    // The subjects,
    // Les sujets, those which emits and receive events
    var updateResult = PassthroughSubject<Bool, APIError>()
    @Published var searchQuery = ""
    @Published var activeFilter: PlayerFilter = .noFilter
    
    private var playersData: PSGPlayersResponse?
    private var playersViewModel = [PSGPlayerCellViewModel]()
    var filteredPlayersViewModels = [PSGPlayerCellViewModel]()
    private let apiService: APIService
    
    // For memory management and subscriptions cancellations
    private var subscriptions = Set<AnyCancellable>()
    
    // Dependency injection
    init(apiService: APIService = PSGAPIService()) {
        self.apiService = apiService
        setBindings()
        getPlayers()
    }
    
    func getPlayers() {
        apiService.fetchPlayers { [weak self] result in
            switch result {
            case .success(let response):
                self?.playersData = response
                self?.parseData()
            case .failure(let error):
                print(error.rawValue)
                self?.updateResult.send(completion: .failure(error))
            }
        }
    }
    
    private func setBindings() {
        $searchQuery
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.searchPlayer()
            }.store(in: &subscriptions)
        
        $activeFilter.receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] value in
                self?.applyFilter()
            }.store(in: &subscriptions)
    }
}

extension PSGPlayersViewModel {
    private func parseData() {
        guard let data = playersData, data.players.count > 0 else {
            // No players downloaded
            updateResult.send(false)
            
            return
        }
        
        data.players.forEach { playersViewModel.append(PSGPlayerCellViewModel(player: $0)) }
        filteredPlayersViewModels = playersViewModel
        updateResult.send(true)
    }
    
    // Given there is no suitable API, we simulate the search by filtering the results among the players, downloaded initially.
    private func searchPlayer() {
        // If the content is empty, that means no filter to apply and the list contains back every player
        guard !searchQuery.isEmpty else {
            activeFilter = .noFilter
            filteredPlayersViewModels = playersViewModel
            updateResult.send(true)
            
            return
        }
        
        filteredPlayersViewModels = playersViewModel.filter { $0.name.lowercased().contains(searchQuery.lowercased()) }
        
        if filteredPlayersViewModels.count > 0 {
            updateResult.send(true)
        } else {
            updateResult.send(false)
        }
    }
    
    private func applyFilter() {
        switch activeFilter {
        case .noFilter:
            filteredPlayersViewModels = playersViewModel
        case .numberOrder:
            // Sorting by number in ascending order
            filteredPlayersViewModels = playersViewModel.sorted(by: { player1, player2 in
                return player1.number < player2.number
            })
        case .goalkeepers:
            filteredPlayersViewModels = playersViewModel.filter { $0.position == "Goalkeeper" }
        case .defenders:
            filteredPlayersViewModels = playersViewModel.filter { $0.position == "Right-back" || $0.position == "Central defender" || $0.position == "Defender" || $0.position == "Left-back" }
        case .midfielders:
            filteredPlayersViewModels = playersViewModel.filter { $0.position == "Midfielder" || $0.position == "Attacking midfielder" || $0.position == "Defensive midfielder" }
        case .forwards:
            filteredPlayersViewModels = playersViewModel.filter { $0.position == "Forward" || $0.position == "Striker" }
        case .fromPSGFormation:
            // Every player from the PSG Training Centre
            filteredPlayersViewModels = playersViewModel.filter { $0.player.fromPSGformation }
        case .alphabeticalOrder:
            filteredPlayersViewModels = playersViewModel.sorted(by: { player1, player2 in
                return player1.name < player2.name
            })
        }
        
        updateResult.send(true)
    }
}


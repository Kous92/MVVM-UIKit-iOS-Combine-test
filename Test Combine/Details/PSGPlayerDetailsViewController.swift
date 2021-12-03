//
//  PSGPlayerDetailsViewController.swift
//  Test Combine
//
//  Created by Koussaïla Ben Mamar on 12/11/2021.
//

import UIKit
import Combine

final class PSGPlayerDetailsViewController: UIViewController {
    @IBOutlet weak var playerNumberLabel: UILabel!
    @IBOutlet weak var playerImage: CachedImageView!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerPositionLabel: UILabel!
    @IBOutlet weak var playerSizeLabel: UILabel!
    @IBOutlet weak var playerWeightLabel: UILabel!
    @IBOutlet weak var playerCountryLabel: UILabel!
    @IBOutlet weak var playerBirthdateLabel: UILabel!
    @IBOutlet weak var playerTrainedLabel: UILabel!
    @IBOutlet weak var playerPlayedMatchesLabel: UILabel!
    @IBOutlet weak var playerGoalsLabel: UILabel!
    
    private var viewModel: PSGPlayerDetailsViewModel!
    private var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBindings()
    }
    
    @IBAction func backToMainView(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // Dependency injection
    func configure(with viewModel: PSGPlayerDetailsViewModel) {
        self.viewModel = viewModel
    }
}

extension PSGPlayerDetailsViewController {
    // The view will be updated automatically with these reactive data bindings (subscriptions).
    private func setBindings() {
        viewModel.$number
            .receive(on: RunLoop.main)
            .compactMap { String($0) }
            .assign(to: \.text, on: playerNumberLabel)
            .store(in: &subscriptions)
        
        viewModel.$name
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .assign(to: \.text, on: playerNameLabel)
            .store(in: &subscriptions)
        
        viewModel.$position
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .assign(to: \.text, on: playerPositionLabel)
            .store(in: &subscriptions)
        
        viewModel.$size
            .receive(on: RunLoop.main)
            .compactMap { "Size: " + String($0) + " cm" }
            .assign(to: \.text, on: playerSizeLabel)
            .store(in: &subscriptions)
        
        viewModel.$weight
            .receive(on: RunLoop.main)
            .compactMap { "Weight: " + String($0) + " kg" }
            .assign(to: \.text, on: playerWeightLabel)
            .store(in: &subscriptions)
        
        viewModel.$country
            .receive(on: RunLoop.main)
            .compactMap { "Country: " + $0 }
            .assign(to: \.text, on: playerCountryLabel)
            .store(in: &subscriptions)
        
        viewModel.$birthDate
            .receive(on: RunLoop.main)
            .compactMap { "Birth date: " + $0 }
            .assign(to: \.text, on: playerBirthdateLabel)
            .store(in: &subscriptions)
        
        viewModel.$fromPSGformation
            .receive(on: RunLoop.main)
            .compactMap { "Trained at PSG: " + ($0 ? "yes": "no") }
            .assign(to: \.text, on: playerTrainedLabel)
            .store(in: &subscriptions)
        
        viewModel.$matches
            .receive(on: RunLoop.main)
            .compactMap { "Played: " + String($0) }
            .assign(to: \.text, on: playerPlayedMatchesLabel)
            .store(in: &subscriptions)
        
        viewModel.$goals
            .receive(on: RunLoop.main)
            .compactMap { "Goals: " + String($0) }
            .assign(to: \.text, on: playerGoalsLabel)
            .store(in: &subscriptions)
        
        // Reactive update of the image
        viewModel.$image
            .receive(on: RunLoop.main)
            .compactMap{ URL(string: $0) }
            .sink { [weak self] url in
                self?.playerImage.loadImage(fromURL: url)
        }.store(in: &subscriptions)
    }
}

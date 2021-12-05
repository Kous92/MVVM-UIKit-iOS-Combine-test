# iOS (Swift 5): MVVM test with Combine and UIKit

**MVVM** and functional reactive programming (FRP) are very used in iOS development inside companies. Here, there is an example where I implement the **MVVM** architecture with **Combine**, Apple's official framework, being the equivalent of the famous **RxSwift** framework. All with **UIKit**.

## Navigation plan
- [MVVM architecture](#mvvm)
- [Functional reactive programming with Combine](#combine)
- [Example](#example)
- [Used elements with Combine]()
    + [Updating](#update)
    + [Search](#search)
    + [Filtering](#filtering)
    + [Detailed view](#details)

## <a name="mvvm"></a>MVVM architecture

MVVM architecture (Model View ViewModel) is a design pattern which allows to seperate business logic and UI interactions. Starting from MVC, the view and the controller are now one in **MVVM**. In iOS with UIKit, the `ViewController` belongs to the view part. Furthermore, the `ViewController` no longer have to manage business logic and no longer have references to data models.

The novelty being the View Model is that it has the responsibility to manage the business logic and update the view by disposing of properties that the view will display through data binding.

Data binding is a link between the view and the view model, where the view through user interactions will send a signal to the view model to run a specific business logic. This signal will allow the update of the data of the model data and thus allow automatic refresh of the view. Data binding in iOS can be done with:
- Delegation
- Callbacks (closures)
- Functional Reactive Programming (**RxSwift, Combine**)

### Pros and cons of MVVM
- Main pros: 
    + Suitable architecture to separate the view from business logic through a `ViewModel`.
    + `ViewController` lightened.
    + Business logic tests easier to do (Code coverage increased)
    + Suitable with **SwiftUI**
    + Suitable with reactive programming (**RxSwift, Combine**)
- Cons:
    + `ViewModel` can be massive if the separation of the elements is not mastered, so it's hard to cut correctly structures, classes and methods in order to respect the 1st principle of **SOLID** being the SRP: Single Responsibility Principle. **MVVM-C** alternative with uses a `Coordinator` is useful to lighten the views and manage the navigation between views.
    + May be complex for very small projects.
    + Unsuitable for very large and complex projects, it will be better to switch to **VIPER** or **Clean Architecture (VIP, MVVM, Clean Swift, ...)**. **MVVM** can be integrated inside a **Clean Architecture**.
    + Complex mastery for beginners (especially with **UIKit**)

![MVVM](https://github.com/Kous92/MVVM-UIKit-iOS-Combine-test/blob/main/MVVM.png)<br>

## <a name="combine"></a>Functional Reactive Programming with Combine

The reactive programming is an asynchronous programming paradigm, oriented around data stream and the propagation of change. This model is based on the observer pattern where a stream creates data at different times. Actions are then executed in an orderly fashion.

These streams are modelized with `Observables` (`Publishers` with **Combine**) which will emit events of 3 types:
- Value
- Error
- Completion (the stream has no data to send anymore)

Like event-based programming, the reactive programming uses also `Observers` (`Subscribers` with **Combine**) which will subscribe to the events, emitted by `Observables`, then receive the data (listening for changes) of the stream in real time in order to execute actions depending to the signal.

The 3rd element of reactive programming is named `Subjects` which acts as dual way, both as an `Observable` as well as `Observer`. `Subjects` can emit and receive events.

We talk about **FRP: Functional Reactive Programming**) the way of combining data streams with function type operators to process the data (formatting, value updating, filtering, merging several streams into one, ...), like those in the arrays with:
- `map`
- `filter`
- `flatMap`
- `compactMap`
- `reduce`
- And more...

Functional Reactive Programming is perfectly suitable for the data binding of **MVVM** architecture with an observable in the view model to emit the received events, especially asynchronous ones (network calls, GPS updating, model data updating, ...) and an observer in the view which will subscribe to the view model observable and listen to any change.

On the other hand, it is also necessary to use `Cancellables` which will cancel the subscription of the observers (`AnyCancellable` with **Combine**) and manage the memory deallocation in order to avoid **memory leaks**.

Functional reactive programming remains one of the most complex concepts to learn and master (especially by oneself in autodidact), the definition itself is complex to to understand and assimilate.
But once mastered, this concept becomes a powerful weapon to write optimal asynchronous functionnalities (chaining HTTP calls, asynchronous server check before validation, ...), having reactive interface which updates itself automatically when changes appended in real time from the data stream, to replace delegation (passing data backward from secondary to main view, ...), ... **Furthermore, knowing how to use reactive programming is also essential to integrate an iOS application project in a compan, being one of the most required skills.**

**Combine** requires **iOS 13** or above for any iOS application. The main advantage of **Combine** is at the level of performance and optimization, since everything is managed by Apple, and Apple can go at the deepest of the operating system elements, thing that third-party framework developers cannot do. External framework dependency is now reduced.

Compared to **RxSwift**, **Combine** remains less complete in terms of operators for specific and advanced cases. Also **Combine** is not fully suitable with **UIKit** especially for bindings with UI components, thing that is more complete with **RxSwift** (**RxCocoa**).

## <a name="example"></a>Example

Here, I propose as example a real-time refresh of a `TableView` of PSG players with **MVVM** architecture. This update is done in several ways:
1. At app launching, through an HTTP `GET` call from an online JSON file. The donwloaded data are therefore arranged on `ViewModel` dedicated to `TableViewCell`.
2. When searching a player, filtering will be applied automatically depending on the text entered, and then refresh in real-time the UI list with filtered data.

<img src="https://github.com/Kous92/Test-MVVM-Combine-UIKit-iOS/blob/main/ReactiveSearch.gif" width="350">

3. By tapping on filtering button, a `ViewController` appears to allow the selection of a filter in order to update the list of the main view from the following criterias: 
    + Goalkeepers
    + Defenders
    + Midfielders
    + Forwards
    + PSG trained players 🔵🔴
    + By alphabetical order
    + By number in ascending order

<img src="https://github.com/Kous92/Test-MVVM-Combine-UIKit-iOS/blob/main/ReactiveFilters.gif" width="350">

4. By tapping on a cell, a `ViewController` appears to display the details of selected players (image, name, number, position, trained or not at PSG, birth date, country, size, weight, number of played matched and goals scored)

<img src="https://github.com/Kous92/Test-MVVM-Combine-UIKit-iOS/blob/main/ReactiveDetails.gif" width="350">

**ICI C'EST PARIS (HERE IT'S PARIS) 🔵🔴**

### The uses elements of Combine in this example

#### 1) <a name="update"></a> Reactive update

For reactive update, I use a subject in my view model (here `PSGPlayersViewModel`). When the app is launched and made the HTTP call from the server, the subject will emit a success event if the download is complete and if the list of view models of `TableViewCell` is updated. The update subject `updateResult` is a `PassthroughSubject`. A subject have 2 types in his declaration: a value and an element for the errors (`Never` if no errors to handle). Here it's a case if an error occurs, especially at app launch during the HTTP call (no Internet connection, error 404, JSON decoding to objects,...). The particularity of the `PassthroughSubject` is that there is no need to give an initial value to emit.

```swift
import Combine

final class PSGPlayersViewModel {
    // Subjects, those who emits and receive events.
    var updateResult = PassthroughSubject<Bool, APIError>()
}
```

When downloading, if the data are updated, we use `send(value)` method to emit an event.
If an error occurs, we use `send(completion: .failure(error)`. Otherwise, we send a value.
```swift
import Combine

final class PSGPlayersViewModel {
    ...
    func getPlayers() {
        apiService.fetchPlayers { [weak self] result in
            switch result {
            case .success(let response):
                self?.playersData = response
                self?.parseData()
            case .failure(let error):
                print(error.rawValue)
                self?.updateResult.send(completion: .failure(error)) // Emit an error
            }
        }
    }

    private func parseData() {
        guard let data = playersData, data.players.count > 0 else {
            // No player downloaded
            updateResult.send(false)
            
            return
        }
        
        data.players.forEach { playersViewModel.append(PSGPlayerCellViewModel(player: $0)) }
        filteredPlayersViewModels = playersViewModel
        updateResult.send(true) // We notify the view that the data are updated to refresh the TableView
    }
}
```

At `ViewController` level, we use `updateResult` propery in order to do the data binding between view and view model. Given that reactive operations are asynchronous, we begin with `receive(on: )` to precise on which thread we will receive the value. UI operation can be done only on the main thread, so we will put in parameter `RunLoop.main` or `DispatchQueue.main` (both are same).

The, the subscription to process the events is done with `sink(completion: , receive: value)`. In `completion`, it's here when we process 2 situations, either if the stream stops emitting, or if there is an error. In `receiveValue`, it's here when we can do the operations UI like refreshing `TableView`. We store after the subscription in an `AnyCancellable` list in order to avoid memory leaks.
```swift
final class MainViewController: UIViewController {
    ...
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel = PSGPlayersViewModel()

    private func setBindings() {
        func setUpdateBinding() {
            // View receives in real-time the emitted event by the subject
            viewModel.updateResult.receive(on: RunLoop.main).sink { completion in
                switch completion {
                case .finished:
                    print("OK: done")
                case .failure(let error):
                    // We can show for example an alert to notify directly that an error has occured
                    print("Error received: \(error.rawValue)")
                }
            } receiveValue: { [weak self] updated in
                // View model data are updated, we refresh the list
                self?.loadingSpinner.stopAnimating()
                self?.loadingSpinner.isHidden = true
                
                if updated {
                    self?.updateTableView()
                } else {
                    self?.displayNoResult()
                }
            }.store(in: &subscriptions)
        }
        
        setUpdateBinding()
    }
}
```
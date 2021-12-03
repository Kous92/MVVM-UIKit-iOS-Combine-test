# iOS (Swift 5): Test MVVM avec Combine et UIKit

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

Data binding is a link between the view and the view model, where the view through user interactions will send a signal to the view model to run a specific business logic. This signal will allow 
Le data binding est un lien entre la vue et la vue modèle, où la vue par le biais des interactions avec l'utilisateur va envoyer un signal à la vue modèle afin d'effectuer une logique métier spécifique. This signal will allow the update of the data of the model data and thus allow automatic refresh of the view. Data binding in iOS can be done with:
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

![MVVM](https://github.com/Kous92/Test-MVVM-Combine-UIKit-iOS/blob/main/MVVM.png)<br>

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

Functional reactive programming remains one of the most complex concepts to learn and master
La programmation réactive fonctionnelle reste l'une des notions les plus complexes à apprendre et à maîtriser (especially by oneself in autodidact), the definition itself is complex to to understand and assimilate.
But once mastered, this concept becomes a powerful weapon to write optimal asynchronous functionnalities (chaining HTTP calls, asynchronous server check before validation, ...), having reactive interface which updates itself automatically when changes appended in real time from the data stream, to replace delegation (passing data backward from secondary to main view, ...), ... **Furthermore, knowing how to use reactive programming is also essential to integrate an iOS application project in a compan, being one of the most required skills.**

**Combine** requires **iOS 13** or above for any iOS application. The main advantage of **Combine** is at the level of performance and optimization, since everything is managed by Apple, and Apple can go at the deepest of the operating system elements, thing that third-party framework developers cannot do. External framework dependency is now reduced.

Compared to **RxSwift**, **Combine** remains less complete in terms of operators for specific and advanced cases. Also **Combine** is not fully suitable with **UIKit** especially for bindings with UI components, thing that is more complete with **RxSwift** (**RxCocoa**).
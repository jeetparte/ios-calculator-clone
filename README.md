# iOS Calculator App Clone

<p align="center">
<img align="center" src="https://user-images.githubusercontent.com/17269750/160439290-48ef9fd9-b07c-4084-8843-7a1d6ff1dc58.png" width=30% height=30%>
&nbsp;&nbsp;&nbsp;&nbsp;  
<img align="center" src="https://user-images.githubusercontent.com/17269750/160439317-c27ed1a4-5eaf-4b3f-b397-715669ae3cc2.png" width=60% height=60%>
</p>

## About

A clone of the system Calculator app on iOS. 

## Why?

This project serves 2 main purposes:

1. as an exercise in building a simple mobile app from scratch. 
* I picked something simple so that I could finish the project in a reasonable amount of time, but I also wanted to experience some of the complexity that's part of a real application. 
That's why I'm trying to achieve the same behaviour and fit-and-finish of the system app.
2. to document parts of the development process.
* This is mainly my design and implementation decisions for some of the essential features in the app.
* But also things that I learnt during this project or found interesting (e.g. test-driven development).

## TL; DR

Building even a simple app can take a significant amount of effort. This is because our simplistic view of things (rightfully) ignores "implementation details". It is only when we create those things (or provide those services), do we realize the essential complexities that go into it. Consumption is easy, creation difficult.

## The Experience

As stated above, my goal was to "pick something simple so that I could finish the project in a reasonable amount of time". I think I've failed here because there's a lot of detailing in the iOS system calculator app that makes it not so simple.

I lost motivation after a while when I realized all my efforts were going into a dummy app that couldn't make it to the App Store.
By this point, I'd also fairly accomplished my implicit goal of being able to build an app from scratch and being comfortable building UI.

Next, I'd like to spend my time on a "real" project that keeps me motivated till the end.

Features I did not implement are:

1. The round bracket keys.
2. Dynamic Type support for the display result.
3. Swipe-to-undo on the display result.

Additionally, I implemented a simpler, single-step calculator where calculations are performed immediately and operator precedence is not taken into account.


## Development

### Building the UI


#### Layout

I built the UI with UIKit and Auto-Layout. Auto-layout is an interesting contraints-based system for laying out UI elements. You describe the position and size of UI elements in points and w.r.t. other elements in a non-ambigious way and the layout engine will do the rest.

In this app, I had 2 different set of UI descriptions (called *constraints*) corresponding to portrait and landscape orientation. Using the appropriate hook event for detecting orientation change, I then activated the corresponding set of constraints while deactivating the other (important otherwise we'd be giving the system 2 conflicting sets of descriptions).

```swift
var portraitConstraints: [NSLayoutConstraint] = ...
var landscapeConstraints: [NSLayoutConstraint]= ...

override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)
    // Switch between standard and scientific mode on orientation change
    // (hide/show scientific buttons and swap constraints)
    let previousOrientation = self.view.window?.windowScene?.interfaceOrientation
    coordinator.animate { viewControllerTransitionCoordinatorContext in
        let newOrientation = self.view.window?.windowScene?.interfaceOrientation
        
        if newOrientation != previousOrientation {
            guard let newOrientation = newOrientation else { return }
            self.activateConstraints(for: newOrientation.simpleOrientation)
            self.toggleRadiansIndicatorVisibility(for: newOrientation.simpleOrientation, isInRadiansMode: self.isInRadiansMode)
        }
    }
}
```

One thing to notice is how we get the previous and new orientation. Inside the general method, we get the current orientation. To get the new orientation we must wait until later. The function passed as argument to the `coordinator.animate` method isn't called until later and turns out to be perfect for this purpose.

#### Highlight trail on buttons

An interesting feature to implement was the one where if you drag your finger on the grid of buttons, it leaves a trail as it highlights the button currently under the touch and unhighlights the previous one.

Handling a sequence of touches is made easier with UIKit's gesture recognizers. We have to put the gesture recognizers on the parent view which contains all the buttons. Initially, we have to iterate over all the buttons to find which button is under the touch (see `highlightButtonUnderTouch()` below). For peformance reasons, once we find the button we hold onto it until the touch leaves that button.

The method that handles all this is big so I've removed part of the code here, keeping the comments so you can better understand the logic:

```swift

@objc func buttonPressOrDrag(_ sender: UILongPressGestureRecognizer) {  
    func highlightButtonUnderTouch() {
        for candidate in highlightableViews {
            let touchLocation = sender.location(in: candidate)
            let isTouchInside = candidate.point(inside: touchLocation, with: nil)
            
            if isTouchInside {
                candidate.highlightState = .active
                self.currentlyHighlightedView = candidate
                break
            }
        }
    }
    
    switch sender.state {
    case .began:
        // touch down event -
        // if there's a button under this touch, highlight it and
        // make it the "currently highlighted button"
        highlightButtonUnderTouch()
    case .changed:
        // drag events -
        // see if the touch is still on the curently highlighted button
        ...
            // if it is, do nothing
            if isStillOnCurrentButton { return }
            // if it isn't, unhighlight the button
            self.currentlyHighlightedView = nil
            // and check if the touch is on another button (below)
                    
        // if there is no currently highlighted button, check if the touch is on another button
        highlightButtonUnderTouch()
    case .ended:
        // touch up event -
        // for the button under this touch,
        // fire its action handler and unhighlight it
        ...
    }
}
```

Making a flowchart of the states and transitions on paper helped me here.

#### Repeated button presses

Visually, buttons unhighlight gradually and for that reason, we use an animation. One of the problems I encountered was repeated button taps didn't register correctly. Initially, I feared this was because I was doing some heavy-calculation / processing on the tap. But that wasn't the case at all. Turns out interacting with a view that's animating is disabled by default so we have to ask for it explicitly by specifying the `.allowsUserInteraction` option in the call to `UIView.animate`:

```swift
var highlightState: HighlightState = .normal {
    didSet {
        if highlightState == oldValue { return }
        
        switch highlightState {
        case .normal:
            // remove highlight gradually
            if let colorForState = self.stateBackgroundColorMap[highlightState] {
                UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction) {
                    self.backgroundColor = colorForState
                }
            }
        case .active:
            // apply highlight immediately
            if let colorForState = self.stateBackgroundColorMap[highlightState] {
                self.backgroundColor = colorForState
            }
        }
    }
}
```

Note that creating a `highlightState` property based on an enum means we simply have to set it and the appropriate visual change follows.

#### Implicit Invocation with NotificationCenter

A recent term I learnt reading the Intro to Software Architecture paper (cite here) is 'implicit invocation'. Basically, it's the reactive mechanism where you register a set of methods beforehand for certain events and the methods are then called for you *implicitly* when the said events occur. I guess the pub-sub pattern is a specific implementation of implicit invocation?

Anyway, it was quite useful to communicate a button tap from an individual button to the top-level object (the view controller) that handled all taps. The reason is convenience as you can communicate between objects that are distant to each other.

However, there's a bit of setup required (registering for a notification, creating a method with a specific signature, having to unwrap the sent data etc.) and there are other drawbacks to this (read the intro to architecture paper) so you'd want to be judicious in its use.

### ...

There's a lot more I can talk about this project. Makes me wonder why am I even doing this? Perhaps that's the only thing to look forward to with a app project that's purely for learning purposes.

Maybe later ...

## Benefits of doing this project

Apart from improving my programming skills, doing this project also had other benefits:

1. Simplified my job interview.
  * Yes that's right. I interviewed for a mobile app developer position and they were happy to look at this project and interview me based on that.
2. Made me realize the value of good architecture. (good architecture = code is easy to change)
3. Allowed me to experiment with new ideas I was learning like test-driven development. 
  * I think having a test-bed of sorts while you're learning something new is a good idea. It's natural to want to incorporate or experiment with new things you learn but it's not always a good idea to do that on your professional projects.

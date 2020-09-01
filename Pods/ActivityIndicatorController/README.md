# ActivityIndicatorController
An ActivityIndicatorView inside an alert controller.

The view controller will look and behave as the `.alert` style of a
`UIAlertController`, inheriting its UI and animations.

## Installation

### Cocoapods
```ruby
pod 'ActivityIndicatorController', '~> 1.2.0'
```

## Usage
The ActivityIndicatorViewController should be presented and dismissed as you
would any other view controller.

```swift
let activityViewController = ActivityIndicatorViewController()
self.present(activityViewController, animated: true, completion: nil)

// some lengthy task

activityViewController.dismiss(animated: true, completion: nil)
```

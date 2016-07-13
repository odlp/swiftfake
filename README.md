# Swiftfake

[![Gem Version](https://badge.fury.io/rb/swiftfake.svg)](https://badge.fury.io/rb/swiftfake)

Generate test fakes from Swift code. The fakes allow you to:

- Verify how many times a function was called
- Verify what arguments were received
- Return a canned value

## Installation

- `ruby -v` to check your Ruby version is 2.1+
- `brew install sourcekitten` - [SourceKitten](https://github.com/jpsim/SourceKitten) is used in the Swift parsing
- `gem install swiftfake`

## Creating fakes

Pass a Swift file path and the fake will be printed to STDOUT:

```bash
swiftfake ./app/MySwiftClass.swift
```

You could then pipe the output:

```bash
# To clipboard
swiftfake ./app/MySwiftClass.swift | pbcopy

# To a file
swiftfake ./app/MySwiftClass.swift > ./test/FakeMySwiftClass.swift
```

## Using the fakes via subclassing

> Subclassing is a marmite solution to faking objects in Swift. Purists may prefer a stubbed implementation of a protocol, allowing a real and fake object to be swapped in a manner transparent to the caller. But in practice subclassing requires less code since no protocol is needed.

If we have a `WidgetViewController` which consumes a `WidgetService`, we may wish to verify the interactions with & provide a canned response from a `FakeWidgetService`, especially if the service has complex business logic.

#### Subject under test

Here's the `WidgetViewController` which calls a `WidgetService` instance:

```swift
import UIKit

class WidgetViewController: UIViewController {

    var widgetService = WidgetService()
    var widgets: [Widget]?

    override func viewDidLoad() {
        super.viewDidLoad()
        widgets = widgetService.fetchWidgets(true)
    }

}
```

#### Real object

Here's the interface of the real `WidgetService` with complex business logic:

```swift
import Foundation

class WidgetService {

    func fetchWidgets(onlyBlue: Bool) -> [Widget] {
        // ... Complex business logic
        return []
    }

}
```

#### Fake object

And here's a generated `FakeWidgetService` which subclasses the original `WidgetService`:

```swift
import Foundation

@testable import ExampleApp

internal class FakeWidgetService: WidgetService {

    override func fetchWidgets(onlyBlue: Bool) -> [Widget] {
        fetchWidgetsCallCount += 1
        fetchWidgetsArgsForCall.append(onlyBlue)
        return fetchWidgetsReturnValue
    }

    // MARK: - Fake Helpers

    var fetchWidgetsCallCount = 0
    var fetchWidgetsArgsForCall = [Bool]()
    var fetchWidgetsReturnValue = [Widget]()

}
```

- `xCallCount` is a counter for how many times the function has been called.
- `xArgsForCall[n]` stores the arguments received from each call to the function.
- `xReturnValue` is the canned return value which can be set prior to commencing the test.

#### Using the fake in a test

And this is how you could use the fake in a test:

```swift
import XCTest
@testable import ExampleApp

class WidgetViewControllerTests: XCTestCase {

    var vc: WidgetViewController!
    var fakeWidgetService: FakeWidgetService!
    var expectedWidget: Widget!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateInitialViewController() as! WidgetViewController

        expectedWidget = Widget(name: "Widgetty", color: "Blue")
        fakeWidgetService = FakeWidgetService()
        fakeWidgetService.fetchWidgetsReturnValue = [expectedWidget]

        vc.widgetService = fakeWidgetService // Property based injection of fake onto UIViewController

        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
    }

    func testVerifyWidgetServiceInteraction() {
        XCTAssertEqual(fakeWidgetService.fetchWidgetsCallCount, 1)

        XCTAssertEqual(fakeWidgetService.fetchWidgetsArgsForCall[0], true)

        guard let loadedWidgets = vc.widgets else {
            XCTFail("View controller has no widgets")
            return
        }

        XCTAssertTrue(loadedWidgets[0] == expectedWidget)
    }

}
```

## Using the fakes via protocols

On the way!

## Notes

This gem is still in an alpha state.

Roadmap:

- Template overrides
- Fake Protocol implementations
- Implement Bright Futures support
- Handling multiple classes/protocols in the Swift source file

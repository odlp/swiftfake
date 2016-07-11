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

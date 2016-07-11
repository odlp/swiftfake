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

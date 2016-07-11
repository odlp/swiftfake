import UIKit

class WidgetViewController: UIViewController {

    var widgetService = WidgetService()
    var widgets: [Widget]?

    override func viewDidLoad() {
        super.viewDidLoad()
        widgets = widgetService.fetchWidgets(true)
    }

}


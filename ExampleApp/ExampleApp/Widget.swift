import Foundation

struct Widget {
    let name: String
    let color: String
}

func ==(a: Widget, b: Widget) -> Bool {
    return a.name == b.name
        && a.color == b.color
}

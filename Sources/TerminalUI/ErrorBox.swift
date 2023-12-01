import SwiftTUI

import SwiftTUI

public struct ErrorBox: View {
    public var body: some View {
        Text("Hello, world!")
    }
    
    public static func render() {
        let application = Application(rootView: ErrorBox())
        application.start()
        application.stop()
    }
}

import Foundation
import NativeAPI
import Observation
import Shaft
import ShaftSetup

// Use the default backend
ShaftSetup.useDefault()

// Enable hot reloading
#if DEBUG && !os(Windows)
    import SwiftReload
    LocalSwiftReloader(onReload: backend.scheduleReassemble).start()
#endif

runApp(
    NativeAPIDemo()
)

final class NativeAPIDemo: StatefulWidget {
    func createState() -> NativeAPIDemoState {
        NativeAPIDemoState()
    }
}

final class NativeAPIDemoState: State<NativeAPIDemo> {
    let pageByTitle: [String: Widget] = [
        "Window Manager": WindowManagerDemo(),
        "Display Manager": DisplayManagerDemo(),
        "Menu System": MenuDemo(),
    ]

    lazy var selectedPage = ValueNotifier("Window Manager")

    override func initState() {
        super.initState()
        updateTitle()
        selectedPage.addListener(self, callback: handleSelectedPageChanged)
    }

    override func dispose() {
        selectedPage.removeListener(self)
        super.dispose()
    }

    private func handleSelectedPageChanged() {
        updateTitle()
    }

    private func updateTitle() {
        View.maybeOf(context)?.title = "NativeAPI Demo - \(selectedPage.wrappedValue)"
    }

    override func build(context: BuildContext) -> Widget {
        NavigationSplitView {
            // Sidebar navigation
            FixedListView(selection: selectedPage) {
                Section {
                    Text("Features")
                        .textStyle(
                            TextStyle(
                                color: Color(0xFF66_6666),
                                fontSize: 14,
                                fontWeight: .bold,
                            )
                        )
                        .padding(.all(12))
                } content: {
                    MenuTile("Window Manager")
                    MenuTile("Display Manager")
                    MenuTile("Menu System")
                }
            }
        } detail: {
            // Detail view showing selected demo
            let page = pageByTitle[selectedPage.wrappedValue]
            page
                ?? Text("Under construction")
                .center()
                .padding(EdgeInsets.all(20))
        }
    }
}

final class MenuTile: StatelessWidget {
    init(_ title: String) {
        self.title = title
    }

    let title: String

    func build(context: BuildContext) -> Widget {
        ListTile(title) {
            Text(title)
                .textStyle(
                    TextStyle(
                        color: Color(0xFF00_0000),
                        fontSize: 14,
                    )
                )
        }
    }
}

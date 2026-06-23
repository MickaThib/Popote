import SwiftUI

struct ShoppingListPanelView: View {
    
    let date: Date
    let closePanelAction: () -> Void
    
    var body: some View {
        ShoppingListFrameView(
            date: date,
            presentationMode: .panel,
            closePanelAction: closePanelAction
        )
    }
}

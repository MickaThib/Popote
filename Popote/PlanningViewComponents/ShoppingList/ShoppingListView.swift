import SwiftUI

struct ShoppingListView: View {
    
    let date: Date
    
    var body: some View {
        ShoppingListFrameView(
            date: date,
            presentationMode: .embedded
        )
    }
}

//
//  ShoppingListPanelView.swift
//  Popote
//
//  Created by Mickael on 12/06/2026.
//
// Compose la vue détachée (header + liste d'items)

import SwiftUI

struct ShoppingListPanelView: View {
    
    let date: Date
    let closePanelAction: () -> Void
    
    var body: some View {
        
        VStack {
            
            header
            
            ShoppingListContainerView(date: date) { currentList, startOfWeek in
                ShoppingListContentView(
                    startOfWeek: startOfWeek,
                    currentList: currentList
                )
            }
        }
    }
    
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Mes courses")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.vertical, 12)
            
            Spacer()
            
            Button {
                closePanelAction()
            } label: {
                Image(systemName: "arrow.up.right.and.arrow.down.left.rectangle")
                    .font(.system(size: 18))
                    .padding(.trailing, 7)
            }
            .buttonStyle(.plain)
                        
        }
        .foregroundStyle(Color.white)
        .frame(height: 45)
        .background(Color.noon)
    }
}

#Preview {
    ShoppingListPanelView(date: Date(), closePanelAction: {})
}

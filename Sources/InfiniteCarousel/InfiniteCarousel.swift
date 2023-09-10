
//
//  InfiniteCarousel.swift
//  Boiler
//
//  Created by Филипп Переверзев on 26.06.2023.
//

import Foundation
import SwiftUI

public struct InfiniteCarousel<Data, Content>: View where Data: Hashable, Content: View{
    private var content: (Data) -> Content
    @Binding private var selectedElement: Data
    private var modifiedIndexedCollection: [(Int,Data)]
    
    public init?(collection: [Data], selection: Binding<Data>, @ViewBuilder content: @escaping (Data) -> Content) {
        guard !collection.isEmpty else {return nil}
        var modifiedData: [Data] = []
        if let firstElement = collection.first, let lastElement = collection.last {
            modifiedData.append(lastElement)
            modifiedData.append(contentsOf: collection)
            modifiedData.append(firstElement)
        }
        let indexedArray = Array(zip(modifiedData.indices, modifiedData))
        self.modifiedIndexedCollection = indexedArray
        self._selectedElement = selection
        self.content = content
    }
    
    private var selectedIndex: Binding<Int> {
        Binding(
            get: {
                let idx = modifiedIndexedCollection[1...modifiedIndexedCollection.endIndex - 2].firstIndex(where: {$0.1 == selectedElement}) ?? 0
                return idx
            },
            set: { index in
                indexBindingSet(to: index)
            }
        )
    }
    
    private func indexBindingSet(to index: Int){
        switch index{
        case 0:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                selectedElement = lastOriginalElement
            }
        case modifiedIndexedCollection.endIndex - 1:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                selectedElement = firstOriginalElement
            }
        default:
            selectedElement = modifiedIndexedCollection[index].1
        }
    }
    
    private var firstOriginalElement: Data {
        modifiedIndexedCollection.last!.1
    }
    
    private var lastOriginalElement: Data {
        modifiedIndexedCollection.first!.1
    }
    
    public var body: some View{
        TabView(selection: selectedIndex) {
            ForEach(modifiedIndexedCollection, id: \.0) { index, item in
                content(item).tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

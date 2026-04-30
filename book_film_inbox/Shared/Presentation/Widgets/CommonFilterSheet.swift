//
//  CommonFilterSheet.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 10.03.2026.
//

import SwiftUI

struct CommonFilterSheet<TF: FilterTypeOption, FilterState: CommonFilterState, CharacteristicsContent: View> : View
where TF.AllCases: RandomAccessCollection, FilterState.FilterType == TF {

    @Binding var filterState: FilterState
    @Environment(\.dismiss) private var dismiss
    let filterStateInstantiate: () -> FilterState
    @ViewBuilder let characteristicSectionContent: (_ filterState: FilterState) -> CharacteristicsContent

    init(
        filterState: Binding<FilterState>,
        filterStateInstantiate: @escaping () -> FilterState,
        @ViewBuilder characteristicSectionContent: @escaping (FilterState) -> CharacteristicsContent
    ) {
        self._filterState = filterState
        self.filterStateInstantiate = filterStateInstantiate
        self.characteristicSectionContent = characteristicSectionContent
    }
    
    var body: some View {
        NavigationStack {
            List {
                
                if TF.allCases.count > 1 {

                    Section {
                        HStack(spacing: 10) {
                            ForEach(TF.allCases) { type in
                                typeButton(type)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .listRowBackground(Color.clear)
                    }

                }
                
                Section {
                    characteristicSectionContent(filterState)
                }
            }
            .navigationTitle(".title.filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(".button.reset") {
                        filterState = filterStateInstantiate()
                    }
                    .foregroundStyle(filterState.isActive ? .red : .secondary)
                    .disabled(!filterState.isActive)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(".button.apply") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func typeButton(_ type: TF) -> some View {
        let isSelected = filterState.itemType == type
        Button {
            if isSelected {
                filterState.itemType = .all
            } else {
                filterState.itemType = type
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.title2)
                Text(type.label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color(uiColor: .secondarySystemGroupedBackground))
            .foregroundStyle(isSelected ? Color.accentColor : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

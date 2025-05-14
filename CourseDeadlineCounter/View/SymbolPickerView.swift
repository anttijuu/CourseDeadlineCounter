//
//  SymbolPickerView.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 14.5.2025.
//
import SwiftUI

struct SymbolPickerView: View {
	@Environment(\.dismiss) var dismiss

	@Binding var symbolName: String
	@State private var selectedSymbol: String = "hammer"
	let symbolNames = [
		"hammer",
		"pencil.and.list.clipboard",
		"checkmark.seal",
		"checklist.checked",
		"person",
		"person.2",
		"person.3",
		"square.and.arrow.up.badge.clock",
		"book.pages",
		"studentdesk",
		"building.columns",
		"signpost.right.and.left",
		"paperplane",
		"play.display",
		"questionmark.bubble",
		"puzzlepiece.extension",
		"tray.and.arrow.down",
		"pencil.and.ruler",
		"graduationcap",
		"trophy"
	]
	
	var body: some View {
		VStack {
			Form {
				TextField("Symbol name", text: $symbolName)
				Text("Enter a symbol name or pick one from below")
					.font(.caption)
				Picker("Select a symbol", selection: $selectedSymbol, content: {
					ForEach(symbolNames, id: \.self) { symbolName in
						HStack {
							Image(systemName: symbolName)
								.font(.largeTitle)
								.tag(symbolName)
							Text(symbolName)
						}
					}
				}, currentValueLabel: {
					Image(systemName: selectedSymbol)
				})
				.onChange(of: selectedSymbol) { oldValue, newValue in
					symbolName = newValue
				}
			}
			.padding()
			Spacer()
			Button("Close") {
				dismiss()
			}
		}
		.padding()
		.onAppear() {
			if symbolNames.contains(symbolName) {
				selectedSymbol = symbolName
			}
		}
	}
}
#Preview {
	@Previewable @State var symbolName = ""
	SymbolPickerView(symbolName: $symbolName)
}

//
//  PrimaryButtonStyle.swift
//  CourseDeadlineCounter
//
//  Created by Antti Juustila on 8.5.2025.
//

import SwiftUI
import AppKit

struct PrimaryButtonStyle: ButtonStyle {
	/*
	 foregroundColor(.accentColor)
				.background(Color(UIColor.systemBackground))
	 */
	var backgroundColor: Color = Color(NSColor.controlBackgroundColor)
	var textColor: Color = Color(NSColor.controlTextColor)
	var height: CGFloat = 34
	var cornerRadius: CGFloat = 10
	var fontSize: CGFloat = 12
	var disabled: Bool = false
	var textSidePadding: CGFloat = 10
	var weight: Font.Weight = .semibold
	
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding([.leading, .trailing], textSidePadding)
			.frame(maxWidth: .infinity, maxHeight: height)
			.background(disabled ? .gray : backgroundColor)
			.foregroundColor(textColor)
			.cornerRadius(cornerRadius)
			.font(.system(size: fontSize, weight: weight, design: .default))
			.scaleEffect(configuration.isPressed ? 1.2 : 1)
			.animation(.easeOut(duration: 0.2), value: configuration.isPressed)
	}
}

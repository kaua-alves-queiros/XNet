//
//  InteractiveTerminalTextView.swift
//  XNet›
//

import SwiftUI
import AppKit


struct InteractiveTerminalTextView: NSViewRepresentable {
    @Binding var text: String
    var theme: TerminalTheme = .defaultTheme
    var onInput: (String) -> Void
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true
        scrollView.backgroundColor = theme.defaultBackgroundNSColor
        
        let textView = CustomTerminalTextView()
        textView.autoresizingMask = [.width, .height]
        textView.backgroundColor = theme.defaultBackgroundNSColor
        textView.drawsBackground = true
        textView.textColor = theme.defaultForegroundNSColor
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.isRichText = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.insertionPointColor = theme.cursorNSColor
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.lineBreakMode = .byCharWrapping
        textView.textContainerInset = NSSize(width: 15, height: 15)
        textView.focusRingType = .none
        textView.appliedThemeID = theme.id
        textView.selectedTextAttributes = [.backgroundColor: theme.selectionNSColor]
        textView.typingAttributes = terminalTypingAttributes(for: theme)
        
        textView.onInput = { input in
            self.onInput(input)
        }
        
        scrollView.documentView = textView
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? CustomTerminalTextView else { return }
        applyTheme(theme, to: scrollView, textView: textView)
        
        if textView.renderedSource != text || textView.appliedThemeID != theme.id {
            textView.textStorage?.setAttributedString(ansiAttributedString(from: text))
            textView.renderedSource = text
            textView.appliedThemeID = theme.id
            textView.scrollToEndOfDocument(nil)
        }
    }

    private func ansiAttributedString(from source: String) -> NSAttributedString {
        let output = NSMutableAttributedString()
        var fg = theme.defaultForegroundNSColor
        var bg = theme.defaultBackgroundNSColor
        var bold = false
        var current = ""
        var index = source.startIndex
        
        func flush() {
            guard !current.isEmpty else { return }
            let fontWeight: NSFont.Weight = bold ? .semibold : .regular
            let attrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: fg,
                .backgroundColor: bg,
                .font: NSFont.monospacedSystemFont(ofSize: 14, weight: fontWeight)
            ]
            output.append(NSAttributedString(string: current, attributes: attrs))
            current.removeAll(keepingCapacity: true)
        }
        
        while index < source.endIndex {
            let char = source[index]
            if char == "\u{1B}" {
                let next = source.index(after: index)
                if next < source.endIndex, source[next] == "[" {
                    flush()
                    var cursor = source.index(after: next)
                    var code = ""
                    while cursor < source.endIndex {
                        let c = source[cursor]
                        if c == "m" {
                            applySGR(code, fg: &fg, bg: &bg, bold: &bold)
                            index = source.index(after: cursor)
                            break
                        }
                        if c.isLetter {
                            index = source.index(after: cursor)
                            break
                        }
                        code.append(c)
                        cursor = source.index(after: cursor)
                    }
                    if cursor >= source.endIndex {
                        index = source.endIndex
                    }
                    continue
                }
            }
            current.append(char)
            index = source.index(after: index)
        }
        
        flush()
        return output
    }
    
    private func applySGR(_ payload: String, fg: inout NSColor, bg: inout NSColor, bold: inout Bool) {
        let values = payload.split(separator: ";").compactMap { Int($0) }
        if values.isEmpty {
            fg = theme.defaultForegroundNSColor
            bg = theme.defaultBackgroundNSColor
            bold = false
            return
        }
        
        var i = 0
        while i < values.count {
            let value = values[i]
            switch value {
            case 0:
                fg = theme.defaultForegroundNSColor
                bg = theme.defaultBackgroundNSColor
                bold = false
            case 1:
                bold = true
            case 22:
                bold = false
            case 30...37:
                fg = ansiColor(for: value - 30, bright: false)
            case 90...97:
                fg = ansiColor(for: value - 90, bright: true)
            case 39:
                fg = theme.defaultForegroundNSColor
            case 40...47:
                bg = ansiColor(for: value - 40, bright: false)
            case 100...107:
                bg = ansiColor(for: value - 100, bright: true)
            case 49:
                bg = theme.defaultBackgroundNSColor
            case 38:
                if i + 1 < values.count {
                    let mode = values[i + 1]
                    if mode == 5, i + 2 < values.count {
                        fg = ansi256Color(values[i + 2])
                        i += 2
                    } else if mode == 2, i + 4 < values.count {
                        let r = values[i + 2]
                        let g = values[i + 3]
                        let b = values[i + 4]
                        fg = rgbColor(r: r, g: g, b: b)
                        i += 4
                    }
                }
            case 48:
                if i + 1 < values.count {
                    let mode = values[i + 1]
                    if mode == 5, i + 2 < values.count {
                        bg = ansi256Color(values[i + 2])
                        i += 2
                    } else if mode == 2, i + 4 < values.count {
                        let r = values[i + 2]
                        let g = values[i + 3]
                        let b = values[i + 4]
                        bg = rgbColor(r: r, g: g, b: b)
                        i += 4
                    }
                }
            default:
                break
            }
            i += 1
        }
    }
    
    private func ansiColor(for index: Int, bright: Bool) -> NSColor {
        theme.ansiColor(index: index, bright: bright)
    }
    
    private func ansi256Color(_ value: Int) -> NSColor {
        let code = max(0, min(255, value))
        if code < 8 {
            return ansiColor(for: code, bright: false)
        }
        if code < 16 {
            return ansiColor(for: code - 8, bright: true)
        }
        if code >= 232 {
            let level = CGFloat(code - 232) / 23.0
            let v = 0.08 + (0.84 * level)
            return NSColor(calibratedRed: v, green: v, blue: v, alpha: 1.0)
        }
        
        let idx = code - 16
        let r = idx / 36
        let g = (idx % 36) / 6
        let b = idx % 6
        
        func map(_ n: Int) -> CGFloat {
            if n == 0 { return 0.0 }
            return CGFloat(55 + n * 40) / 255.0
        }
        
        return NSColor(calibratedRed: map(r), green: map(g), blue: map(b), alpha: 1.0)
    }
    
    private func rgbColor(r: Int, g: Int, b: Int) -> NSColor {
        NSColor(
            calibratedRed: CGFloat(max(0, min(255, r))) / 255.0,
            green: CGFloat(max(0, min(255, g))) / 255.0,
            blue: CGFloat(max(0, min(255, b))) / 255.0,
            alpha: 1.0
        )
    }
    
    private func applyTheme(_ theme: TerminalTheme, to scrollView: NSScrollView, textView: CustomTerminalTextView) {
        scrollView.backgroundColor = theme.defaultBackgroundNSColor
        textView.backgroundColor = theme.defaultBackgroundNSColor
        textView.textColor = theme.defaultForegroundNSColor
        textView.insertionPointColor = theme.cursorNSColor
        textView.selectedTextAttributes = [.backgroundColor: theme.selectionNSColor]
        textView.typingAttributes = terminalTypingAttributes(for: theme)
    }
    
    private func terminalTypingAttributes(for theme: TerminalTheme) -> [NSAttributedString.Key: Any] {
        [
            .foregroundColor: theme.defaultForegroundNSColor,
            .backgroundColor: theme.defaultBackgroundNSColor,
            .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        ]
    }
}

class CustomTerminalTextView: NSTextView {
    var onInput: ((String) -> Void)?
    var renderedSource = ""
    var appliedThemeID = TerminalTheme.defaultTheme.id
    
    override var acceptsFirstResponder: Bool { true }
    
    override func insertText(_ string: Any, replacementRange: NSRange) {
        // Do nothing here to prevent double-input. All characters are captured in keyDown.
    }
    
    override func insertTab(_ sender: Any?) {}
    override func insertNewline(_ sender: Any?) {}
    override func insertBacktab(_ sender: Any?) {}
    
    override func shouldChangeText(in affectedCharRange: NSRange, replacementString: String?) -> Bool {
        return false
    }
    
    override func keyDown(with event: NSEvent) {
        let keyCode = event.keyCode
        
        // 1. Handle functional keys by their keycodes (most reliable)
        switch keyCode {
        case 36: // Return
            onInput?("\r")
            return
        case 48: // Tab
            onInput?("\t")
            return
        case 51: // Delete
            onInput?("\u{7F}")
            return
        case 123: // Left
            onInput?("\u{1B}[D")
            return
        case 124: // Right
            onInput?("\u{1B}[C")
            return
        case 125: // Down
            onInput?("\u{1B}[B")
            return
        case 126: // Up
            onInput?("\u{1B}[A")
            return
        default:
            break
        }
        
        // 2. Handle alphanumeric and control combinations
        if let chars = event.charactersIgnoringModifiers, !chars.isEmpty {
            if event.modifierFlags.contains(.control) {
                if let first = chars.utf16.first, first >= 97 && first <= 122 {
                    if let scalar = UnicodeScalar(first - 96) {
                        onInput?(String(scalar))
                        return
                    }
                }
            }
            
            if !event.modifierFlags.contains(.command) && !event.modifierFlags.contains(.control) {
                onInput?(chars)
            }
        }
    }
    
    // We want to force the cursor to visually look like it's at the end
    override func setSelectedRange(_ charRange: NSRange, affinity: NSSelectionAffinity, stillSelecting flag: Bool) {
        super.setSelectedRange(charRange, affinity: affinity, stillSelecting: flag)
    }
}

// © 2026 Stuart Thomas (stuart.thomas@mac.com)
// Licensed under MIT License
// Copyright, Designs and Patents Act 1988

import SwiftUI
import Cocoa

struct PlainTextView: NSViewRepresentable {
    @Binding var text: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollablePlainDocumentContentTextView()
        
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        
        // Critical for "Windows Notepad" functionality - Strips all paste formatting!
        textView.isRichText = false
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        textView.textColor = NSColor.textColor
        
        // Disable smart formatting that feels un-notepad-like
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        
        // Minimal insets
        textView.textContainerInset = NSSize(width: 10, height: 10)
        
        textView.delegate = context.coordinator
        textView.string = text
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView, textView.string != text else {
            return
        }
        textView.string = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: PlainTextView
        
        init(_ parent: PlainTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            // Dispatch to main loop to avoid state update cycles in SwiftUI
            DispatchQueue.main.async {
                self.parent.text = textView.string
            }
        }
    }
}

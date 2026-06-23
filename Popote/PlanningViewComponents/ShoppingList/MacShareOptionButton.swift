import SwiftUI
import AppKit

struct MacShareOptionButton: NSViewRepresentable {
    
    @Environment(AppSettings.self) private var appSettings
    
    let title: String
    let systemImage: String
    let action: (NSButton) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.cornerRadius = 14
        container.layer?.backgroundColor = NSColor(appSettings.mainColor)
            .withAlphaComponent(0.12)
            .cgColor
        
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = NSImageView()
        imageView.image = configuredImage(named: systemImage)
        imageView.symbolConfiguration = NSImage.SymbolConfiguration(
            pointSize: 23,
            weight: .regular
        )
        imageView.contentTintColor = .secondaryLabelColor
        imageView.imageScaling = .scaleProportionallyDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabelColor
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let button = NSButton(
            title: "",
            target: context.coordinator,
            action: #selector(Coordinator.performAction(_:))
        )
        button.isBordered = false
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor.clear.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        context.coordinator.button = button
        
        container.addSubview(imageView)
        container.addSubview(label)
        container.addSubview(button)
        
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 72),
            container.heightAnchor.constraint(equalToConstant: 72),
            
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 26),
            
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6),
            
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.layer?.backgroundColor = NSColor(appSettings.mainColor)
            .withAlphaComponent(0.12)
            .cgColor
        
        context.coordinator.action = action
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    private func configuredImage(named name: String) -> NSImage? {
        let configuration = NSImage.SymbolConfiguration(
            pointSize: 23,
            weight: .regular
        )
        
        return NSImage(
            systemSymbolName: name,
            accessibilityDescription: nil
        )?
        .withSymbolConfiguration(configuration)
    }
    
    final class Coordinator: NSObject {
        var action: (NSButton) -> Void
        weak var button: NSButton?
        
        init(action: @escaping (NSButton) -> Void) {
            self.action = action
        }
        
        @objc func performAction(_ sender: NSButton) {
            action(sender)
        }
    }
}

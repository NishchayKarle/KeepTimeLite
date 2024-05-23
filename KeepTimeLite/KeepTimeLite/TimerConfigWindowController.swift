//
//  TimerConfigWindowController.swift
//  KeepTimeLite
//
//  Created by Nishchay Karle on 5/23/24.
//

import Cocoa

class TimerConfigWindowController: NSWindowController, NSWindowDelegate {
    var titleTextField: NSTextField!
    var valueTextField: NSTextField!
    var valueStepper: NSStepper!
    var countUpPopUp: NSPopUpButton!
    var colorPopUp: NSPopUpButton!
    var completionHandler: ((String, Int, Bool, NSColor) -> Void)?

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 270),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.isMovableByWindowBackground = true
        self.init(window: window)
        self.window?.title = "New Timer Configuration"
        self.window?.delegate = self
        setupUI()
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        if let window = window {
            window.delegate = self
        } else {
            // print("Window is not loaded.")
        }
    }

//    func windowWillClose(_ notification: Notification) {
//        if let appDelegate = NSApp.delegate as? AppDelegate {
//            appDelegate.closeConfigWindow()
//        }
//    }

    func setupUI() {
        guard let contentView = window?.contentView else { return }

        // Label for Title
        let titleLabel = createLabel(with: "Title:")
        titleLabel.frame = NSRect(x: 20, y: 190, width: 120, height: 20)
        contentView.addSubview(titleLabel)

        // Title TextField
        titleTextField = createTextField(placeholder: "Enter title", frame: NSRect(x: 150, y: 190, width: 180, height: 20))
        contentView.addSubview(titleTextField)

        // Label for Initial Value
        let valueLabel = createLabel(with: "Start Time From:")
        valueLabel.frame = NSRect(x: 20, y: 150, width: 120, height: 20)
        contentView.addSubview(valueLabel)

        // Value TextField and Stepper
        valueTextField = createTextField(placeholder: "0", frame: NSRect(x: 150, y: 150, width: 50, height: 20))
        contentView.addSubview(valueTextField)

        valueStepper = NSStepper(frame: NSRect(x: 210, y: 150, width: 20, height: 20))
        valueStepper.minValue = 0
        valueStepper.maxValue = Double(Int.max)
        valueStepper.increment = 1
        valueStepper.valueWraps = false
        valueStepper.autorepeat = true
        valueStepper.target = self
        valueStepper.action = #selector(stepperValueChanged(_:))
        contentView.addSubview(valueStepper)

        // Label for Count Up
        let countUpLabel = createLabel(with: "Count Up:")
        countUpLabel.frame = NSRect(x: 20, y: 110, width: 120, height: 20)
        contentView.addSubview(countUpLabel)

        // Count Up Pop-Up Button
        countUpPopUp = NSPopUpButton(frame: NSRect(x: 150, y: 110, width: 100, height: 20), pullsDown: false)
        countUpPopUp.addItems(withTitles: ["Yes", "No"])
        contentView.addSubview(countUpPopUp)

        // Label for Color Selection
        let colorLabel = createLabel(with: "Color:")
        colorLabel.frame = NSRect(x: 20, y: 70, width: 120, height: 20)
        contentView.addSubview(colorLabel)

        // Color Selection Pop-Up Button
        colorPopUp = NSPopUpButton(frame: NSRect(x: 150, y: 70, width: 100, height: 20), pullsDown: false)
        colorPopUp.addItems(withTitles: AppColors.colorNames)
        contentView.addSubview(colorPopUp)

        // Submit Button (Add)
        let submitButton = NSButton(title: "Add", target: self, action: #selector(submitAction))
        submitButton.frame = NSRect(x: 125, y: 20, width: 100, height: 30)
        submitButton.bezelStyle = .rounded
        submitButton.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        contentView.addSubview(submitButton)
    }

    private func createLabel(with text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.font = NSFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }

    private func createTextField(placeholder: String, frame: NSRect) -> NSTextField {
        let textField = NSTextField(frame: frame)
        textField.placeholderString = placeholder
        textField.font = NSFont.systemFont(ofSize: 14)
        textField.isBezeled = true
        textField.bezelStyle = .roundedBezel
        return textField
    }

    @objc private func submitAction() {
        let title = titleTextField.stringValue.isEmpty ? "New Timer" : titleTextField.stringValue
        let value = Int(valueTextField.stringValue) ?? 0
        let countUp = countUpPopUp.indexOfSelectedItem == 0  // Yes = 0, No = 1
        let colorKey = AppColors.colorNames[colorPopUp.indexOfSelectedItem]
        let color = AppColors.colors[colorKey] ?? .black // Default to black if color is not found

        completionHandler?(title, value, countUp, color)
        self.window?.close()
    }

    @objc private func stepperValueChanged(_ sender: NSStepper) {
        valueTextField.stringValue = String(sender.integerValue)
    }
}

import UIKit

@IBDesignable
class SentryButton: UIButton {

    // MARK: - Inspectables
    @IBInspectable var normalColor: UIColor = UIColor(red: 54/255, green: 45/255, blue: 89/255, alpha: 1) { // #362D59
        didSet { applyAppearance() }
    }
    @IBInspectable var pressedColor: UIColor = UIColor(red: 86/255, green: 46/255, blue: 125/255, alpha: 1) { // #562E7D
        didSet { applyAppearance() }
    }
    @IBInspectable var cornerRadius: CGFloat = 4 { didSet { layer.cornerRadius = cornerRadius } }
    @IBInspectable var borderWidth: CGFloat = 1 { didSet { layer.borderWidth = borderWidth } }
    @IBInspectable var borderColor: UIColor = UIColor.black.withAlphaComponent(0.2) { // ~ #33000000
        didSet { layer.borderColor = borderColor.cgColor }
    }
    @IBInspectable var applyPressedToSelected: Bool = false { didSet { applyAppearance() } }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }

    private func commonInit() {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        applyAppearance()
    }

    // MARK: - Appearance
    private func applyAppearance() {
        if #available(iOS 15.0, *) {
            // Use modern configuration; ensures Storyboard + runtime show correct background.
            // IMPORTANT: If Storyboard assigned a default configuration (system type), we control it here.
            var config = self.configuration ?? .filled()
            config.baseForegroundColor = .white
            self.configuration = config

            configurationUpdateHandler = { [weak self] btn in
                guard let self = self else { return }
                let isDown = btn.isHighlighted || btn.isFocused || (self.applyPressedToSelected && btn.isSelected)
                btn.configuration?.background.backgroundColor = isDown ? self.pressedColor : self.normalColor
            }
            setNeedsUpdateConfiguration()
        } else {
            // Legacy fallback (iOS 14 and earlier): use background images.
            setBackgroundImage(image(from: normalColor), for: .normal)
            setBackgroundImage(image(from: pressedColor), for: .highlighted)
            setBackgroundImage(image(from: applyPressedToSelected ? pressedColor : normalColor), for: .selected)
            // tvOS/iPad focus (harmless on iOS < 15)
            setBackgroundImage(image(from: pressedColor), for: .focused)
        }
    }

    private func image(from color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill(); UIRectFill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
    }
}

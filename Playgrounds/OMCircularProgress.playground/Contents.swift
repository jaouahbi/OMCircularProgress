//: Playground - noun: a place where people can play

import UIKit

import UIKit
import PlaygroundSupport
// https://gist.github.com/erica/6f13f3043a330359c035e7660f3fe7f5
// String to animate and its attributes
var string = "Hello, playground"
let attributes: [String: Any] = [
    NSForegroundColorAttributeName: UIColor.black,
    NSFontAttributeName: UIFont.boldSystemFont(ofSize: 32)]
let storage = NSTextStorage(string: string, attributes: attributes)
let fullSize = storage.size()

// Build a view to animate over
let heightCount: CGFloat = 15
var horizontalOffset: CGFloat = 50
let viewSize = CGSize(
    width: fullSize.width + 2 * horizontalOffset, // 50 point padding
    height: fullSize.height * heightCount) // string height * count = view height
let view = UIView(frame: CGRect(origin:.zero, size: viewSize))
view.backgroundColor = UIColor.white
let destinationY = fullSize.height * (heightCount - 1) / 2

// Layout manager provides glyph geometry
let layoutManager = NSLayoutManager()
layoutManager.addTextContainer(NSTextContainer(size: CGRect.infinite.size))
layoutManager.textStorage = storage
let glyphCount = Int(layoutManager.numberOfGlyphs)
// Fetch individual attributed characters
let attributedCharacters = (0 ..< glyphCount)
    .map({ storage.attributedSubstring(from: NSMakeRange($0, 1)) })

// Pretty colors within 25% - 75% brightness
func randomColor() -> UIColor {
    func random() -> CGFloat { return 0.25 + 0.5 * CGFloat(arc4random()) / CGFloat(UInt32.max) }
    return UIColor(red: random(), green: random(), blue: random(), alpha: 1)
}

// Animate each character into place
let format = UIGraphicsImageRendererFormat()
attributedCharacters.enumerated().forEach({ (idx, char) in
    let colorChar: NSMutableAttributedString = char.mutableCopy() as! NSMutableAttributedString
    colorChar.addAttribute(NSForegroundColorAttributeName, value: randomColor(), range: NSMakeRange(0, 1))
    let chSize = char.size(); defer { horizontalOffset += chSize.width }
    
    // Create an character image
    let renderer = UIGraphicsImageRenderer(size: chSize, format: format)
    let characterImage = renderer.image { context in colorChar.draw(at: .zero) }
    
    // Animation from p1 to p2
    let p1 = CGPoint(x: horizontalOffset, y: viewSize.height + 100)
    let p2 = CGPoint(x: horizontalOffset, y: destinationY)
    let destination = CGRect(origin: p2, size: chSize)
    
    // Construct UIImageView
    let characterView = UIImageView(frame: CGRect(origin: p1, size: chSize))
    characterView.image = characterImage; characterView.alpha = 0.0
    view.addSubview(characterView)
    
    // Animate, with an 0.1 sec delay between each, increase
    // this to slow down the animation
    UIView.animate(withDuration: 1.5, // time for full letter transit
        delay: Double(idx) * 0.1, // letter to letter delay
        usingSpringWithDamping: 0.6, // slowing down
        initialSpringVelocity: 0.5, // initial speed
        options: [],
        animations: { characterView.frame = destination; characterView.alpha = 1.0 },
        completion: nil)
})

PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

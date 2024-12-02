//
//  ViewController.swift
//  RenderingTutorial
//
//  Copyright (c) 2024 Jeremy All rights reserved.


import UIKit

final class RenderingViewController: UIViewController {
    
    // MARK: Property(s)
    
    private var panGesture: UIPanGestureRecognizer = .init()
    private var lastFrameTime = CACurrentMediaTime()
    private var world: World = World(map: TileMap.defaultMap)
    private lazy var renderer = Renderer3D(width: 200, height: 200)
    
    private let joystickRadius: Double = 40
    
    private let trailingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isOpaque = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.magnificationFilter = .nearest
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.label.cgColor
        return imageView
    }()
    
    private let mapImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.isOpaque = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.magnificationFilter = .nearest
        imageView.layer.borderColor = UIColor.label.cgColor
        imageView.layer.borderWidth = 1.0
        return imageView
    }()
    
    private let halfLeadingStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.layer.borderColor = UIColor.label.cgColor
        stack.layer.borderWidth = 1.0
        return stack
    }()
    
    private let controlStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 5
        return stack
    }()
    
    private let infoStack: UIStackView = UIStackView()
    private let labelStack: UIStackView = UIStackView()
    private let focalControl: UISlider = .init()
    private let focalDisplayLabel: UILabel = .init()
    private let viewWidthControl: UISlider = .init()
    private let viewWidthDisplayLabel: UILabel = .init()
    
    private let buttonStack: UIStackView = {
       let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.spacing = 0.5
        return stack
    }()
    
    private let controlResetButton: UIButton = {
        let button = UIButton(configuration: .tinted())
        button.tintColor = .red
        button.setTitle("reset", for: .normal)
        return button
        
    }()
    
    // MARK: Override(s)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controlResetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        configureLayoutConstraints()
        setupDisplayLink()
        setupPanGesture()
    }
}

// MARK: Rendering

extension RenderingViewController {
    
    @objc private func update(_ displayLink: CADisplayLink) {
        let timestep = displayLink.timestamp - lastFrameTime
        self.lastFrameTime = displayLink.timestamp
        let input = Input(velocity: inputVector)
        world.update(timestep, input)
        updateControlPanel()
        renderer.draw(world, focalLength: Double(focalControl.value), viewWidth: Double(viewWidthControl.value))
        var mapRenderer = Renderer(width: 100, height: 100)
        mapRenderer.draw(world, focalLength: Double(focalControl.value), viewWidth: Double(viewWidthControl.value))
        mapImageView.image = UIImage(bitmap: mapRenderer.bitmap)
        trailingImageView.image = UIImage(bitmap: renderer.bitmap)
    }
    
    @objc private func didTapResetButton() {
        focalControl.value = 1.0
        viewWidthControl.value = 1.0
    }
    
    private func setupDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .main, forMode: .common)
    }
    
    private func updateControlPanel() {
        focalDisplayLabel.text = "focal length: \(focalControl.value)"
        viewWidthDisplayLabel.text = "view width: \(viewWidthControl.value)"
    }
}

// MARK: User PanGesture Input

extension RenderingViewController {
    private var inputVector: Vector {
        switch panGesture.state {
        case .began, .changed:
            let translation = panGesture.translation(in: trailingImageView)
            let vector = Vector(x: translation.x, y: translation.y)
            let result = vector / max(joystickRadius, vector.length)
            panGesture.setTranslation(
                CGPoint(x: result.x * joystickRadius, y: result.y * joystickRadius),
                in: trailingImageView
            )
            return result
        default:
            return Vector(x: .zero, y: .zero)
        }
    }
}

// MARK: View Settings

extension RenderingViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    private func setupPanGesture() {
        view.addGestureRecognizer(panGesture)
    }
    
    private func configureLayoutConstraints() {
        view.addSubview(halfLeadingStack)
        view.addSubview(trailingImageView)
        
        
        let inset: CGFloat = 10
        
        halfLeadingStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            halfLeadingStack.topAnchor.constraint(equalTo: view.topAnchor, constant: inset),
            halfLeadingStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: inset),
            halfLeadingStack.trailingAnchor.constraint(equalTo: trailingImageView.leadingAnchor, constant: -inset),
            halfLeadingStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset),
            halfLeadingStack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5)
        ])
        
        trailingImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trailingImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: inset),
            trailingImageView.leadingAnchor.constraint(equalTo: halfLeadingStack.trailingAnchor, constant: inset),
            trailingImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: inset),
            trailingImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset),
            trailingImageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5)
        ])
        
        halfLeadingStack.addArrangedSubview(infoStack)
        infoStack.layoutMargins = .init(top: 50, left: 0, bottom: 50, right: 0)
        infoStack.isLayoutMarginsRelativeArrangement = true
        halfLeadingStack.addArrangedSubview(controlStack)
        controlStack.layoutMargins = .init(top: 50, left: 0, bottom: 50, right: 0)
        controlStack.isLayoutMarginsRelativeArrangement = true
        controlStack.addArrangedSubview(focalControl)
        controlStack.addArrangedSubview(viewWidthControl)
        
        NSLayoutConstraint.activate([
            controlStack.heightAnchor.constraint(equalTo: halfLeadingStack.heightAnchor, multiplier: 0.5)
        ])
        
        infoStack.isLayoutMarginsRelativeArrangement = true
        infoStack.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        infoStack.distribution = .fill
        infoStack.alignment = .fill
        infoStack.axis = .vertical
        infoStack.addArrangedSubview(focalDisplayLabel)
        infoStack.addArrangedSubview(viewWidthDisplayLabel)
        
        halfLeadingStack.distribution = .fill
        halfLeadingStack.alignment = .fill
        halfLeadingStack.spacing = 5
        
        controlStack.distribution = .equalSpacing
        
        infoStack.distribution = .fill
        infoStack.alignment = .fill
        
        focalControl.value = 1.0
        focalControl.minimumValue = 0.01
        focalControl.maximumValue = 5
        
        focalControl.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        viewWidthControl.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        
        viewWidthControl.value = 1.0
        viewWidthControl.minimumValue = 0.01
        viewWidthControl.maximumValue = 5
    }
}



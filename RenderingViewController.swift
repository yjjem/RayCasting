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
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.isOpaque = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.magnificationFilter = .nearest
        return imageView
    }()
    
    private let mapImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.isOpaque = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.magnificationFilter = .nearest
        return imageView
    }()
    
    // MARK: Half Leading Stack
    
    private let halfLeadingStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 10, left: 0, bottom: 10, right: 0)
        stack.spacing = 10
        return stack
    }()
    
    // MARK: Control Panel
    
    private let controlStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        return stack
    }()
    
    private let focalControl: UISlider = .init()
    private let focalDisplayLabel: UILabel = .init()
    
    private let viewWidthControl: UISlider = .init()
    private let viewWidthDisplayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 8, weight: .bold)
        return label
    }()
    
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
        button.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        return button
        
    }()
    
    // MARK: Override(s)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
        setupDisplayLink()
        setupPanGesture()
    }
}

// MARK: Render Update

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
        imageView.image = UIImage(bitmap: renderer.bitmap)
    }
}

// MARK: User Input

extension RenderingViewController {
    var inputVector: Vector {
        switch panGesture.state {
        case .began, .changed:
            let translation = panGesture.translation(in: imageView)
            let vector = Vector(x: translation.x, y: translation.y)
            let result = vector / max(joystickRadius, vector.length)
            panGesture.setTranslation(
                CGPoint(x: result.x * joystickRadius, y: result.y * joystickRadius),
                in: imageView
            )
            return result
        default:
            return Vector(x: .zero, y: .zero)
        }
    }
}

// MARK: Configuration

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
    
    private func setupDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .main, forMode: .common)
    }
    
    private func setupPanGesture() {
        self.view.addGestureRecognizer(panGesture)
    }
    
    private func configureImageView() {
        view.addSubview(halfLeadingStack)
        halfLeadingStack.translatesAutoresizingMaskIntoConstraints = false
        halfLeadingStack.addArrangedSubview(mapImageView)
        halfLeadingStack.addArrangedSubview(controlStack)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        mapImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            halfLeadingStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            halfLeadingStack.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -10),
            halfLeadingStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            halfLeadingStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            halfLeadingStack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            
//            imageView.leadingAnchor.constraint(equalTo: halfLeadingStack.trailingAnchor, constant: -10),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            
            mapImageView.heightAnchor.constraint(equalTo: halfLeadingStack.heightAnchor, multiplier: 0.5),
        ])
        
        controlStack.addArrangedSubview(mapImageView)
        controlStack.addArrangedSubview(viewWidthDisplayLabel)
        controlStack.addArrangedSubview(viewWidthControl)
        controlStack.addArrangedSubview(buttonStack)
        buttonStack.addArrangedSubview(controlResetButton)
        
        focalControl.value = 1.0
        focalControl.minimumValue = 0.01
        focalControl.maximumValue = 5
        controlStack.addArrangedSubview(focalDisplayLabel)
        controlStack.addArrangedSubview(focalControl)
        
        focalControl.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        viewWidthControl.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        
        viewWidthControl.value = 1.0
        viewWidthControl.minimumValue = 0.01
        viewWidthControl.maximumValue = 5
    }
    
    @objc private func didTapResetButton() {
        focalControl.value = 1.0
        viewWidthControl.value = 1.0
    }
    
    private func updateControlPanel() {
        focalDisplayLabel.text = "focal length: \(focalControl.value.formatted())"
        viewWidthDisplayLabel.text = "view width: \(viewWidthControl.value.formatted())"
    }
}

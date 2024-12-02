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
    
    private let controlStack: UIStackView = UIStackView()
    private let infoStack: UIStackView = UIStackView()
    private let labelStack: UIStackView = UIStackView()
    private let focalControl: UISlider = .init()
    private let focalDisplayLabel: UILabel = .init()
    private let viewWidthControl: UISlider = .init()
    private let viewWidthDisplayLabel: UILabel = .init()
    
    private let controlResetButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.tintColor = .red
        button.setTitle("reset", for: .normal)
        return button
        
    }()
    
    // MARK: Override(s)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureViewConstraints()
        configureViewSettings()
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
    
    private func configureViewHierarchy() {
        view.addSubview(controlStack)
        view.addSubview(trailingImageView)
        view.addSubview(infoStack)
        view.addSubview(mapImageView)
        
        controlStack.addArrangedSubview(focalControl)
        controlStack.addArrangedSubview(viewWidthControl)
        controlStack.addArrangedSubview(controlResetButton)
        
        
        let flImage = "FL".image(withAttributes: [.font: UIFont.systemFont(ofSize: 20), .backgroundColor: UIColor.lightGray])
        let vWImage = "VW".image(withAttributes: [.font: UIFont.systemFont(ofSize: 20), .backgroundColor: UIColor.lightGray])
        focalControl.setThumbImage(flImage, for: .normal)
        viewWidthControl.setThumbImage(vWImage, for: .normal)
        
        
        infoStack.addArrangedSubview(focalDisplayLabel)
        infoStack.addArrangedSubview(viewWidthDisplayLabel)
    }
    
    private func configureViewConstraints() {
        
        controlStack.alignment = .bottom
        controlStack.axis = .vertical
        controlStack.spacing = 8
        controlStack.layoutMargins = .init(top: 10, left: 0, bottom: 10, right: 10)
        controlStack.isLayoutMarginsRelativeArrangement = true
        controlStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlStack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            controlStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            controlStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(view.bounds.height * 0.5)),
            controlStack.trailingAnchor.constraint(equalTo: trailingImageView.leadingAnchor, constant: -20),
            controlStack.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height * 0.5)
        ])
        
        trailingImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trailingImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, constant: -10),
            trailingImageView.widthAnchor.constraint(equalTo: trailingImageView.heightAnchor),
            trailingImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            trailingImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            trailingImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        infoStack.spacing = 8
        infoStack.axis = .vertical
        infoStack.alignment = .fill
        
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoStack.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            infoStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height * 0.5),
            infoStack.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
            infoStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        ])
        
        mapImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45),
            mapImageView.widthAnchor.constraint(equalTo: mapImageView.heightAnchor),
            mapImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapImageView.trailingAnchor.constraint(equalTo: trailingImageView.leadingAnchor, constant: -20),
            mapImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height * 0.5)
        ])
        
        NSLayoutConstraint.activate([
            focalControl.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.45),
            focalControl.heightAnchor.constraint(equalToConstant: 30),
            viewWidthControl.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.45),
            viewWidthControl.heightAnchor.constraint(equalToConstant: 30),
            controlResetButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func configureViewSettings() {
        controlResetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        focalControl.minimumValue = 0.1
        focalControl.maximumValue = 2.0
        focalControl.value = 1.0
        viewWidthControl.minimumValue = 0.1
        viewWidthControl.maximumValue = 2.0
        viewWidthControl.value = 1.0
    }
}




extension String {
    func image(
        withAttributes attributes: [NSAttributedString.Key: Any]? = nil,
        size: CGSize? = nil
    ) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(
                in: CGRect(origin: .zero, size: size),
                withAttributes: attributes
            )
        }
    }
    
}

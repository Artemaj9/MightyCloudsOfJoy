import UIKit
//
//class ViewController: UIViewController {
//
//    let collectionView: UICollectionView
//    let weatherIcons = ["sun", "rain", "snow", "lightning", "mist", "wind"]
//    let weatherColors: [UIColor] = [.yellow, .blue, .white, .gray, .orange, .cyan]
//    var weatherViews: [UIView] = []
//    var currentWeatherIndex: Int = 0
//
//    init() {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        
//        super.init(nibName: nil, bundle: nil)
//        
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.register(WeatherCell.self, forCellWithReuseIdentifier: "WeatherCell")
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Set transparent background for collection view
//        collectionView.backgroundColor = .clear
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.showsVerticalScrollIndicator = false
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.addSubview(collectionView)
//        
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.heightAnchor.constraint(equalToConstant: 100)
//        ])
//        
//        setupWeatherViews()
//        
//        // Wait for the layout to be set up before scrolling
//        DispatchQueue.main.async {
//            let randomIndex = Int(arc4random_uniform(UInt32(self.weatherIcons.count)))
//            self.currentWeatherIndex = randomIndex
//            self.displayWeather(at: self.currentWeatherIndex)
//            self.scrollToCenter(at: self.currentWeatherIndex)
//            self.selectItem(at: self.currentWeatherIndex)
//        }
//        
//        setupSwipeGestures()
//    }
//
//    func setupWeatherViews() {
//        let effects = ["snowShader", "rainShader", "sunShader", "snowShader", "rainShader", "sunShader"]
//        
//        for effect in effects {
//            let metalView = WeatherMetalView(effect: effect, frame: view.bounds)
//            metalView.isHidden = true
//            metalView.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(metalView)
//            weatherViews.append(metalView)
//        }
//    }
////    func setupWeatherViews() {
////        for color in weatherColors {
////            let weatherView = UIView()
////            weatherView.backgroundColor = color
////            weatherView.frame = view.bounds
////            weatherView.isHidden = true
////            weatherView.translatesAutoresizingMaskIntoConstraints = false
////            view.addSubview(weatherView)
////            weatherViews.append(weatherView)
////        }
////    }
//
//    func displayWeather(at index: Int) {
//        weatherViews.forEach { $0.isHidden = true }
//        let selectedView = weatherViews[index]
//        selectedView.isHidden = false
//        
//        UIView.transition(with: view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
//            self.view.sendSubviewToBack(selectedView)
//        }, completion: nil)
//    }
//    
//    func scrollToCenter(at index: Int) {
//        let indexPath = IndexPath(item: index, section: 0)
//        // Ensure layout is updated before scrolling
//        collectionView.layoutIfNeeded()
//        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
//    }
//    
//    func setupSwipeGestures() {
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        swipeLeft.direction = .left
//        view.addGestureRecognizer(swipeLeft)
//        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        swipeRight.direction = .right
//        view.addGestureRecognizer(swipeRight)
//    }
//    
//    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
//        if gesture.direction == .left {
//            currentWeatherIndex = (currentWeatherIndex + 1) % weatherViews.count
//        } else if gesture.direction == .right {
//            currentWeatherIndex = (currentWeatherIndex - 1 + weatherViews.count) % weatherViews.count
//        }
//        displayWeather(at: currentWeatherIndex)
//        selectItem(at: currentWeatherIndex)
//        scrollToCenter(at: currentWeatherIndex)
//    }
//    
//    func selectItem(at index: Int) {
//        let indexPath = IndexPath(item: index, section: 0)
//        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
//    }
//}
//
//extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return weatherIcons.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as! WeatherCell
//        cell.imageView.image = UIImage(named: weatherIcons[indexPath.row])
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        currentWeatherIndex = indexPath.row
//        displayWeather(at: indexPath.row)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 100, height: 100)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//}

//
//import UIKit
//import MetalKit
//
//class ViewController: UIViewController {
//
//    let collectionView: UICollectionView
//    let weatherIcons = ["sun", "rain", "snow", "lightning", "mist", "wind"]
//    var currentWeatherIndex: Int = 0
//
//    var metalView: MTKView!
//    var device: MTLDevice!
//    var commandQueue: MTLCommandQueue!
//    var pipelineState: MTLRenderPipelineState!
//
//    init() {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        
//        super.init(nibName: nil, bundle: nil)
//        
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.register(WeatherCell.self, forCellWithReuseIdentifier: "WeatherCell")
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        
//        collectionView.backgroundColor = .clear
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.showsVerticalScrollIndicator = false
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupMetal()
//        
//        view.addSubview(metalView)
//        view.addSubview(collectionView)
//
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.heightAnchor.constraint(equalToConstant: 100),
//            metalView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
//            metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            metalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            metalView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//
//        // Set initial weather effect
//        let randomIndex = Int(arc4random_uniform(UInt32(weatherIcons.count)))
//        currentWeatherIndex = randomIndex
//        updateWeatherEffect(for: currentWeatherIndex)
//
//        DispatchQueue.main.async {
//            self.scrollToCenter(at: self.currentWeatherIndex)
//        }
//        
//        setupSwipeGestures()
//    }
//
//    func setupMetal() {
//        device = MTLCreateSystemDefaultDevice()
//        metalView = MTKView(frame: .zero, device: device)
//        metalView.delegate = self
//        metalView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
//        
//        // Load shaders
//        let library = device.makeDefaultLibrary()!
//        let vertexFunction = library.makeFunction(name: "vertex_main")
//        let fragmentFunction = library.makeFunction(name: "fragment_snow") // Default shader
//        
//        let pipelineDescriptor = MTLRenderPipelineDescriptor()
//        pipelineDescriptor.vertexFunction = vertexFunction
//        pipelineDescriptor.fragmentFunction = fragmentFunction
//        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
//        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//        
//        commandQueue = device.makeCommandQueue()
//    }
//
//    func updateWeatherEffect(for index: Int) {
//        let shaderName: String
//        switch index {
//        case 0: shaderName = "fragment_sun"
//        case 1: shaderName = "fragment_rain"
//        case 2: shaderName = "fragment_snow"
//        // Add more cases for other weather effects
//        default: shaderName = "fragment_sun"
//        }
//        
//        let library = device.makeDefaultLibrary()!
//        let fragmentFunction = library.makeFunction(name: shaderName)
//        
//        let pipelineDescriptor = MTLRenderPipelineDescriptor()
//        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
//        pipelineDescriptor.fragmentFunction = fragmentFunction
//        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
//        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//        
//        metalView.setNeedsDisplay()
//    }
//
//    func scrollToCenter(at index: Int) {
//        let indexPath = IndexPath(item: index, section: 0)
//        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
//    }
//
//    func setupSwipeGestures() {
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        swipeLeft.direction = .left
//        view.addGestureRecognizer(swipeLeft)
//        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        swipeRight.direction = .right
//        view.addGestureRecognizer(swipeRight)
//    }
//    
//    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
//        if gesture.direction == .left {
//            currentWeatherIndex = (currentWeatherIndex + 1) % weatherIcons.count
//        } else if gesture.direction == .right {
//            currentWeatherIndex = (currentWeatherIndex - 1 + weatherIcons.count) % weatherIcons.count
//        }
//        updateWeatherEffect(for: currentWeatherIndex)
//        scrollToCenter(at: currentWeatherIndex)
//    }
//}
//
//extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return weatherIcons.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as! WeatherCell
//        cell.imageView.image = UIImage(named: weatherIcons[indexPath.row])
//        cell.backgroundColor = (indexPath.row == currentWeatherIndex) ? .lightGray : .clear
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        currentWeatherIndex = indexPath.row
//        updateWeatherEffect(for: indexPath.row)
//        collectionView.reloadData() // Refresh to update the selection highlight
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 100, height: 100)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//}
//
//extension ViewController: MTKViewDelegate {
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
//
//    func draw(in view: MTKView) {
//        guard let drawable = view.currentDrawable else { return }
//
//        let renderPassDescriptor = view.currentRenderPassDescriptor!
//        let commandBuffer = commandQueue.makeCommandBuffer()!
//        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
//        
//        renderEncoder.setRenderPipelineState(pipelineState)
//        
//        // Define vertices and texture coordinates for a full-screen quad
//        let vertices: [float4] = [
//            float4(-1, -1, 0, 1),
//            float4(1, -1, 0, 1),
//            float4(-1, 1, 0, 1),
//            float4(1, 1, 0, 1)
//        ]
//        let texCoords: [float2] = [
//            float2(0, 0),
//            float2(1, 0),
//            float2(0, 1),
//            float2(1, 1)
//        ]
//        
//        let vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<float4>.size * vertices.count, options: [])
//        let texCoordBuffer = device.makeBuffer(bytes: texCoords, length: MemoryLayout<float2>.size * texCoords.count, options: [])
//        
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        renderEncoder.setVertexBuffer(texCoordBuffer, offset: 0, index: 1)
//        
//        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
//        renderEncoder.endEncoding()
//        
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}
//
//

//class ViewController: UIViewController {
//
//    // Same as before...
//
//    func setupWeatherViews() {
//        let effects = ["snowShader", "rainShader", "sunShader", "snowShader", "rainShader", "sunShader"]
//        
//        for effect in effects {
//            let metalView = WeatherMetalView(effect: effect, frame: view.bounds)
//            metalView.isHidden = true
//            metalView.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(metalView)
//            weatherViews.append(metalView)
//        }
//    }
//
//    // Rest of your ViewController code...
//}
//Finally, replace your existing WeatherCell class with the updated one that uses WeatherMetalView:
//
//swift
//Copy code
//class WeatherCell: UICollectionViewCell {
//    
//    let imageView: UIImageView
//    var metalView: WeatherMetalView?
//    
//    override init(frame: CGRect) {
//        imageView = UIImageView()
//        super.init(frame: frame)
//        
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(imageView)
//        
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//        ])
//        
//        contentView.backgroundColor = .clear
//        contentView.layer.borderColor = UIColor.red.cgColor
//        contentView.layer.borderWidth = 0
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override var isSelected: Bool {
//        didSet {
//            contentView.layer.borderWidth = isSelected ? 2 : 0
//        }
//    }
//}

//class ViewController: UIViewController {
//
//    let collectionView: UICollectionView
//    let weatherIcons = ["sun", "rain", "snow", "lightning", "mist", "wind"]
//    let weatherEffects = ["sunShader", "rainShader", "snowShader", "lightningShader", "mistShader", "windShader"]
//    var weatherViews: [WeatherMetalView] = []
//    var currentWeatherIndex: Int = 0
//
//    init() {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        
//        super.init(nibName: nil, bundle: nil)
//        
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.register(WeatherCell.self, forCellWithReuseIdentifier: "WeatherCell")
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Set transparent background for collection view
//        collectionView.backgroundColor = .clear
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.showsVerticalScrollIndicator = false
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.addSubview(collectionView)
//        
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.heightAnchor.constraint(equalToConstant: 100)
//        ])
//        
//        setupWeatherViews()
//        
//        // Wait for the layout to be set up before scrolling
//        DispatchQueue.main.async {
//            let randomIndex = Int(arc4random_uniform(UInt32(self.weatherIcons.count)))
//            self.currentWeatherIndex = randomIndex
//            self.displayWeather(at: self.currentWeatherIndex)
//            self.scrollToCenter(at: self.currentWeatherIndex)
//            self.selectItem(at: self.currentWeatherIndex)
//        }
//        
//        setupSwipeGestures()
//    }
//
//    func setupWeatherViews() {
//        for effect in weatherEffects {
//            let metalView = WeatherMetalView(effect: effect, frame: view.bounds)
//            metalView.isHidden = true
//            metalView.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(metalView)
//            weatherViews.append(metalView)
//        }
//    }
//
//    func displayWeather(at index: Int) {
//        weatherViews.forEach { $0.isHidden = true }
//        let selectedView = weatherViews[index]
//        selectedView.isHidden = false
//        
//        UIView.transition(with: view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
//            self.view.sendSubviewToBack(selectedView)
//        }, completion: nil)
//    }
//    
//    func scrollToCenter(at index: Int) {
//        let indexPath = IndexPath(item: index, section: 0)
//        // Ensure layout is updated before scrolling
//        collectionView.layoutIfNeeded()
//        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
//    }
//    
//    func setupSwipeGestures() {
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        swipeLeft.direction = .left
//        view.addGestureRecognizer(swipeLeft)
//        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        swipeRight.direction = .right
//        view.addGestureRecognizer(swipeRight)
//    }
//    
//    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
//        if gesture.direction == .left {
//            currentWeatherIndex = (currentWeatherIndex + 1) % weatherViews.count
//        } else if gesture.direction == .right {
//            currentWeatherIndex = (currentWeatherIndex - 1 + weatherViews.count) % weatherViews.count
//        }
//        displayWeather(at: currentWeatherIndex)
//        selectItem(at: currentWeatherIndex)
//        scrollToCenter(at: currentWeatherIndex)
//    }
//    
//    func selectItem(at index: Int) {
//        let indexPath = IndexPath(item: index, section: 0)
//        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
//    }
//}
//
//extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return weatherIcons.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as! WeatherCell
//        cell.imageView.image = UIImage(named: weatherIcons[indexPath.row])
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        currentWeatherIndex = indexPath.row
//        displayWeather(at: indexPath.row)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 100, height: 100)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//}


class ViewController: UIViewController {

    let collectionView: UICollectionView
    let weatherIcons = ["sun", "rain", "snow", "lightning", "mist", "wind"]
    let weatherEffects = ["sunShader", "rainShader", "snowShader", "lightningShader", "cloudShader", "windShader"]
    var weatherViews: [WeatherMetalView] = []
    var currentWeatherIndex: Int = 0

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WeatherCell.self, forCellWithReuseIdentifier: "WeatherCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set transparent background for collection view
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        setupWeatherViews()
        
        // Wait for the layout to be set up before scrolling
        DispatchQueue.main.async {
            let randomIndex = Int(arc4random_uniform(UInt32(self.weatherIcons.count)))
            self.currentWeatherIndex = randomIndex
            self.displayWeather(at: self.currentWeatherIndex)
            self.scrollToCenter(at: self.currentWeatherIndex)
            self.selectItem(at: self.currentWeatherIndex)
        }
        
        setupSwipeGestures()
    }

    func setupWeatherViews() {
        for effect in weatherEffects {
            let metalView = WeatherMetalView(effect: effect, frame: view.bounds)
            metalView.isHidden = true
            metalView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(metalView)
            weatherViews.append(metalView)
        }
    }

    func displayWeather(at index: Int) {
        weatherViews.forEach { $0.isHidden = true }
        let selectedView = weatherViews[index]
        selectedView.isHidden = false
        
        UIView.transition(with: view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            self.view.sendSubviewToBack(selectedView)
        }, completion: nil)
    }
    
    func scrollToCenter(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        // Ensure layout is updated before scrolling
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    
    func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            currentWeatherIndex = (currentWeatherIndex + 1) % weatherViews.count
        } else if gesture.direction == .right {
            currentWeatherIndex = (currentWeatherIndex - 1 + weatherViews.count) % weatherViews.count
        }
        displayWeather(at: currentWeatherIndex)
        selectItem(at: currentWeatherIndex)
        scrollToCenter(at: currentWeatherIndex)
    }
    
    func selectItem(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherIcons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as! WeatherCell
        cell.imageView.image = UIImage(named: weatherIcons[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentWeatherIndex = indexPath.row
        displayWeather(at: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

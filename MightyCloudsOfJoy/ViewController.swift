import UIKit

class ViewController: UIViewController {
    
    private let collectionView: UICollectionView
    private let weatherIcons = ["sun", "rain", "snow", "lightning", "dull", "cloudy"]
    private let weatherEffects = ["sunShader", "rainShader", "snowShader", "lightningShader", "cloudShader", "cloudSunShader"]
    private var weatherViews: [WeatherMetalView] = []
    private var currentWeatherIndex: Int = 0

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WeatherCell.self, forCellWithReuseIdentifier: "WeatherCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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
        setupConstraints()
        setupWeatherViews()
        setupSwipeGestures()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        let randomIndex = Int(arc4random_uniform(UInt32(weatherIcons.count)))
        currentWeatherIndex = randomIndex
        displayWeather(at: currentWeatherIndex)
        scrollToCenter(at: currentWeatherIndex)
        selectItem(at: currentWeatherIndex)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func setupWeatherViews() {
        for effect in weatherEffects {
            let metalView = WeatherMetalView(effect: effect, frame: view.bounds)
            metalView.isHidden = true
            metalView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(metalView)
            weatherViews.append(metalView)
        }
    }

    private func displayWeather(at index: Int) {
        weatherViews.forEach { $0.isHidden = true }
        let selectedView = weatherViews[index]
        selectedView.isHidden = false
        
        UIView.transition(with: view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            self.view.sendSubviewToBack(selectedView)
        }, completion: nil)
    }
    
    private func scrollToCenter(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            currentWeatherIndex = (currentWeatherIndex + 1) % weatherViews.count
        } else if gesture.direction == .right {
            currentWeatherIndex = (currentWeatherIndex - 1 + weatherViews.count) % weatherViews.count
        }
        displayWeather(at: currentWeatherIndex)
        selectItem(at: currentWeatherIndex)
        scrollToCenter(at: currentWeatherIndex)
    }
    
    private func selectItem(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        displayWeather(at: index)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        scrollToCenter(at: currentWeatherIndex)
        updateCellAppearances()
    }
    
    
    private func updateCellAppearances() {
        for cell in collectionView.visibleCells {
            if let weatherCell = cell as? WeatherCell {
                weatherCell.updateAppearance()
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherIcons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as! WeatherCell
        cell.imageView.image = UIImage(named: weatherIcons[indexPath.row])
        cell.titleLabel.text = NSLocalizedString(weatherIcons[indexPath.row], comment: "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentWeatherIndex = indexPath.row
        displayWeather(at: indexPath.row)
        scrollToCenter(at: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

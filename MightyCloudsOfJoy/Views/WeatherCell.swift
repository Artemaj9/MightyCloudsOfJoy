import UIKit

class WeatherCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    let imageView: UIImageView
    let titleLabel: UILabel
    var metalView: WeatherMetalView?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        titleLabel = UILabel()
        
        super.init(frame: frame)
        
        setupImageView()
        setupTitleLabel()
        setupConstraints()
        
        contentView.backgroundColor = .clear
        contentView.layer.borderColor = UIColor.green.withAlphaComponent(0.2).cgColor
        contentView.layer.borderWidth = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0.5
        contentView.addSubview(imageView)
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white.withAlphaComponent(0.5)
        contentView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func updateAppearance() {
        if isSelected {
            imageView.alpha = 1.0
            titleLabel.textColor = .white
        } else {
            imageView.alpha = 0.5
            titleLabel.textColor = .white.withAlphaComponent(0.5)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
}

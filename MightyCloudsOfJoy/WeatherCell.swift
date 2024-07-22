//
//  WeatherCell.swift
//
//
import UIKit
//
//class WeatherCell: UICollectionViewCell {
//    
//    let imageView: UIImageView
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

class WeatherCell: UICollectionViewCell {
    
    let imageView: UIImageView
    var metalView: WeatherMetalView?
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.backgroundColor = .clear
        contentView.layer.borderColor = UIColor.green.withAlphaComponent(0.2).cgColor
        contentView.layer.borderWidth = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? 2 : 0
        }
    }
}

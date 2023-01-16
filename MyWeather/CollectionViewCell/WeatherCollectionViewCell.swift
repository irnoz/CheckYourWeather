//
//  WeatherCollectionViewCell.swift
//  MyWeather
//
//  Created by Irakli Nozadze on 13.01.23.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    static let identifier = "WeatherCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell",
                     bundle: nil)
    }
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var temperatureLabel: UILabel!
    
    func configure(with model: HourlyWeatherEntry) {
        self.temperatureLabel.text = "\(Int(model.temperature))°"
        self.iconImageView.contentMode = .scaleAspectFit
        
        let icon = model.icon.lowercased()
        if icon.contains("clear") {
            self.iconImageView.image = UIImage(named: "clear")
        } else if icon.contains("rain") {
            self.iconImageView.image = UIImage(named: "rain")
        } else {
            self.iconImageView.image = UIImage(named: "cloud")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

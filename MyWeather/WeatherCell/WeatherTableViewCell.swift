//
//  WeatherTableViewCell.swift
//  MyWeather
//
//  Created by Irakli Nozadze on 11.01.23.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var highTemperatureLabel: UILabel!
    @IBOutlet var lowTemperatureLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static let identifier = "WeatherTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell",
                     bundle: nil)
    }
    
    func configure(with model: DailyWeatherEntry) {
        self.highTemperatureLabel.textAlignment = .center
        self.lowTemperatureLabel.textAlignment = .center
        
        self.highTemperatureLabel.text = "\(Int(model.temperatureHigh))°"
        self.lowTemperatureLabel.text = "\(Int(model.temperatureLow))°"
        self.dayLabel.text = getDayForDate(Date(timeIntervalSince1970: Double(model.time)))

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
    
    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        return formatter.string(from: inputDate)
    }
}

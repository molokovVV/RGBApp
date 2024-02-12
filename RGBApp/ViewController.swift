//
//  ViewController.swift
//  RGBApp
//
//  Created by Виталик Молоков on 06.02.2024.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UIColorPickerViewControllerDelegate {
    
    //MARK: - UI Elements
    
    private lazy var firstColorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Select Color"
        return label
    }()
    
    private lazy var secondColorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Select Color"
        return label
    }()
    
    private lazy var mixedColorNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Color Name"
        return label
    }()
    private lazy var languageChangeLabel: UILabel = {
        let label = UILabel()
        label.text = "Translate"
        return label
    }()
    
    private lazy var firstColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 25
        button.addTarget(nil, 
                         action: #selector(presentColorPicker(_:)), 
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var secondColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 25
        button.addTarget(nil, 
                         action: #selector(presentColorPicker(_:)), 
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var mixedColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 25
        view.backgroundColor = .systemGray
        return view
    }()
    
    private lazy var languageSwitch: UISwitch = {
        let selector = UISwitch()
        selector.addTarget(nil, 
                           action: #selector(toggleLanguage(_:)), 
                           for: .valueChanged)
        return selector
    }()
    
    //MARK: - Properties
    
    var selectedColorButton: UIButton?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupView()
        setupHierarchy()
        setupLayout()
    }
    
    //MARK: - Setups
    
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupHierarchy() {
        view.addSubview(languageChangeLabel)
        view.addSubview(languageSwitch)
        view.addSubview(mixedColorView)
        view.addSubview(firstColorLabel)
        view.addSubview(secondColorLabel)
        view.addSubview(firstColorButton)
        view.addSubview(secondColorButton)
        view.addSubview(mixedColorNameLabel)
    }
    
    private func setupLayout() {
        
        firstColorButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        firstColorLabel.snp.makeConstraints { make in
            make.top.equalTo(firstColorButton.snp.bottom).offset(10)
            make.centerX.equalTo(firstColorButton.snp.centerX)
            make.left.right.equalToSuperview().inset(20) 
        }
        
        secondColorButton.snp.makeConstraints { make in
            make.top.equalTo(firstColorLabel.snp.top).offset(100)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        secondColorLabel.snp.makeConstraints { make in
            make.top.equalTo(secondColorButton.snp.bottom).offset(10)
            make.centerX.equalTo(secondColorButton.snp.centerX)
            make.left.right.equalToSuperview().inset(20) 
        }
        
        languageChangeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-50)
            make.top.equalTo(mixedColorNameLabel.snp.bottom).offset(50)
        }
        
        languageSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(languageChangeLabel.snp.centerY)
            make.left.equalTo(languageChangeLabel.snp.right).offset(10)
        }
        
        mixedColorNameLabel.snp.makeConstraints { make in
            make.top.equalTo(mixedColorView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        mixedColorView.snp.makeConstraints { make in
            make.top.equalTo(secondColorLabel.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        viewController.dismiss(animated: true)
        
        let selectedColor = viewController.selectedColor
        selectedColorButton?.backgroundColor = selectedColor
        
        // Запрашивание и обновление цвета
        APIManager.fetchColorNameFromAPI(color: selectedColor) { [weak self] fetchedColorName in
            DispatchQueue.main.async {
                if self?.selectedColorButton == self?.firstColorButton {
                    self?.firstColorLabel.text = fetchedColorName
                } else if self?.selectedColorButton == self?.secondColorButton {
                    self?.secondColorLabel.text = fetchedColorName
                }
                
                // Проверка и обновление смешанного цвета
                if let color1 = self?.firstColorButton.backgroundColor, let color2 = self?.secondColorButton.backgroundColor {
                    let mixedColor = self?.mixColors(color1: color1, color2: color2)
                    self?.mixedColorView.backgroundColor = mixedColor
                    APIManager.fetchColorNameFromAPI(color: mixedColor ?? .gray) { mixedColorName in
                        self?.mixedColorNameLabel.text = "\(mixedColorName)"
                        self?.updateMixedColorAfterTranslation()
                    }
                }
            }
        }
    }
    
    //MARK: - Actions
    
    // Метод выбора цвета
    @objc private func presentColorPicker(_ sender: UIButton) {
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        selectedColorButton = sender
        present(colorPickerVC, animated: true)
    }
    
    // Методд переключения языка
    @objc private func toggleLanguage(_ sender: UISwitch) {
            let targetLanguage = sender.isOn ? "ru" : "en"
            let sourceLanguage = sender.isOn ? "en" : "ru"
            
            // Обновление текста для каждого UILabel
            updateLabelTranslation(for: firstColorLabel, 
                                   text: firstColorLabel.text ?? "", 
                                   sourceLanguage: sourceLanguage, 
                                   targetLanguage: targetLanguage)
        
            updateLabelTranslation(for: secondColorLabel, text: secondColorLabel.text ?? "", 
                                   sourceLanguage: sourceLanguage, 
                                   targetLanguage: targetLanguage)
        
            updateLabelTranslation(for: mixedColorNameLabel, 
                                   text: mixedColorNameLabel.text ?? "", 
                                   sourceLanguage: sourceLanguage, 
                                   targetLanguage: targetLanguage)
        updateLabelTranslation(for: languageChangeLabel, 
                               text: languageChangeLabel.text ?? "", 
                               sourceLanguage: sourceLanguage, 
                               targetLanguage: targetLanguage)
        }
 
    //MARK: - Buisness Logic
    
    // Метод обновленния цвета
    private func updateMixedColorAfterTranslation() {
        
        guard let color1 = firstColorButton.backgroundColor, let color2 = secondColorButton.backgroundColor else { return }

        let mixedColor = mixColors(color1: color1, color2: color2)
        mixedColorView.backgroundColor = mixedColor
        
        APIManager.fetchColorNameFromAPI(color: mixedColor) { [weak self] mixedColorName in
            guard let self = self else { return }

            // Проверяем включен ли UISwitch
            if self.languageSwitch.isOn {
                let sourceLanguageCode = "en" 
                let targetLanguageCode = "ru" 
                
                APIManager.translateTextWithYandexTranslateAPI(text: mixedColorName, sourceLanguageCode: sourceLanguageCode, targetLanguageCode: targetLanguageCode) { translatedText, error in
                    DispatchQueue.main.async {
                        if let translatedText = translatedText {
                            self.mixedColorNameLabel.text = "\(translatedText)"
                        } else {
                            self.mixedColorNameLabel.text = "\(mixedColorName)"
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.mixedColorNameLabel.text = "\(mixedColorName)"
                }
            }
        }
    }
    
    // Метод смешивания двух цветов
    private func mixColors(color1: UIColor, color2: UIColor) -> UIColor {
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
        
        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        return UIColor(red: (red1 + red2) / 2, green: (green1 + green2) / 2, blue: (blue1 + blue2) / 2, alpha: (alpha1 + alpha2) / 2)
    }
    
    // Метод обновления текста путем перевода его на указанный язык
    private func updateLabelTranslation(for label: UILabel, text: String, sourceLanguage: String, targetLanguage: String) {
        APIManager.translateTextWithYandexTranslateAPI(text: text, sourceLanguageCode: sourceLanguage, targetLanguageCode: targetLanguage) { translatedText, error in
            DispatchQueue.main.async {
                if let translatedText = translatedText {
                    label.text = translatedText
                } else if let error = error {
                    print("Translation error: \(error.localizedDescription)")
                }
            }
        }
    }
}







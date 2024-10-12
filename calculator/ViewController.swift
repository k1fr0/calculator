//
//  ViewController.swift
//  calculator
//
//  Created by Кирилл  on 12.10.2024.
//

import UIKit

class ViewController: UIViewController {
    
    // задание переменных
    private var displayLabel: UILabel!
    private var buttonTitles: [[String]] = [
        ["AC", "^2", "%", "/"],
        ["7", "8", "9", "*"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["00", "0", ",", "="]
    ]
    
    // отображение начальной строки
    private var currentInput: String = "0" {
        didSet {
            displayLabel.text = currentInput
        }
    }
    
    private var userIsInTheMiddleOfTyping = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setting()
    }
    
    // настройка интерфейса
    private func setting() {
        view.backgroundColor = .black
        
        // Настройка отображения
        displayLabel = UILabel()
        displayLabel.text = "0"
        displayLabel.font = UIFont.systemFont(ofSize: 64)
        displayLabel.textAlignment = .right
        displayLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        displayLabel.textColor = .white
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(displayLabel)
        
        // настройка StackView для размещения кнопок
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        // добавление строки с кнопками в StackView
        for row in buttonTitles {
            let horizontalStackView = UIStackView()
            horizontalStackView.axis = .horizontal
            horizontalStackView.alignment = .fill
            horizontalStackView.distribution = .fillEqually
            horizontalStackView.spacing = 10
            for title in row {
                let button = createButton(withTitle: title)
                horizontalStackView.addArrangedSubview(button)
            }
            buttonStackView.addArrangedSubview(horizontalStackView)
        }
        
        // добавление ограничений для displayLabel и buttonStackView
        NSLayoutConstraint.activate([
            displayLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 205),
            displayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            displayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            displayLabel.heightAnchor.constraint(equalToConstant: 80),
            
            buttonStackView.topAnchor.constraint(equalTo: displayLabel.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // создание кнопок
    private func createButton(withTitle title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        button.backgroundColor = #colorLiteral(red: 0.1686272621, green: 0.1686276495, blue: 0.1772211492, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 40
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // привязка действия к кнопкам
        if title == "=" {
            button.addTarget(self, action: #selector(equalsPressed(_:)), for: .touchUpInside)
            button.backgroundColor = #colorLiteral(red: 1, green: 0.6257896423, blue: 0.03897520155, alpha: 1)
        } else if title == "AC" {
            button.addTarget(self, action: #selector(clearPressed(_:)), for: .touchUpInside)
            button.backgroundColor = #colorLiteral(red: 0.3607841134, green: 0.360784471, blue: 0.3693870902, alpha: 1)
        } else if title == "%" {
            button.addTarget(self, action: #selector(percentPressed(_:)), for: .touchUpInside)
            button.backgroundColor = #colorLiteral(red: 0.3607841134, green: 0.360784471, blue: 0.3693870902, alpha: 1)
        }else if title == "^2" {
            button.addTarget(self, action: #selector(squarePressed(_:)), for: .touchUpInside)
            button.backgroundColor = #colorLiteral(red: 0.3607841134, green: 0.360784471, blue: 0.3693870902, alpha: 1)
        } else if title == "," {
            button.addTarget(self, action: #selector(decimalPressed(_:)), for: .touchUpInside)
        } else if ["+", "-", "*", "/"].contains(title) {
            button.addTarget(self, action: #selector(operationPressed(_:)), for: .touchUpInside)
            button.backgroundColor = #colorLiteral(red: 1, green: 0.6257896423, blue: 0.03897520155, alpha: 1)
        } else {
            button.addTarget(self, action: #selector(digitPressed(_:)), for: .touchUpInside)
        }
        
        return button
    }
    
    // обработка нажатия на цифры
    @objc private func digitPressed(_ sender: UIButton) {
        guard let digit = sender.currentTitle else { return }
        if currentInput == "0" || currentInput == "00"{
            currentInput = digit
        }else{
            currentInput += digit
        }
    }
    
    // обработка нажатия на операции
    @objc private func operationPressed(_ sender: UIButton) {
        guard let operation = sender.currentTitle else { return }
        currentInput += " \(operation) "
        userIsInTheMiddleOfTyping = false
    }
    
    // обработка нажатия на "="
        @objc func equalsPressed(_ sender: UIButton) {
            if currentInput.contains("/ 0") {
                currentInput = "Нельзя"
            } else {
                currentInput = String(formatResult(calculateResult(from: currentInput)))
            }
            userIsInTheMiddleOfTyping = false
        }
        
        // метод для вычисления результата из строки
        private func calculateResult(from input: String) -> Double {
            let expressionComponents = input.split(separator: " ").map { String($0) }
            var result = 0.0
            var currentOperation: String? = nil

            for component in expressionComponents {
                if let number = Double(component) {
                    if let operation = currentOperation {
                        switch operation {
                        case "+":
                            result += number
                        case "-":
                            result -= number
                        case "*":
                            result *= number
                        case "/":
                            if number != 0 {
                                result /= number
                            } else {
                                return 0
                            }
                        default:
                            break
                        }
                    } else {
                        result = number
                    }
                } else {
                    currentOperation = component
                }
            }
            return result
        }
    
    // форматирование результата для отображения дробных значений
        private func formatResult(_ result: Double) -> String {
            if result.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%.0f", result) // целое число, если нет остатка
            } else {
                return String(format: "%.7f",result) // дробное число
            }
        }
    
    // обработка нажатия на "%"
    @objc private func percentPressed(_ sender: UIButton) {
        if let value = Double(currentInput) {
            currentInput = String(formatResult(value / 100))
        }
        userIsInTheMiddleOfTyping = false
    }
    
    // обработка нажатия на "^2"
    @objc private func squarePressed(_ sender: UIButton) {
        if let value = Double(currentInput) {
            currentInput = String(formatResult(value * value))
        }
        userIsInTheMiddleOfTyping = false
    }
    
    // обработка нажатия на запятую "."
    @objc private func decimalPressed(_ sender: UIButton) {
        if !currentInput.contains(".") {
            if currentInput != "00"{
                currentInput += "."
            }else{
                currentInput = "Ошибка"
            }
            
        }
    }
    
    // сброс строки
    @objc private func clearPressed(_ sender: UIButton) {
        currentInput = "0"
        userIsInTheMiddleOfTyping = false
    }
}

//
//  ViewController.swift
//  EggTimerNoStoryboard
//
//  Created by Eugene Kotovich on 06.04.2022.
//

import SwiftUI
import AVFoundation
import SnapKit

class ViewController: UIViewController {
    
    let eggTimes = ["soft": 5 * 60, "medium": 7 * 60, "hard": 12 * 60]
    var timer = Timer()
    var secondsRemaining = 30
    var time = 1
    private var buttons: [UIButton] = []
    var player = AVAudioPlayer()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "How do you like your eggs?"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .darkGray
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    enum EggLabel: String, CaseIterable {
        case soft
        case medium
        case hard
        var image: String {
            "\(self.rawValue)_egg"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
//MARK: - Create and setup Progress Bar
    
    let progress: UIProgressView = {
        let progress = UIProgressView()
        progress.progressViewStyle = .bar
        progress.progress = 0.0
        progress.tintColor = .systemYellow
        progress.trackTintColor = .systemGray4
        progress.snp.makeConstraints { make in
            make.height.equalTo(5)
        }
        return progress
    }()

//MARK: - Create and setup Buttons
    
    func createButtons() {
        EggLabel.allCases.forEach {
            let button = UIButton()
            button.setTitle($0.rawValue, for: .normal)
            button.setImage(UIImage(named: $0.image), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(hardnessSelected), for: .touchUpInside)
            buttons.append(button)
            view.addSubview(button)
        }
    }
    
//MARK: - Create and setup Timer
    
    @objc func hardnessSelected(_ sender: UIButton) {
        if let hardness = sender.currentTitle {
            timer.invalidate()
            secondsRemaining = eggTimes[hardness] ?? 1
            time = secondsRemaining
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateTimer() {
        if secondsRemaining > 0 {
            secondsRemaining -= 1
            progress.progress = 1.0 - Float(secondsRemaining)/Float(time)
        } else if secondsRemaining == 0 {
            titleLabel.text = "Bon appetit!"
            playSound()
            timer.invalidate()
        }
        
        func playSound() {
            guard let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "mp3") else { return }
            player = try! AVAudioPlayer(contentsOf: url)
            player.play()
        }
    }
    
//MARK: - Initialize UI
    
    func initialize() {
        view.backgroundColor = UIColor(named: "BackgroundColor")
        createButtons()
        let eggs = UIStackView(arrangedSubviews: buttons)
        eggs.axis = .horizontal
        eggs.distribution = .fillEqually
        eggs.alignment = .center
        eggs.spacing = 10
        view.addSubview(eggs)
        let stack = UIStackView(arrangedSubviews: [titleLabel, eggs, progress])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .fill
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.bottom.equalTo(-100)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            
        }
    }

}

//MARK: - Setup SwiftUI Preview

struct FlowProvider: PreviewProvider {
    static var previews: some View {
        ContainterView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainterView: UIViewControllerRepresentable {
        
        let view = ViewController()
        func makeUIViewController(context: UIViewControllerRepresentableContext<FlowProvider.ContainterView>) -> ViewController {
            return view
        }
        
        func updateUIViewController(_ uiViewController: FlowProvider.ContainterView.UIViewControllerType, context: UIViewControllerRepresentableContext<FlowProvider.ContainterView>) {
            
        }
        
    }
    
}

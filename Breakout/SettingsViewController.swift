//
//  SettingsViewController.swift
//  Breakout
//
//  Created by nevercry on 10/15/15.
//  Copyright © 2015 nevercry. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var columnSlider: UISlider!
    @IBOutlet weak var rowSlider: UISlider!
    @IBOutlet weak var ballStepper: UIStepper!
    @IBOutlet weak var difficultySelector: UISegmentedControl!
    @IBOutlet weak var autoStartSwitch: UISwitch!
    @IBOutlet weak var speedSlider: UISlider!
    
    @IBOutlet weak var columnLabel: UILabel!
    @IBOutlet weak var rowLabel: UILabel!
    @IBOutlet weak var ballLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    var columns: Int {
        get { return Int(columnLabel.text!)! }
        set {
            columnLabel.text = "\(newValue)"
            columnSlider.value = Float(newValue)
        }
    }
    
    var rows: Int {
        get { return Int(rowLabel.text!)! }
        set {
            rowLabel.text = "\(newValue)"
            rowSlider.value = Float(newValue)
        }
    }
    
    var balls: Int {
        get { return Int(ballLabel.text!)! }
        set {
            ballLabel.text = "\(newValue)"
            ballStepper.value = Double(newValue)
        }
    }
    
    var difficulty: Int {
        get { return difficultySelector.selectedSegmentIndex }
        set { difficultySelector.selectedSegmentIndex = newValue }
    }
    
    var autoStart: Bool {
        get { return autoStartSwitch.on }
        set { autoStartSwitch.on = newValue }
    }
    
    var speed: Float {
        get { return speedSlider.value / 100.0 }
        set {
            speedSlider.value = newValue * 100.0
            speedLabel.text = "\(Int(speedSlider.value)) %"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        columns = Settings().columns!
        rows = Settings().rows!
        balls = Settings().balls!
        difficulty = Settings().difficulty!
        autoStart = Settings().autoStart
        speed = Settings().speed
    }
    
    @IBAction func columnsChanged(sender: UISlider) {
        columns = Int(sender.value)
        Settings().columns = columns
        Settings().changed = true
    }
    
    @IBAction func rowsChanged(sender: UISlider) {
        rows = Int(sender.value)
        Settings().rows = rows
        Settings().changed = true
    }
    
    @IBAction func ballsChanged(sender: UIStepper) {
        balls = Int(sender.value)
        Settings().balls = balls
    }
    
    @IBAction func difficultyChanged(sender: UISegmentedControl) {
        Settings().difficulty = sender.selectedSegmentIndex
        Settings().changed = true
    }
    
    @IBAction func autoStartChanged(sender: UISwitch) {
        Settings().autoStart = autoStart
    }
    
    @IBAction func speedChanged(sender: UISlider) {
        speed = sender.value / 100.0
        Settings().speed = speed
        Settings().changed = true
    }
    
    
    
    
    
}

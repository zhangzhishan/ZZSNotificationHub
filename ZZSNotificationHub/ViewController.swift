//
//  ViewController.swift
//  ZZSNotificationHub
//
//  Created by Zhishan Zhang on 7/14/16.
//  Copyright (c) 2016 code4fun. All rights reserved.
//


import UIKit


class ViewController: UIViewController {


    var hub: ZZSNotificationHub!
    var barHub: ZZSNotificationHub!
    @IBOutlet weak var barButtonItem: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupButton()
        let imageView: UIImageView = UIImageView(image: UIImage(named: "mail"))
        imageView.frame = CGRect(x: self.view.frame.size.width / 2 - 35, y: 120, width: 70, height: 70)
        hub = ZZSNotificationHub(view: imageView)
        hub.moveCircleByX(-5, Y: 5)
        // moves the circle five pixels left and 5 down
        barHub = ZZSNotificationHub(barButtonItem: barButtonItem!)
        barHub.increment()
        self.view.addSubview(imageView)
    }

    @IBAction func barButtonPressed(_ sender: AnyObject) {
        barHub.increment()
//        barHub.pop()
//        barHub.blink()
        barHub.bump()
    }

    func testIncrement() {
        hub.increment()
//        hub.pop()
//        barHub.blink()
        barHub.bump()
    }

    func setupButton() {
        let color: UIColor = UIColor(red: 0.15, green: 0.67, blue: 0.88, alpha: 1)
        let button: UIButton = UIButton(frame: CGRect(x: 50, y: 400, width: 200, height: 60))
        button.center = self.view.center
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.setTitle("Increment", for: UIControlState())
        button.backgroundColor = color
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(testIncrement), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }




}

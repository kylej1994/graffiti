//
//  PostViewController.swift
//  Graffiti
//
//  Created by Judah Newman on 2/23/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    
    @IBOutlet var SegmentedControl: UISegmentedControl!
    
    
    private lazy var textPostViewController: TextPostViewController = {
        
        let storyboard = UIStoryboard(name: "TextPost" , bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "TextPostViewController") as! TextPostViewController
        
        self.add(asChildViewController: viewController)
        
        return viewController
        
    }()
    
    
    private lazy var photoPostViewController: PhotoPostViewController = {
        
        let storyboard = UIStoryboard(name: "TextPost" , bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "PhotoPostViewController") as! PhotoPostViewController
        
        self.add(asChildViewController: viewController)
        
        return viewController
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()

        // Do any additional setup after loading the view.
    }
    

    
   
 
    private func add(asChildViewController viewController: UIViewController) {
        
        addChildViewController(viewController)
        
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    
    
    
    private func updateView() {
        if SegmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: textPostViewController)
            add(asChildViewController: photoPostViewController)
        } else {
            remove(asChildViewController: photoPostViewController)
            add(asChildViewController: textPostViewController)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupView(){
       setupSegmentedControl()
        
        updateView()
    }
    
    private func setupSegmentedControl(){
        SegmentedControl.removeAllSegments()
        SegmentedControl.insertSegment(withTitle: "Text", at: 0, animated: false)
        SegmentedControl.insertSegment(withTitle: "Photo", at: 1, animated: false)
        SegmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        SegmentedControl.selectedSegmentIndex = 0
        
        
    }
    
    func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

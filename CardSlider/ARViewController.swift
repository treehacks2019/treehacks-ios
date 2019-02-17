//
//  ARViewController.swift
//  CardSlider
//
//  Created by Stewart Dulaney on 2/16/19.
//  Copyright © 2019 Saoud Rizwan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Firebase
import CoreLocation

class ARViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var treeNode: SCNNode?
    let locationManager = CLLocationManager()
    var lat: Double = 0.0
    var long : Double = 0.0
    var username = "Will"
    var timer: Timer!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let id = UIDevice.current.identifierForVendor!.uuidString
        let ref = Database.database().reference()
        ref.child(id).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            self.username = snapshot.value as? String ?? ""
        }) { (error) in
            print(error.localizedDescription)
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/Lowpoly_tree_sample.dae")!
        self.treeNode = scene.rootNode.childNode(withName: "Tree_lp_11", recursively: true)
        self.treeNode?.position = SCNVector3Make(0, 0, -1)
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Create timer
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] (_) in
            self?.timerHasBeenCalled()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            long = location.coordinate.longitude
            lat = location.coordinate.latitude
            let ref = Database.database().reference()
            ref.child("profile").child(username).child("lat").setValue(lat);
            ref.child("profile").child(username).child("lng").setValue(long);
            
        }
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func timerHasBeenCalled() {
        // update this
        var target = "Jennie"
        var target_lat = 0.0
        var target_lng = 0.0
        if (username == "Jennie") {target = "Will"}
        
        let ref = Database.database().reference()
        ref.child("profile").child(target).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String : AnyObject] ?? [:]
            if (value["lat"] != nil) {
                target_lat = value["lat"] as! Double
            }
            if (value["lng"] != nil) {
                target_lng = value["lng"] as! Double
            }
            print(target_lat,target_lng, "gotten")
            // update
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
    }
    
}


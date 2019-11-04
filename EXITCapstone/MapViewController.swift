//
//  ViewController.swift
//  EXITCapstone
//
//  Created by 김민국 on 2018. 7. 17..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit
import ARKit
import ARCL
import SceneKit
import MapKit
import MapboxDirections
import FirebaseDatabase

class MapViewController: UIViewController, ARSCNViewDelegate {

    
    @IBOutlet var sceneBackView: UIView!
    var sceneLocationView = SceneLocationView()
    let leftImage = UIImage(named: "TurnLeft.png")
    let rightIimage = UIImage(named: "TurnRight.png")
    let destImage = UIImage(named: "pin.png")
    let altitude: CLLocationDistance = 170 //평면도로 = 35 //높은지역 = 170 < 행긱
    
    var bottomSheetVC: BottomSheetViewController?
    var isBottomSheetVC: Bool = false
    var blackView: UIView!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var center: UIImageView!
    var adjustNorthByTappingSidesOfScreen = false
    var annotationsList: [LocationAnnotationNode] = []
    var destAnnotationList: LocationAnnotationNode? = nil
    
    @IBOutlet var selectTrackModeBtnView: UIButton!
    @IBOutlet var selectInformBtn: UIButton!
    
    let trackBtnImage1 = UIImage(named: "button_1.png")
    let trackBtnImage2 = UIImage(named: "button_2.png")
    let trackBtnImage3 = UIImage(named: "button_3.png")
    let informBtnImage = UIImage(named: "button_i.png")
    
    var CtrackBtnImage1 = UIImage()
    var CtrackBtnImage2 = UIImage()
    var CtrackBtnImage3 = UIImage()
    var CinformBtnImage = UIImage()
    
    let imageSize = 35
    
    var blackV = UIView()
    var serverLoadingV = UIView()
    
    var locationManager = CLLocationManager()
    let dispatchGroup = DispatchGroup()
    
    let directions = Directions(accessToken: "pk.eyJ1Ijoia2ltbWluZ3VrIiwiYSI6ImNqam9naGZvcTA0aG4zcG83a3F2OGN4cmgifQ.vHcE_awzx1KuPSmo1jcJfA")
    
    @IBOutlet var centerImg: UIImageView!
    var waypointAnnotations: [MKPointAnnotation] = []
//    var Centerlat:CLLocationDegrees = 0.0
//    var Centerlon:CLLocationDegrees = 0.0
    
    var SortedAPIData: [Place] = []
    
    @IBOutlet var multiRouteBtnView: UISwitch!
    @IBOutlet var waypointStepperView: UIStepper!
    
    var overlayList = [MKPolyline]()
    
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
//    var dangerAnnotations
    
    var multiRouteBool: Bool = false {
        didSet{
            if multiRouteBool == true{
                center.isHidden = false
                waypointStepperView.isHidden = false
                waypointAnnotations.removeAll()
            }else{
                center.isHidden = true
                waypointStepperView.isHidden = true
                multiRouteBtnView.isOn = false
            }
        }
    }

    var selectedInx = 0{
        didSet{
            loadingView()
            oneWayToDest()
        }
    }
    
    var progressValue: Float = 0.0{
        didSet{
            if progressValue == 1{
                loadingView()
                SortByDistance()
            }
        }
    }
    
    var APIData = [[String:Any]]() {
        didSet{
            progressValue += 0.5
        }
    }
    
    var userLocation = CLLocation(){
        didSet{
            progressValue += 0.5
        }
    }
    var waypointValue: Int = 0 {
        didSet(oldVal){
            if multiRouteBool == true {
                if oldVal > waypointValue{
                    if mapView.overlays.count != 0 {
                        mapView.removeOverlays(overlayList)
                    }
                    annotationValueMinus()
                }else{
                    if mapView.overlays.count != 0 {
                        mapView.removeOverlays(overlayList)
                    }
                    annotationValuePlus()
                }
            }
        }
    }
    
    var trackMode: Bool = false{
        didSet{
            if trackMode == true{
                
                mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
                selectTrackModeBtnView.setImage(CtrackBtnImage1, for: .normal)
            }else{
                mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
                
                selectTrackModeBtnView.setImage(CtrackBtnImage2, for: .normal)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        center.isHidden = true
        waypointStepperView.isHidden = true
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        view.sendSubviewToBack(sceneBackView)
        sceneBackView.addSubview(sceneLocationView)
        
        
        
        serverLoadingView()
        databaseHandle = ref.child("지역").child("부산광역시").observe(.childAdded, with: { (snapshot) in
            for snap in (snapshot.children.allObjects as! [DataSnapshot]){
                let test = snap.value as! [String:AnyObject]
                let lat = (test["latitude"] as! NSString).doubleValue
                let lon = (test["longitude"] as! NSString).doubleValue
                self.addRadiusCircle(location: CLLocation(latitude: lat, longitude: lon))
            }
            self.serverLoadingV.removeFromSuperview()
        })

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        center.center = mapView.center
        selectTrackModeBtnView.setBackgroundImage(UIImage(named: "button_background.png"), for: .normal)
        
        CtrackBtnImage1 = (trackBtnImage1?.resizedImage(newSize: CGSize(width: imageSize, height: imageSize)))!
        CtrackBtnImage2 = (trackBtnImage2?.resizedImage(newSize: CGSize(width: imageSize, height: imageSize)))!
        CtrackBtnImage3 = (trackBtnImage3?.resizedImage(newSize: CGSize(width: imageSize, height: imageSize)))!
        
        selectTrackModeBtnView.setImage(CtrackBtnImage3, for: .normal)
        
        CinformBtnImage = (informBtnImage?.resizedImage(newSize: CGSize(width: imageSize, height: imageSize)))!
        selectInformBtn.setImage(CinformBtnImage, for: .normal)
        
        sceneLocationView.run()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = sceneBackView.bounds
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
    }
    
    @IBAction func sendDangerLocation(_ sender: Any) {
        let lati = String(self.mapView.userLocation.coordinate.latitude)
        let long = String(self.mapView.userLocation.coordinate.longitude)
        self.ref.child("지역").child("부산광역시").childByAutoId().child("주소").setValue(["latitude":"\(lati)","longitude":"\(long)"])
    }
    
    
    @IBAction func multiRouteBtn(_ sender: UISwitch) {
        if sender.isOn == true{
            multiRouteBool = true
        }else{
            multiRouteBool = false
            waypointAnnotations.removeAll()
            waypointValue = 0
            waypointStepperView.value = 0
            loadingView()
            oneWayToDest()
        }
    }

    @IBAction func waypointStepperBtn(_ sender: UIStepper) {
        waypointValue = Int(sender.value)
    }
    @IBAction func selectTrackModeBtn(_ sender: Any) {
        if trackMode == true{
            trackMode = false
            
        }else{
            trackMode = true
        }
    }
    
    @IBAction func informBtn(_ sender: Any) {
        if isBottomSheetVC == false
        {
            blackView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            blackView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            self.view.addSubview(blackView)
            
            isBottomSheetVC = true
            bottomSheetVC = BottomSheetViewController()
            bottomSheetVC?.SortedAPIData = SortedAPIData[selectedInx]
            self.addChild(bottomSheetVC!)
            self.view.addSubview((bottomSheetVC?.view)!)
            bottomSheetVC?.didMove(toParent: self)
            
            let height = view.frame.height
            let width  = view.frame.width
            bottomSheetVC?.view.frame = CGRect(x: 0, y: self.view.frame.height, width: width, height: height)
        }
    }
    
    // test-------------------------------------------------------------
 
    // test-------------------------------------------------------------
    func annotationValueMinus(){
        if waypointAnnotations.count != 0{
            loadingView()
            self.mapView.removeAnnotation(waypointAnnotations.last!)
            waypointAnnotations.removeLast()
            
            var waypointsF = [
                Waypoint(coordinate: (userLocation.coordinate), name: "UserLocation")
            ]
            for point in waypointAnnotations{
                waypointsF.append(Waypoint(coordinate: point.coordinate, name: "between"))
            }
            waypointsF.append(Waypoint(coordinate: SortedAPIData[selectedInx].location.coordinate, name: "Destination"))
            MultipleWayToDest(waypoints: waypointsF)
        }
    }
    func annotationValuePlus(){
        loadingView()
        let Centerlat = mapView.centerCoordinate.latitude
        let Centerlon = mapView.centerCoordinate.longitude
        
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: Centerlat, longitude: Centerlon)
        
        self.mapView.addAnnotation(annotation)
        waypointAnnotations.append(annotation)
        
        var waypointsF = [
            Waypoint(coordinate: (userLocation.coordinate), name: "UserLocation")
        ]
        for point in waypointAnnotations{
            waypointsF.append(Waypoint(coordinate: point.coordinate, name: "between"))
        }
        waypointsF.append(Waypoint(coordinate: SortedAPIData[selectedInx].location.coordinate, name: "Destination"))
        MultipleWayToDest(waypoints: waypointsF)
    }
    
    func SortByDistance(){
        for i in 0...APIData.count - 1{
            let place = Place()
            place.name = APIData[i]["소재지도로명주소"] as? String
            place.latitude = (APIData[i]["위도"] as! NSString).doubleValue
            place.longitude = (APIData[i]["경도"] as! NSString).doubleValue
            place.realName = APIData[i]["민방위대피시설명"] as? String
            place.address = APIData[i]["소재지도로명주소"] as? String
            place.count = APIData[i]["대피가능인원수"] as? String
            SortedAPIData.append(place)
        }
        SortedAPIData.sort(by: { $0.distance(fromMy: userLocation) < $1.distance(fromMy: userLocation) })

        let reveal = self.revealViewController()
        let table = reveal?.rightViewController as! ListTableViewController
        table.APIData = SortedAPIData
        view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        oneWayToDest()
    }
    func loadingView(){
        blackV = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        blackV.backgroundColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 0.3)
        
        let wait = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        wait.activityIndicatorViewStyle = .whiteLarge
        wait.startAnimating()
        wait.center = blackV.center
        blackV.addSubview(wait)
        self.view.addSubview(blackV)
    }
    
    func serverLoadingView(){
        serverLoadingV = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        serverLoadingV.backgroundColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 0.3)
        
        let wait = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        wait.activityIndicatorViewStyle = .whiteLarge
        wait.startAnimating()
        wait.center = blackV.center
        serverLoadingV.addSubview(wait)
        self.view.addSubview(serverLoadingV)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isBottomSheetVC == true
        {
            UIView.animate(withDuration: 0.3, animations: {
                let frame = self.view.frame
                self.bottomSheetVC?.view.frame = CGRect(x: 0, y: self.view.frame.height, width: frame.width, height: frame.height)
                self.blackView.removeFromSuperview()
                self.bottomSheetVC = nil
                self.isBottomSheetVC = false
            })
        }
        
    }
}
extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate{
    func oneWayToDest(){
        locationManager.startUpdatingLocation()
        
        if destAnnotationList != nil{
            self.sceneLocationView.removeLocationNode(locationNode: destAnnotationList!)
            destAnnotationList = nil
        }
        
        if annotationsList.count != 0{
            for i in 0...annotationsList.count - 1{
                self.sceneLocationView.removeLocationNode(locationNode: annotationsList[i])
            }
            self.annotationsList.removeAll()
        }
        if mapView.overlays.count != 0 {

            mapView.removeOverlays(overlayList)
        }
        
        if mapView.annotations.count != 0{
            mapView.removeAnnotations(mapView.annotations)
        }
        
        let waypoints = [
            Waypoint(coordinate: (userLocation.coordinate), name: "UserLocation"),
            Waypoint(coordinate: SortedAPIData[selectedInx].location.coordinate, name: "Destination")
            ]
        let options = RouteOptions(waypoints: waypoints, profileIdentifier: MBDirectionsProfileIdentifier.walking)
        options.includesSteps = true
        options.includesAlternativeRoutes = true
        
        dispatchGroup.enter()
        let task = directions.calculate(options) { (waypoints, routes, error) in
            guard error == nil else {
                print("Error calculating directions: \(error!)")
                return
            }

            if let route = routes?.first, let leg = route.legs.first {
                
                let distanceFormatter = LengthFormatter()
                let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
                
                let travelTimeFormatter = DateComponentsFormatter()
                travelTimeFormatter.unitsStyle = .short
                let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
                
                var routeCoordinates = route.coordinates!
                let routeLine = MKPolyline(coordinates: &routeCoordinates, count: Int(route.coordinateCount))
                self.mapView.addOverlay(routeLine)
                self.overlayList.append(routeLine)
                
                let destcoordinate = CLLocationCoordinate2D(latitude: self.SortedAPIData[self.selectedInx].location.coordinate.latitude, longitude: self.SortedAPIData[self.selectedInx].location.coordinate.longitude)
                let destLocation = CLLocation(coordinate: destcoordinate, altitude: self.altitude)
                let destAnnotationNode = LocationAnnotationNode(location: destLocation, image: self.destImage!)
                destAnnotationNode.scaleRelativeToDistance = true
                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: destAnnotationNode)
                self.destAnnotationList = destAnnotationNode

                for i in 1...leg.steps.count - 1 {
                    
                    let coordinate = CLLocationCoordinate2D(latitude: (leg.steps[i].coordinates?.first?.latitude)!, longitude: (leg.steps[i].coordinates?.first?.longitude)!)
                    
                    let location = CLLocation(coordinate: coordinate, altitude: self.altitude)
                    
                    if leg.steps[i].instructions.contains("Turn right"){
                        
                        let annotationNode = LocationAnnotationNode(location: location, image: self.rightIimage!)
                        
                        annotationNode.scaleRelativeToDistance = true
                        
                        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                        self.annotationsList.append(annotationNode)

                    }else if leg.steps[i].instructions.contains("Turn left"){
                        
                        let annotationNode = LocationAnnotationNode(location: location, image: self.leftImage!)
                        
                        annotationNode.scaleRelativeToDistance = true
                        
                        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                        self.annotationsList.append(annotationNode)
                    }
                    
                }
                self.blackV.removeFromSuperview()
                self.dispatchGroup.leave()
            }
        }
    }
    
    func MultipleWayToDest(waypoints: [Waypoint]){
        locationManager.startUpdatingLocation()
        if destAnnotationList != nil{
            self.sceneLocationView.removeLocationNode(locationNode: destAnnotationList!)
            destAnnotationList = nil
        }
        if annotationsList != nil{
            for i in 0...annotationsList.count - 1{
                self.sceneLocationView.removeLocationNode(locationNode: annotationsList[i])
            }
            self.annotationsList.removeAll()
        }
        
        mapView.removeOverlays(overlayList)

        let options = RouteOptions(waypoints: waypoints, profileIdentifier: MBDirectionsProfileIdentifier.walking)
        options.includesSteps = true
        options.includesAlternativeRoutes = true
        
        dispatchGroup.enter()
        let task = directions.calculate(options) { (waypoints, routes, error) in
            guard error == nil else {
                print("Error calculating directions: \(error!)")
                return
            }
            
            if let route = routes?.first, let leg = route.legs.first {
                
                let distanceFormatter = LengthFormatter()
                let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
                
                let travelTimeFormatter = DateComponentsFormatter()
                travelTimeFormatter.unitsStyle = .short
                let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
                
                var routeCoordinates = route.coordinates!
                let routeLine = MKPolyline(coordinates: &routeCoordinates, count: Int(route.coordinateCount))
                self.mapView.addOverlay(routeLine)
                self.overlayList.append(routeLine)
                
                let destcoordinate = CLLocationCoordinate2D(latitude: self.SortedAPIData[self.selectedInx].location.coordinate.latitude, longitude: self.SortedAPIData[self.selectedInx].location.coordinate.longitude)
                let destLocation = CLLocation(coordinate: destcoordinate, altitude: self.altitude)
                let destAnnotationNode = LocationAnnotationNode(location: destLocation, image: self.destImage!)
                destAnnotationNode.scaleRelativeToDistance = true
                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: destAnnotationNode)
                self.destAnnotationList = destAnnotationNode
                
                for i in 1...leg.steps.count - 1 {
                    
                    let coordinate = CLLocationCoordinate2D(latitude: (leg.steps[i].coordinates?.first?.latitude)!, longitude: (leg.steps[i].coordinates?.first?.longitude)!)
                    
                    let location = CLLocation(coordinate: coordinate, altitude: self.altitude)

                    if leg.steps[i].instructions.contains("Turn right"){
                        let annotationNode = LocationAnnotationNode(location: location, image: self.rightIimage!)
                        
                        annotationNode.scaleRelativeToDistance = true
                        
                        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                        self.annotationsList.append(annotationNode)
                    }else if leg.steps[i].instructions.contains("Turn left"){
                        let annotationNode = LocationAnnotationNode(location: location, image: self.leftImage!)
                        
                        annotationNode.scaleRelativeToDistance = true
                        
                        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                        self.annotationsList.append(annotationNode)
                    }
                    
                }
                self.blackV.removeFromSuperview()
                self.dispatchGroup.leave()
            }
        }
    }
    
    
    
    func addRadiusCircle(location: CLLocation){
        let circle = MKCircle(center: location.coordinate, radius: 50)
        
        self.mapView.addOverlay(circle)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if multiRouteBool == true{
            
             centerImg.isHidden = false
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if animated != true{
            if multiRouteBool == true{
                centerImg.isHidden = true
                
            }
        }
    }

    
    func mapView(_ mapView: MKMapView, rendererFor
        overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline{
            let renderer = MKPolylineRenderer(overlay: overlay)
            
            renderer.strokeColor = UIColor.black
            renderer.lineWidth = 2.0
            return renderer
        }else if overlay is MKCircle{
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.05)
            circle.lineWidth = 1
            return circle
        }else{
            return MKPolylineRenderer()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last!
        
        let center = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        self.mapView.setRegion(region, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            self.mapView.setRegion(region, animated: true)
            self.trackMode = true
        })

        locationManager.stopUpdatingLocation()
    }
}

//
//  MapViewController.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import UIKit
import MapKit
import SwiftyUserDefaults

class MapViewController: UIViewController {
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var keyboardConstraint: NSLayoutConstraint!
    @IBOutlet private var moodFilterView: MoodFilterView!
    
    private lazy var keyboardNotifier = KeyboardNotifier(parentView: view, constraint: keyboardConstraint, isAnchor: true)
    private var posts = Defaults[\.posts] {
        didSet {
            Defaults[\.posts] = posts
            filterUpdated()
        }
    }
    private lazy var filteredPosts = posts {
        didSet {
            updateMap()
        }
    }
    private var topics: [Topic] = Topic.allCases {
        didSet {
            updateCollectionView(oldValue: oldValue)
        }
    }
    private var _selectedTopic: Topic?
    private var selectedTopic: Topic? {
        get { _selectedTopic }
        set {
            _selectedTopic = newValue
            filterUpdated()
        }
    }
    private var topicsFilter = "" {
        didSet {
            filterUpdated()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupCollectionView()
        
        _ = { (clear: Bool) in
            if clear {
                posts = []
            } else {
                updateMap()
            }
        }(false)
        
        moodFilterView.selectedMoodChanged = { [weak self] _ in self?.filterUpdated() }
        keyboardNotifier.enabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.delegate = nil
    }
    
    private func isDimmed(at indexPath: IndexPath) -> Bool {
        selectedTopic == nil ? false : selectedTopic != topics[indexPath.item]
    }
    
    private func filterUpdated() {
        var topics = Topic.allCases
        var filteredPosts = posts
        defer {
            self.topics = topics
            self.filteredPosts = filteredPosts
        }
        if let selectedMood = moodFilterView.selectedMood {
            topics = topics.filter { $0.mood == selectedMood }
            filteredPosts = posts.filter { $0.topic.mood == selectedMood }
        }
        if !topicsFilter.isEmpty {
            topics = topics.filter { $0.title.contains(topicsFilter) }
        }
        guard let selectedTopic = selectedTopic else { return }
        guard topics.contains(selectedTopic) else {
            _selectedTopic = nil
            return
        }
        filteredPosts = filteredPosts.filter { $0.topic == selectedTopic }
    }
    
    private func setupMapView() {
        mapView.register(PostAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(PostAnnotationView.self))
        mapView.userTrackingMode = .follow
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
    }
    
    private func setupCollectionView() {
        collectionView.showsHorizontalScrollIndicator = false
        let itemWidth = (UIScreen.main.bounds.width / 4.7).roundedScreenScaled
        let itemHeight = itemWidth + 16
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
            .itemSize = CGSize(width: itemWidth, height: itemHeight)
        collectionViewHeightConstraint.constant = itemHeight
    }
    
    private func updateCollectionView(oldValue: [Topic]) {
        let diff = topics.difference(from: oldValue)
        var deletedIndexPaths = [IndexPath]()
        var insertedIndexPaths = [IndexPath]()
        for change in diff {
            switch change {
            case let .remove(offset, _, _):
                deletedIndexPaths.append(IndexPath(row: offset, section: 0))
            case let .insert(offset, _, _):
                insertedIndexPaths.append(IndexPath(row: offset, section: 0))
            }
        }
        
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: deletedIndexPaths)
            collectionView.insertItems(at: insertedIndexPaths)
        })
    }
    
    private var annotations = [MKAnnotation]() {
        didSet {
            mapView.removeAnnotations(oldValue)
            mapView.addAnnotations(annotations)
        }
    }
    
    private func updateMap() {
        annotations = filteredPosts.map(PostAnnotation.init))
        
        
        print(mapView.annotations)
    }
}

extension MapViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTopic.setIfNotSame(newValue: topics[indexPath.row])
        UIView.animate(withDuration: 0.3) {
            self.collectionView.indexPathsForVisibleItems.forEach { indexPath in
                (self.collectionView.cellForItem(at: indexPath) as? TopicCell)?
                    .dimmed = self.isDimmed(at: indexPath)
            }
        }
    }
}

extension MapViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int
    {
        topics.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopicCell", for: indexPath) as! TopicCell
        cell.topic = topics[indexPath.item]
        cell.dimmed = isDimmed(at: indexPath)
        return cell
    }
}

extension MapViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        topicsFilter = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let rect = mapView.visibleMapRect
        let rectCount = posts.filter({ rect.contains(.init($0.location)) }).count
        guard rectCount < 10 else { return }
        (0..<10 - rectCount).forEach { _ in
            let location = MKMapPoint(
                x: rect.minX + rect.width * .random(in: 0...1),
                y: rect.minY + rect.height * .random(in: 0...1)
            )
            posts.append(Post(topic: Topic.allCases.randomElement()!,
                              location: location.coordinate))
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PostAnnotation else { return nil }
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: NSStringFromClass(PostAnnotationView.self),
            for: annotation
        ) as! PostAnnotationView
        let image = annotation.post.topic.emoji.image
        view.image = image
        return view
    }
}

extension Optional where Wrapped: Equatable {
    fileprivate mutating func setIfNotSame(newValue: Wrapped) {
        if case .some(let value) = self, value == newValue {
            self = nil
        } else {
            self = newValue
        }
    }
}

extension String {
    var image: UIImage? {
        let size = CGSize(width: 80, height: 80)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 60)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

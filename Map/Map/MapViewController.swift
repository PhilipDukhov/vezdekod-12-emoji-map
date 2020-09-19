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
            guard filteredPosts != oldValue else { return }
            setNeedsUpdateMap()
        }
    }
    private var topics: [Topic] = Topic.allCases {
        didSet {
            guard oldValue != topics else { return }
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
                setNeedsUpdateMap()
            }
        }(false)
        
        moodFilterView.selectedMoodChanged = { [weak self] _ in self?.filterUpdated() }
        keyboardNotifier.enabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        mapView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.delegate = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.title = (sender as! PostAnnotation).post.topic.title
    }
    
    @IBAction private func closeButtonTap() {
        navigationController?.dismiss(animated: true)
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
        mapView.register(PostAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
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
    
    private var annotations = [PostAnnotation]() {
        didSet {
            let diff = annotations.difference(from: oldValue) { $0.post == $1.post }
            var removed = [PostAnnotation]()
            var added = [PostAnnotation]()
            for change in diff {
                switch change {
                case let .remove(_, element, _):
                    removed.append(element)
                case let .insert(_, element, _):
                    added.append(element)
                }
            }
            
            mapView.removeAnnotations(removed)
            mapView.addAnnotations(added)
        }
    }
    
    private var computingNeeded = false
    private var computing = false
    private func setNeedsUpdateMap() {
        guard !computingNeeded else { return }
        if computing {
            computingNeeded = true
        } else {
            let visibleMapRect = mapView.visibleMapRect
            backgroundQueue.async {
                self.updateMap(visibleMapRect: visibleMapRect)
            }
        }
    }
    
    var overlays = [MKPolyline]() {
        didSet {
            mapView.removeOverlays(oldValue)
            mapView.addOverlays(overlays)
        }
    }
    
    private func updateMap(visibleMapRect: MKMapRect) {
        computingNeeded = false
        computing = true
        let clusterRects = visibleMapRect.clusterRects
        let overlays = true ? [] :
            clusterRects
            .map { rect -> MKMapRect in
                let inset = min(rect.width / 70, rect.height / 70)
                return rect.insetBy(dx: inset, dy: inset)
            }
            .map { MKPolyline([
                MKMapPoint(x: $0.minX, y: $0.minY),
                MKMapPoint(x: $0.maxX, y: $0.minY),
                MKMapPoint(x: $0.maxX, y: $0.maxY),
                MKMapPoint(x: $0.minX, y: $0.maxY),
                MKMapPoint(x: $0.minX, y: $0.minY),
            ] + $0.threeCirclePoints)
        }
        let newAnnotations = filteredPosts
            .reduce(into: [Int: [Post]]()) { result, post in
                guard let rectIndex = clusterRects.firstIndex(where: { $0.contains(post.mapPoint) }) else { return }
                result[rectIndex, default: []].append(post)
            }.reduce(into: [Post]()) { result, clusterPosts in
                var rectPoints = clusterRects[clusterPosts.key].threeCirclePoints
                guard clusterPosts.value.count > 7 else {
                    result += clusterPosts.value
                    return
                }
                let top = clusterPosts.value.reduce(into: [Topic: [MKMapPoint]]()) { result, post in
                    result[post.topic, default: []].append(post.mapPoint)
                }.sorted { $0.value.count > $1.value.count }
                if top.count == 1 {
                    result += clusterPosts.value.prefix(7)
                    return
                }
                result += top
                    .prefix(3)
                    .map { key, value in
                    (topic: key,
                     location: value.reduce(into: MKMapPoint()) {
                        $0.x += $1.x / Double(value.count)
                        $0.y += $1.y / Double(value.count)
                     },
                     clusterCount: value.count
                    )
                }.map { info -> Post in
                    let index = rectPoints
                        .enumerated()
                        .map {
                            (diff: $0.element.x - info.location.x + $0.element.y - info.location.y,
                             index: $0.offset)
                        }.max { $0.diff < $1.diff }!
                        .index
                    return Post(
                        topic: info.topic,
                        location: rectPoints.remove(at: index).coordinate,
                        clusterCount: info.clusterCount
                    )
                }
            }
//            .print { "result \($0.count)" }
            .map(PostAnnotation.init)
        computing = false
        DispatchQueue.main.async {
            if self.computingNeeded {
                self.computingNeeded = false
                self.setNeedsUpdateMap()
            } else {
                self.annotations = newAnnotations
                self.overlays = overlays
            }
        }
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

private let backgroundQueue = DispatchQueue(label: "backgroundQueue", qos: .utility)
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        defer {
            setNeedsUpdateMap()
        }
        let rect = mapView.visibleMapRect
        let rectCount = posts.filter({ rect.contains(.init($0.location)) }).count
        let neededCount = Int(rect.width / 1500) - rectCount
        guard neededCount > 0 else { return }
        let generator: () -> [Post] = {
            (0..<neededCount).map { _ in
                Post(topic: Topic.allCases.randomElement()!,
                     location: MKMapPoint(
                        x: rect.minX + rect.width * .random(in: 0...1),
                        y: rect.minY + rect.height * .random(in: 0...1)
                     ).coordinate)
            }
        }
        if neededCount > 10 {
            backgroundQueue.async {
                let newPosts = generator()
                DispatchQueue.main.async {
                    self.posts += newPosts
                }
            }
        } else {
            posts += generator()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PostAnnotation else { return nil }
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: NSStringFromClass(PostAnnotationView.self),
            for: annotation
        ) as! PostAnnotationView
        view.action = { [weak self] in
            self?.performSegue(withIdentifier: "show", sender: annotation)
            self?.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3
        renderer.strokeColor = Asset.Colors.blue.color
        return renderer
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

extension Collection {
    func print(block: (Self) -> String) -> Self {
        Swift.print(block(self))
        return self
    }
}

extension MKPolyline {
    convenience init(_ points: [MKMapPoint]) {
        self.init(points: points, count: points.count)
    }
}

extension MKMapRect {
    var clusterRects: [MKMapRect] {
        let clusterSize = MKMapSize(width: width * 0.5, height: width * 0.7)
        let verticalCount = Int(height / clusterSize.height) / 2 * 2 + 3
        let horizontalCount = 3
        return (0..<horizontalCount)
            .reduce(into: [MKMapPoint]()) { result, x in
                result += (0..<verticalCount).map { y in
                    MKMapPoint(
                        x: midX - clusterSize.width * Double(horizontalCount - 2 * x) / 2,
                        y: midY - clusterSize.height * Double(verticalCount - 2 * y) / 2
                    )
                }
            } .map { MKMapRect(origin: $0, size: clusterSize) }
        
    }
    
    var threeCirclePoints: [MKMapPoint] {
        if width != height {
            return middleSquare.threeCirclePoints
        }
        let r = width / 3.93185165258
        let p = 1.52 * r
        return [
            MKMapPoint(x: minX + r, y: minY + r),
            MKMapPoint(x: maxX - r, y: minY + p),
            MKMapPoint(x: minX + p, y: maxY - r),
        ]
    }
    
    var middleSquare: MKMapRect {
        if width > height {
            return insetBy(dx: (width - height) / 2, dy: 0)
        }
        return insetBy(dx: 0, dy: (height - width) / 2)
    }
}

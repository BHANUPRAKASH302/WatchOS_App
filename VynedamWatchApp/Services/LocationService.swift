import Foundation
import CoreLocation

class LocationService: ObservableObject {
    @Published var currentCoordinate = CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090) // New Delhi
    @Published var nearestHospitals: [Hospital] = []
    @Published var safeRoutes: [Route] = []
    @Published var boundaryPoints: [CLLocationCoordinate2D] = []
    @Published var isSharingLiveLocation: Bool = false
    
    struct Hospital: Identifiable {
        let id = UUID()
        let name: String
        let distance: String
        let coordinate: CLLocationCoordinate2D
    }
    
    struct Route: Identifiable {
        let id = UUID()
        let name: String
        let safetyRating: Double // 1 to 5
        let durationMin: Int
    }
    
    init() {
        nearestHospitals = [
            Hospital(name: "City General Hospital", distance: "0.8 km", coordinate: CLLocationCoordinate2D(latitude: 28.6145, longitude: 77.2075)),
            Hospital(name: "Saint Jude Care Center", distance: "2.3 km", coordinate: CLLocationCoordinate2D(latitude: 28.6105, longitude: 77.2150)),
            Hospital(name: "LifeLine Trauma Ward", distance: "4.1 km", coordinate: CLLocationCoordinate2D(latitude: 28.6210, longitude: 77.1990))
        ]
        
        safeRoutes = [
            Route(name: "Via Parliament St (Well-lit)", safetyRating: 4.8, durationMin: 12),
            Route(name: "Via Janpath Rd (Active CCTV)", safetyRating: 4.6, durationMin: 15),
            Route(name: "Via Connaught Cir (Patrolled)", safetyRating: 4.9, durationMin: 18)
        ]
        
        // Farm boundaries
        boundaryPoints = [
            CLLocationCoordinate2D(latitude: 28.6130, longitude: 77.2080),
            CLLocationCoordinate2D(latitude: 28.6150, longitude: 77.2080),
            CLLocationCoordinate2D(latitude: 28.6150, longitude: 77.2100),
            CLLocationCoordinate2D(latitude: 28.6130, longitude: 77.2100)
        ]
        
        startLocationUpdates()
    }
    
    func startLocationUpdates() {
        // Mock slight GPS movement
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let latOffset = Double.random(in: -0.0002...0.0002)
            let lonOffset = Double.random(in: -0.0002...0.0002)
            self.currentCoordinate = CLLocationCoordinate2D(
                latitude: self.currentCoordinate.latitude + latOffset,
                longitude: self.currentCoordinate.longitude + lonOffset
            )
        }
    }
    
    func toggleLiveLocationSharing() {
        isSharingLiveLocation.toggle()
    }
}

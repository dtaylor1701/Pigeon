import Foundation

struct Pokemon: Codable {
    let id: Int
    let name: String
    let height: Double
    let weight: Double
    let species: Species
    let abilities: [AbilityContainer]
}

struct Species: Codable {
    let name: String
    let url: URL
}

struct AbilityContainer: Codable {
    let ability: Ability
    let isHidden: Bool
}

struct Ability: Codable {
    let name: String
    let url: URL
}

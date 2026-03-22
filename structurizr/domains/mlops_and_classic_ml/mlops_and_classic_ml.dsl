// Forges of Middle-earth

// Systems
group "Forges of Middle-earth" {
    // Magical artifacts forged in the fortress
    rings_of_power = softwareSystem "Rings of Power" "Magical artifacts in the fortress"
    elven_blades = softwareSystem "Elven Blades" "Artifacts available to all free peoples"

    // Seers
    lorien_seers = softwareSystem "Seers of Lorien"
}

swift_messengers = softwareSystem "Swift Messengers" "Urgent delivery of prophecies" "External"

// System relationships
eye_of_sauron -> rings_of_power "Routes requests to the Rings" "REST/HTTPS"
eye_of_sauron -> istari "Routes requests to the Istari" "REST/HTTPS"

lorien_seers -> mines_of_moria "Mine ore in the Mines" "TCP"
lorien_seers -> erebor_treasury "Mine ore in the Treasury" "TCP"
lorien_seers -> swift_messengers "Send prophecies to Messengers" "Kafka"

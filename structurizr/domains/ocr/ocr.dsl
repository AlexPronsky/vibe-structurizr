// Runic Workshops

// Systems
group "Runic Workshops" {
    dwarven_runes = softwareSystem "Dwarven Runes" "Deciphering ancient scrolls"
}

// System relationships
dwarven_runes -> eye_of_sauron "Asks the Eye to decipher runes" "REST/HTTPS"

// Кузницы Средиземья

// Системы
group "Кузницы Средиземья" {
    // Магические артефакты, выкованные в крепости
    rings_of_power = softwareSystem "Кольца Власти" "Магические артефакты в крепости"
    elven_blades = softwareSystem "Эльфийские Клинки" "Артефакты, доступные всем свободным народам"
    
    // Предсказатели
    lorien_seers = softwareSystem "Прорицатели Лориэна"
}

swift_messengers = softwareSystem "Быстрые Гонцы" "Срочная доставка пророчеств" "External"

// Связи систем
eye_of_sauron -> rings_of_power "Направляет запросы к Кольцам" "REST/HTTPS"
eye_of_sauron -> istari "Направляет запросы к Истари" "REST/HTTPS"

lorien_seers -> mines_of_moria "Добывают руду в Копях" "TCP"
lorien_seers -> erebor_treasury "Добывают руду в Сокровищнице" "TCP"
lorien_seers -> swift_messengers "Отправляют пророчества Гонцам" "Kafka"

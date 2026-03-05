// Рунические Мастерские

// Системы
group "Рунические Мастерские" {
    dwarven_runes = softwareSystem "Руны Гномов" "Расшифровка древних свитков"
}

// Связи систем
dwarven_runes -> eye_of_sauron "Просит Око расшифровать руны" "REST/HTTPS"

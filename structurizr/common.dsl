// Общие элементы Средиземья

// Народы
hobbits = person "Хоббиты Шира" "" "External"
rangers = person "Следопыты Севера"

// Общие системы
minas_tirith_library = softwareSystem "Библиотека Минас Тирита" "" "External"
rivendell_archives = softwareSystem "Архивы Ривенделла" "" "External"
task_palantir = softwareSystem "Палантир Задач" "" "External"

gondor_beacons = softwareSystem "Огни Гондора" "Сигнальная система" "External"
eye_of_sauron = softwareSystem "Око Саурона" "Всевидящий шлюз магии" "External"
istari = softwareSystem "Истари" "Маги за Морем, доступные через палантиры" "External"

group "Подземные Хранилища" {
    mines_of_moria = softwareSystem "Копи Мории" "Древнее хранилище гномов (legacy)" "External"
    erebor_treasury = softwareSystem "Сокровищница Эребора" "Хранилище Подгорного Королевства" "External"
}

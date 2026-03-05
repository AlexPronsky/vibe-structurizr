// Братство Кольца

// Системы
white_tower = softwareSystem "Белая Башня" "Главный зал общения с магами"
winds_of_manwe = softwareSystem "Ветра Манвэ" "Потоки поручений от Валар" "External"

group "Братство Кольца" {
    radagast = softwareSystem "Радагаст-Аналитик" "Мольбы в Копи и Сокровищницу на языке смертных"
    bards_of_rohan = softwareSystem "Барды Рохана"
    citadel_guards = softwareSystem "Стражи Цитадели"
    smiths_of_rivendell = softwareSystem "Кузнецы Ривенделла"
}

group "Палантиры" {
    bree_crossroads = softwareSystem "Перекрёсток Бри" "Узловая станция Средиземья"
}

distant_lands_news = softwareSystem "Вести из Дальних Земель" "" "External"
bree_notice_board = softwareSystem "Доска Объявлений Бри" "" "External"

// Связи систем
rangers -> white_tower "Обращаются к магам Башни" "HTTPS"
white_tower -> radagast "Передаёт мольбы Радагасту" "REST/HTTPS"
white_tower -> bree_crossroads "Запрашивает свитки через Перекрёсток" "MCP/HTTPS"

winds_of_manwe -> citadel_guards "Призывает Стражей" "REST/HTTPS"

radagast -> eye_of_sauron "Обращается к Оку за заклинаниями" "REST/HTTPS"
radagast -> mines_of_moria "Спускается в Копи" "TCP"
radagast -> erebor_treasury "Входит в Сокровищницу" "TCP"

bards_of_rohan -> bree_notice_board "Вывешивает вести на Доску" "REST/HTTPS"
bards_of_rohan -> eye_of_sauron "Просит Око пересказать кратко и по делу" "REST/HTTPS"
bards_of_rohan -> distant_lands_news "Собирает вести" "HTTPS"
citadel_guards -> eye_of_sauron "Обращается к Оку" "REST/HTTPS"
smiths_of_rivendell -> eye_of_sauron "Обращается к Оку" "REST/HTTPS"

bree_crossroads -> minas_tirith_library "Читает свитки из Библиотеки" "REST/HTTPS"



!element bree_crossroads {
    group "Цитадель Минас Тирита" {
        // Контейнеры
        knowledge_palantir = container "Палантир Знаний" "Связь с Библиотекой Минас Тирита" "Java"
    }
	
	// Связи контейнеров
	white_tower -> knowledge_palantir "Запрашивает свитки" "MCP/HTTPS"
    knowledge_palantir -> minas_tirith_library "Читает из Библиотеки" "REST/HTTPS"

	// Инфопотоки
	knowledge_palantir -> white_tower "INF01. Свитки из Библиотеки" "" "Dataflow"
    minas_tirith_library -> knowledge_palantir "INF02. Свитки из Библиотеки" "" "Dataflow"
}

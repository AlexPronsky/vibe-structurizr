// Совет Мудрых

// Системы
prancing_pony = softwareSystem "Трактир «Гарцующий Пони»" "Пристанище путников" "External"
green_dragon = softwareSystem "Трактир «Зелёный Дракон»" "Пристанище путников" "External"

gates_of_moria = softwareSystem "Врата Мории" "Привратник входящих посланий" "External"
council_of_elrond = softwareSystem "Совет Элронда" "Разрешение проблем" "External"
seeing_stone = softwareSystem "Палантир Связи" "Дальновидение и дальнослышание" "External"

group "Совет Мудрых" {
    ent_advisors = softwareSystem "Энты-Советники" "Мудрые создания, отвечающие на вопросы"
    elrond_healer = softwareSystem "Целитель Элронд" "Исцеление и поддержка"
    bilbo_chronicler = softwareSystem "Летописец Бильбо" "Летопись и толкование речей совета"
}

mirror_of_galadriel = softwareSystem "Зеркало Галадриэль" "Кладезь мудрости Средиземья"

shire_chronicles = softwareSystem "Летопись Шира" "Хроники деяний хоббитов" "External"
eagles_of_manwe = softwareSystem "Орлы Манвэ" "Воздушная доставка свитков" "External"
noldor_forges = softwareSystem "Кузницы Нолдор" "" "External"
chronicle_bot = softwareSystem "Перо-Самописец" "" "External"
gandalf = softwareSystem "Гэндальф-Координатор" "" "External"

// Связи систем
rangers -> gondor_beacons "Зажигают сигнальные огни" "HTTPS"
gondor_beacons -> gates_of_moria "Передаёт мольбы путников" "REST/HTTPS"

rangers -> task_palantir "Записывают задачи в Палантир" "HTTPS"
gandalf -> task_palantir "Разбирает задачи из Палантира" "HTTPS"
gandalf -> ent_advisors "Передаёт вопросы Энтам" "REST/HTTPS"

hobbits -> prancing_pony "Заходят в трактир" "HTTPS"
hobbits -> green_dragon "Заходят в трактир" "HTTPS"
prancing_pony -> gates_of_moria "Передаёт мольбы путников" "REST/HTTPS"
green_dragon -> gates_of_moria "Передаёт мольбы путников" "REST/HTTPS"

gates_of_moria -> ent_advisors "Передаёт мольбы путников" "REST/HTTPS"
ent_advisors -> mirror_of_galadriel "Заглядывает в Зеркало" "REST/HTTPS"
ent_advisors -> eye_of_sauron "Обращается к Оку" "REST/HTTPS"
ent_advisors -> shire_chronicles "Запрашивает хроники" "REST/HTTPS"

noldor_forges -> eagles_of_manwe "Отправляет свитки с Орлами" "kafka"
eagles_of_manwe -> ent_advisors "Доставляет свитки Энтам" "kafka"

council_of_elrond -> elrond_healer "Направляет страждущих" "REST/HTTPS"
elrond_healer -> eye_of_sauron "Обращается к Оку" "REST/HTTPS"

seeing_stone -> bilbo_chronicler "Передаёт речи совета" "REST/HTTPS"
bilbo_chronicler -> eye_of_sauron "Обращается к Оку" "REST/HTTPS"
bilbo_chronicler -> chronicle_bot "Передаёт свитки"

ent_advisors -> elven_blades "Берёт Эльфийский Клинок" "HTTPS"

mirror_of_galadriel -> minas_tirith_library "Загружает свитки из Библиотеки" "HTTPS"
mirror_of_galadriel -> rivendell_archives "Загружает свитки из Архивов" "HTTPS"

// Контейнеры Энтов-Советников
!element ent_advisors {
	// Контейнеры
	group "Цитадель Минас Тирита" {
		ent_core = container "Энты-Советники" "Совет мудрых энтов" "Python"
        khazad_dum_bridge = container "Мост Казад-Дума" "Посредник между мирами" "Java"
        anduin_crossing = container "Переправа через Андуин" "Переправа древних свитков" "Kafka Connect" "NotInProd"
		anduin_cache = container "Тайник у Андуина" "Схрон переправленных свитков" "PostgreSQL" "DB,NotInProd"
        anduin_stream = container "Течение Андуина" "Русло свитков" "Kafka" "Pipe,NotInProd"
	}
	
	// Связи контейнеров
    gates_of_moria -> ent_core "Передаёт мольбы путников" "REST/HTTPS"
    gandalf -> ent_core "Передаёт вопросы от Гэндальфа" "REST/HTTPS"

	ent_core -> mirror_of_galadriel "Заглядывает в Зеркало" "REST/HTTPS"
    ent_core -> eye_of_sauron "Обращается к Оку" "REST/HTTPS"
    ent_core -> khazad_dum_bridge "Переходит через Мост" "REST/HTTPS"
    khazad_dum_bridge -> shire_chronicles "Запрашивает хроники" "REST/HTTPS"
    khazad_dum_bridge -> anduin_crossing "Запрашивает свитки с Переправы" "REST/HTTPS"
    
    eagles_of_manwe -> anduin_stream "Орлы сбрасывают свитки в Течение" "TCP"
    anduin_crossing -> anduin_stream "Читает из Течения" "TCP"
    anduin_crossing -> anduin_cache "Прячет и достаёт из Тайника" "TCP"

    // Инфопотоки
    ent_core -> gates_of_moria "INF01. Ответы на мольбы путников" "" "Dataflow"
    ent_core -> gandalf "INF02. Ответы на вопросы Гэндальфа" "" "Dataflow"
    mirror_of_galadriel -> ent_core "INF03. Знания Средиземья" "" "Dataflow"
    eye_of_sauron -> ent_core "INF04. Ответы мудрости Ока" "" "Dataflow"
    khazad_dum_bridge -> ent_core "INF05. Свитки хроник" "" "Dataflow"
    shire_chronicles -> khazad_dum_bridge "INF06. Хроники деяний хоббитов" "" "Dataflow"
    eagles_of_manwe -> anduin_stream "INF07. Свитки из Кузниц Нолдор" "" "Dataflow"
    anduin_stream -> anduin_crossing "INF08. Свитки из Русла" "" "Dataflow"
    anduin_cache -> anduin_crossing "INF09. Свитки из Тайника" "" "Dataflow"
    anduin_crossing -> khazad_dum_bridge "INF10. Переправленные свитки" "" "Dataflow"
}

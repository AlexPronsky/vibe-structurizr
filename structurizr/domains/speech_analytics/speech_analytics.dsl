// Слухачи

// Системы
helms_deep = softwareSystem "Хельмова Падь" "" "External"

group "Слухачи" {
	aragorn_palantir = softwareSystem "Палантир Арагорна" "Всевидящее толкование речей"
	isengard_listeners = softwareSystem "Слухачи Изенгарда" "Ловцы речей Средиземья"
}

// Связи систем
helms_deep -> aragorn_palantir "Запрашивает разведданные" "REST/HTTPS"
aragorn_palantir -> isengard_listeners "Забирает расшифровки из потока" "Kafka"
aragorn_palantir -> eye_of_sauron "Просит Око истолковать" "REST/HTTPS"

// Контейнеры Палантира Арагорна
!element aragorn_palantir {
	// Контейнеры
	group "Цитадель Минас Тирита" {
		aragorn = container "Арагорн" "Координатор" "Java"
		moria_vault = container "Хранилище Мории" "БД" "PostgreSQL" "DB"
		ravens = container "Почтовые Вороны" "Очередь посланий" "RabbitMQ" "Pipe"
		dwarf_miner = container "Гном-Рудокоп" "Рабочий" "Python"
	}
	
	// Связи контейнеров
	aragorn -> isengard_listeners "Забирает расшифровки из потока" "Kafka"
	aragorn -> moria_vault "Сохраняет в Хранилище" "TCP"
	aragorn -> ravens  "Отправляет Воронов с заданиями" "AMQP"
	ravens -> dwarf_miner "Передаёт задания Гному" "AMQP"
	ravens -> aragorn "Возвращает результаты Арагорну" "AMQP"
	dwarf_miner -> eye_of_sauron "Обращается к Оку" "REST/HTTPS"
	dwarf_miner -> ravens "Отдаёт результаты Воронам" "AMQP"
	helms_deep -> aragorn "Запрашивает разведданные" "REST/HTTPS"

	// Инфопотоки
	isengard_listeners -> aragorn "INF01. Расшифровки речей" "" "Dataflow"
	moria_vault -> aragorn "INF02. Расшифровки и толкования Ока" "" "Dataflow"
	aragorn -> ravens "INF03. Задания на обработку" "" "Dataflow"
	ravens -> dwarf_miner "INF04. Задания на обработку" "" "Dataflow"
	eye_of_sauron -> dwarf_miner "INF05. Толкования Ока" "" "Dataflow"
	dwarf_miner -> ravens "INF06. Толкования Ока" "" "Dataflow"
	ravens -> aragorn "INF07. Толкования Ока" "" "Dataflow"
	aragorn -> helms_deep "INF08. Толкования речей" "" "Dataflow"
}

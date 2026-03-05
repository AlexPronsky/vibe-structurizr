// Диаграммы Слухачей

systemContext aragorn_palantir "aragorn_palantir_system" "Палантир Арагорна: обзор" {
    include *
    exclude relationship.tag==Dataflow
}

container aragorn_palantir "aragorn_palantir_containers" "Палантир Арагорна: архитектура" {
    include *
    exclude relationship.tag==Dataflow
}

container aragorn_palantir "aragorn_palantir_dataflow" "Палантир Арагорна: инфопотоки" {
    include *
    exclude relationship.tag!=Dataflow
}

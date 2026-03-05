// Диаграммы Совета Мудрых

systemContext ent_advisors "ent_advisors_system" "Энты-Советники: обзор" {
    include *
    exclude relationship.tag==Dataflow
}

container ent_advisors "ent_advisors_containers" "Энты-Советники: архитектура" {
    include *
    exclude relationship.tag==Dataflow
}

container ent_advisors "ent_advisors_dataflow" "Энты-Советники: инфопотоки" {
    include *
    exclude relationship.tag!=Dataflow
}

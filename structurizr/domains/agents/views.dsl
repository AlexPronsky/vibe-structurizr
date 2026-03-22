systemContext bree_crossroads "bree_crossroads_system" "Перекрёсток Бри: обзор" {
    include *
    exclude relationship.tag==Dataflow
    autoLayout
}

container bree_crossroads "bree_crossroads_containers" "Перекрёсток Бри: архитектура" {
    include *
    exclude relationship.tag==Dataflow
    autoLayout lr
}

container bree_crossroads "bree_crossroads_dataflow" "Перекрёсток Бри: инфопотоки" {
    include *
    exclude relationship.tag!=Dataflow
    autoLayout rl
}


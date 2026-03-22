// Listener diagrams

systemContext aragorn_palantir "aragorn_palantir_system" "Aragorn's Palantir: overview" {
    include *
    exclude relationship.tag==Dataflow
}

container aragorn_palantir "aragorn_palantir_containers" "Aragorn's Palantir: architecture" {
    include *
    exclude relationship.tag==Dataflow
}

container aragorn_palantir "aragorn_palantir_dataflow" "Aragorn's Palantir: data flows" {
    include *
    exclude relationship.tag!=Dataflow
}

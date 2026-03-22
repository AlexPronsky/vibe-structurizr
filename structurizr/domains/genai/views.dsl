// Council of the Wise diagrams

systemContext ent_advisors "ent_advisors_system" "Ent Advisors: overview" {
    include *
    exclude relationship.tag==Dataflow
}

container ent_advisors "ent_advisors_containers" "Ent Advisors: architecture" {
    include *
    exclude relationship.tag==Dataflow
}

container ent_advisors "ent_advisors_dataflow" "Ent Advisors: data flows" {
    include *
    exclude relationship.tag!=Dataflow
}

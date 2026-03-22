systemContext bree_crossroads "bree_crossroads_system" "Crossroads of Bree: overview" {
    include *
    exclude relationship.tag==Dataflow
    autoLayout
}

container bree_crossroads "bree_crossroads_containers" "Crossroads of Bree: architecture" {
    include *
    exclude relationship.tag==Dataflow
    autoLayout lr
}

container bree_crossroads "bree_crossroads_dataflow" "Crossroads of Bree: data flows" {
    include *
    exclude relationship.tag!=Dataflow
    autoLayout rl
}

// Smiths of Rivendell views
systemContext smiths_of_rivendell "smiths_of_rivendell_system" "Smiths of Rivendell: overview" {
    include *
    exclude relationship.tag==Dataflow
    autoLayout
}

container smiths_of_rivendell "smiths_of_rivendell_containers" "Smiths of Rivendell: architecture" {
    include *
    exclude relationship.tag==Dataflow
    exclude "element.type==SoftwareSystem -> element.type==SoftwareSystem"
    autoLayout lr
}

container smiths_of_rivendell "smiths_of_rivendell_dataflow" "Smiths of Rivendell: data flows" {
    include *
    exclude relationship.tag!=Dataflow
    exclude "element.type==SoftwareSystem -> element.type==SoftwareSystem"
    autoLayout rl
}

// Solution 001: Forging Runic Diagrams and Covenant Scrolls — consolidated views
container smiths_of_rivendell "solution_001_containers" "Solution 001: system architecture" {
    include "element.parent==smiths_of_rivendell"
    include "element.parent==bree_crossroads"
    include "->element.parent==smiths_of_rivendell->"
    include "->element.parent==bree_crossroads->"
    exclude relationship.tag==Dataflow
    exclude "element.type==SoftwareSystem -> element.type==SoftwareSystem"
    autoLayout lr
}

container smiths_of_rivendell "solution_001_dataflow" "Solution 001: data flows" {
    include "element.parent==smiths_of_rivendell"
    include "element.parent==bree_crossroads"
    include "->element.parent==smiths_of_rivendell->"
    include "->element.parent==bree_crossroads->"
    exclude relationship.tag!=Dataflow
    exclude "element.type==SoftwareSystem -> element.type==SoftwareSystem"
    autoLayout rl
}


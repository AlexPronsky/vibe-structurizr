// Fellowship of the Ring

// Systems
white_tower = softwareSystem "White Tower" "Main hall for communicating with wizards"
winds_of_manwe = softwareSystem "Winds of Manwe" "Task streams from the Valar" "External"

group "Fellowship of the Ring" {
    radagast = softwareSystem "Radagast the Analyst" "Queries to the Mines and Treasury in the common tongue"
    bards_of_rohan = softwareSystem "Bards of Rohan"
    citadel_guards = softwareSystem "Citadel Guards"
    smiths_of_rivendell = softwareSystem "Smiths of Rivendell"
}

group "Palantiri" {
    bree_crossroads = softwareSystem "Crossroads of Bree" "Central hub of Middle-earth"
}

distant_lands_news = softwareSystem "News from Distant Lands" "" "External"
bree_notice_board = softwareSystem "Bree Notice Board" "" "External"

// System relationships
rangers -> white_tower "Address the wizards of the Tower" "HTTPS"
white_tower -> radagast "Forwards queries to Radagast" "REST/HTTPS"
white_tower -> bree_crossroads "Requests scrolls via Crossroads" "MCP/HTTPS"

winds_of_manwe -> citadel_guards "Summons the Guards" "REST/HTTPS"

radagast -> eye_of_sauron "Seeks spells from the Eye" "REST/HTTPS"
radagast -> mines_of_moria "Descends into the Mines" "TCP"
radagast -> erebor_treasury "Enters the Treasury" "TCP"

bards_of_rohan -> bree_notice_board "Posts news on the Board" "REST/HTTPS"
bards_of_rohan -> eye_of_sauron "Asks the Eye to summarize concisely" "REST/HTTPS"
bards_of_rohan -> distant_lands_news "Gathers news" "HTTPS"
citadel_guards -> eye_of_sauron "Consults the Eye" "REST/HTTPS"
smiths_of_rivendell -> eye_of_sauron "Consults the Eye" "REST/HTTPS"

bree_crossroads -> minas_tirith_library "Reads and publishes scrolls in the Library" "REST/HTTPS" "Changed"
bree_crossroads -> task_palantir "Reads tasks from the Palantir" "REST/HTTPS" "New"

// Solution 001: Forging Runic Diagrams and Covenant Scrolls
white_tower -> smiths_of_rivendell "Forwards requests to Rune Master" "REST/HTTPS" "New"
smiths_of_rivendell -> bree_crossroads "Retrieves content and forges artifacts via Crossroads" "MCP/HTTPS" "New"



!element bree_crossroads {
    group "Citadel of Minas Tirith" {
        // Containers
        knowledge_palantir = container "Knowledge Palantir" "Link to the Library of Minas Tirith and Task Palantir" "Java" "Changed"
        runic_hammer = container "Runic Hammer" "Carrier dove for forging and testing runic diagrams and Covenant Scrolls" "Python" "New"
    }

	// Container relationships
	white_tower -> knowledge_palantir "Requests scrolls" "MCP/HTTPS"
    knowledge_palantir -> minas_tirith_library "Reads from the Library" "REST/HTTPS"
    smiths_of_rivendell -> knowledge_palantir "Retrieves content via Knowledge Palantir" "MCP/HTTPS" "New"
    knowledge_palantir -> task_palantir "Reads tasks from the Palantir" "REST/HTTPS" "New"
    knowledge_palantir -> minas_tirith_library "Publishes scrolls to the Library" "REST/HTTPS" "New"
    smiths_of_rivendell -> runic_hammer "Forges runic diagrams" "MCP/HTTPS" "New"

	// Data flows
	knowledge_palantir -> white_tower "INF01. Scrolls from the Library" "" "Dataflow"
    minas_tirith_library -> knowledge_palantir "INF02. Scrolls from the Library" "" "Dataflow"
    knowledge_palantir -> smiths_of_rivendell "INF03. Content from Knowledge Palantir" "" "Dataflow,New"
    task_palantir -> knowledge_palantir "INF04. Task context from the Palantir" "" "Dataflow,New"
    minas_tirith_library -> knowledge_palantir "INF05. Published scroll links" "" "Dataflow,New"
    runic_hammer -> smiths_of_rivendell "INF06. Forged runic diagrams" "" "Dataflow,New"
}

// Smiths of Rivendell containers
!element smiths_of_rivendell {
    group "Citadel of Minas Tirith" {
        rune_master = container "Rune Master" "Messenger for working with runic diagrams and Covenant Scrolls" "Python" "New"
    }

    // Container relationships
    white_tower -> rune_master "Forwards requests to Rune Master" "REST/HTTPS" "New"
    rune_master -> bree_crossroads "Retrieves content via Knowledge Palantir" "MCP/HTTPS" "New"
    rune_master -> bree_crossroads "Forges diagrams via Runic Hammer" "MCP/HTTPS" "New"
    rune_master -> eye_of_sauron "Invokes Istari for artifact forging" "REST/HTTPS" "New"

    // Data flows
    rune_master -> white_tower "INF01. Response with forged artifacts" "" "Dataflow,New"
    bree_crossroads -> rune_master "INF02. Content from Knowledge Palantir" "" "Dataflow,New"
    bree_crossroads -> rune_master "INF03. Forged runic diagrams from Runic Hammer" "" "Dataflow,New"
    eye_of_sauron -> rune_master "INF04. Forged artifacts from Istari" "" "Dataflow,New"
}

// Cross-system container relationships (for solution views)
smiths_of_rivendell.rune_master -> bree_crossroads.knowledge_palantir "Retrieves content and publishes scrolls" "MCP/HTTPS" "New"
smiths_of_rivendell.rune_master -> bree_crossroads.runic_hammer "Forges and tests runic diagrams" "MCP/HTTPS" "New"

// Cross-system data flows (for solution views)
bree_crossroads.knowledge_palantir -> smiths_of_rivendell.rune_master "INF02. Content and templates from Knowledge Palantir" "" "Dataflow,New"
bree_crossroads.runic_hammer -> smiths_of_rivendell.rune_master "INF03. Forged diagrams from Runic Hammer" "" "Dataflow,New"

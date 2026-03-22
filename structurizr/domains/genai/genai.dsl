// Council of the Wise

// Systems
prancing_pony = softwareSystem "The Prancing Pony Inn" "Travellers' haven" "External"
green_dragon = softwareSystem "The Green Dragon Inn" "Travellers' haven" "External"

gates_of_moria = softwareSystem "Gates of Moria" "Gatekeeper of incoming messages" "External"
council_of_elrond = softwareSystem "Council of Elrond" "Problem resolution" "External"
seeing_stone = softwareSystem "Seeing Stone" "Far-sight and far-hearing" "External"

group "Council of the Wise" {
    ent_advisors = softwareSystem "Ent Advisors" "Wise creatures who answer questions"
    elrond_healer = softwareSystem "Elrond the Healer" "Healing and support"
    bilbo_chronicler = softwareSystem "Bilbo the Chronicler" "Chronicle and interpretation of council speeches"
}

mirror_of_galadriel = softwareSystem "Mirror of Galadriel" "Wellspring of Middle-earth wisdom"

shire_chronicles = softwareSystem "Shire Chronicles" "Chronicles of hobbit deeds" "External"
eagles_of_manwe = softwareSystem "Eagles of Manwe" "Aerial scroll delivery" "External"
noldor_forges = softwareSystem "Noldor Forges" "" "External"
chronicle_bot = softwareSystem "Auto-Quill" "" "External"
gandalf = softwareSystem "Gandalf the Coordinator" "" "External"

// System relationships
rangers -> gondor_beacons "Light the signal beacons" "HTTPS"
gondor_beacons -> gates_of_moria "Forwards travellers' pleas" "REST/HTTPS"

rangers -> task_palantir "Record tasks in the Palantir" "HTTPS"
gandalf -> task_palantir "Retrieves tasks from the Palantir" "HTTPS"
gandalf -> ent_advisors "Forwards questions to the Ents" "REST/HTTPS"

hobbits -> prancing_pony "Visit the inn" "HTTPS"
hobbits -> green_dragon "Visit the inn" "HTTPS"
prancing_pony -> gates_of_moria "Forwards travellers' pleas" "REST/HTTPS"
green_dragon -> gates_of_moria "Forwards travellers' pleas" "REST/HTTPS"

gates_of_moria -> ent_advisors "Forwards travellers' pleas" "REST/HTTPS"
ent_advisors -> mirror_of_galadriel "Gazes into the Mirror" "REST/HTTPS"
ent_advisors -> eye_of_sauron "Consults the Eye" "REST/HTTPS"
ent_advisors -> shire_chronicles "Requests chronicles" "REST/HTTPS"

noldor_forges -> eagles_of_manwe "Sends scrolls with the Eagles" "kafka"
eagles_of_manwe -> ent_advisors "Delivers scrolls to the Ents" "kafka"

council_of_elrond -> elrond_healer "Refers those in need" "REST/HTTPS"
elrond_healer -> eye_of_sauron "Consults the Eye" "REST/HTTPS"

seeing_stone -> bilbo_chronicler "Transmits council speeches" "REST/HTTPS"
bilbo_chronicler -> eye_of_sauron "Consults the Eye" "REST/HTTPS"
bilbo_chronicler -> chronicle_bot "Delivers scrolls"

ent_advisors -> elven_blades "Takes an Elven Blade" "HTTPS"

mirror_of_galadriel -> rivendell_archives "Loads scrolls from the Archives" "HTTPS"

// Ent Advisors containers
!element ent_advisors {
	// Containers
	group "Citadel of Minas Tirith" {
		ent_core = container "Ent Advisors" "Council of wise ents" "Python"
        khazad_dum_bridge = container "Bridge of Khazad-dum" "Intermediary between worlds" "Java"
        anduin_crossing = container "Anduin Crossing" "Ancient scroll ferry" "Kafka Connect" "NotInProd"
		anduin_cache = container "Anduin Cache" "Cache of ferried scrolls" "PostgreSQL" "DB,NotInProd"
        anduin_stream = container "Anduin Stream" "Scroll channel" "Kafka" "Pipe,NotInProd"
	}

	// Container relationships
    gates_of_moria -> ent_core "Forwards travellers' pleas" "REST/HTTPS"
    gandalf -> ent_core "Forwards questions from Gandalf" "REST/HTTPS"

	ent_core -> mirror_of_galadriel "Gazes into the Mirror" "REST/HTTPS"
    ent_core -> eye_of_sauron "Consults the Eye" "REST/HTTPS"
    ent_core -> khazad_dum_bridge "Crosses the Bridge" "REST/HTTPS"
    khazad_dum_bridge -> shire_chronicles "Requests chronicles" "REST/HTTPS"
    khazad_dum_bridge -> anduin_crossing "Requests scrolls from the Crossing" "REST/HTTPS"

    eagles_of_manwe -> anduin_stream "Eagles drop scrolls into the Stream" "TCP"
    anduin_crossing -> anduin_stream "Reads from the Stream" "TCP"
    anduin_crossing -> anduin_cache "Stores and retrieves from Cache" "TCP"

    // Data flows
    ent_core -> gates_of_moria "INF01. Replies to travellers' pleas" "" "Dataflow"
    ent_core -> gandalf "INF02. Replies to Gandalf's questions" "" "Dataflow"
    mirror_of_galadriel -> ent_core "INF03. Knowledge of Middle-earth" "" "Dataflow"
    eye_of_sauron -> ent_core "INF04. Wisdom from the Eye" "" "Dataflow"
    khazad_dum_bridge -> ent_core "INF05. Chronicle scrolls" "" "Dataflow"
    shire_chronicles -> khazad_dum_bridge "INF06. Chronicles of hobbit deeds" "" "Dataflow"
    eagles_of_manwe -> anduin_stream "INF07. Scrolls from the Noldor Forges" "" "Dataflow"
    anduin_stream -> anduin_crossing "INF08. Scrolls from the Stream" "" "Dataflow"
    anduin_cache -> anduin_crossing "INF09. Scrolls from Cache" "" "Dataflow"
    anduin_crossing -> khazad_dum_bridge "INF10. Ferried scrolls" "" "Dataflow"
}

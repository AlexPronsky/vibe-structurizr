// Listeners

// Systems
helms_deep = softwareSystem "Helm's Deep" "" "External"

group "Listeners" {
	aragorn_palantir = softwareSystem "Aragorn's Palantir" "All-seeing speech interpretation"
	isengard_listeners = softwareSystem "Isengard Listeners" "Speech catchers of Middle-earth"
}

// System relationships
helms_deep -> aragorn_palantir "Requests intelligence" "REST/HTTPS"
aragorn_palantir -> isengard_listeners "Retrieves transcriptions from stream" "Kafka"
aragorn_palantir -> eye_of_sauron "Asks the Eye to interpret" "REST/HTTPS"

// Aragorn's Palantir containers
!element aragorn_palantir {
	// Containers
	group "Citadel of Minas Tirith" {
		aragorn = container "Aragorn" "Coordinator" "Java"
		moria_vault = container "Moria Vault" "Database" "PostgreSQL" "DB"
		ravens = container "Messenger Ravens" "Message queue" "RabbitMQ" "Pipe"
		dwarf_miner = container "Dwarf Miner" "Worker" "Python"
	}

	// Container relationships
	aragorn -> isengard_listeners "Retrieves transcriptions from stream" "Kafka"
	aragorn -> moria_vault "Saves to the Vault" "TCP"
	aragorn -> ravens  "Sends Ravens with tasks" "AMQP"
	ravens -> dwarf_miner "Delivers tasks to the Dwarf" "AMQP"
	ravens -> aragorn "Returns results to Aragorn" "AMQP"
	dwarf_miner -> eye_of_sauron "Consults the Eye" "REST/HTTPS"
	dwarf_miner -> ravens "Delivers results to Ravens" "AMQP"
	helms_deep -> aragorn "Requests intelligence" "REST/HTTPS"

	// Data flows
	isengard_listeners -> aragorn "INF01. Speech transcriptions" "" "Dataflow"
	moria_vault -> aragorn "INF02. Transcriptions and Eye interpretations" "" "Dataflow"
	aragorn -> ravens "INF03. Processing tasks" "" "Dataflow"
	ravens -> dwarf_miner "INF04. Processing tasks" "" "Dataflow"
	eye_of_sauron -> dwarf_miner "INF05. Eye interpretations" "" "Dataflow"
	dwarf_miner -> ravens "INF06. Eye interpretations" "" "Dataflow"
	ravens -> aragorn "INF07. Eye interpretations" "" "Dataflow"
	aragorn -> helms_deep "INF08. Speech interpretations" "" "Dataflow"
}

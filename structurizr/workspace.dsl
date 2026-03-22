workspace "Middle-earth" {
	!identifiers hierarchical

	model {
		properties {
			"structurizr.groupSeparator" "/"
		}

		// Common elements of Middle-earth
		!include "common.dsl"

		// Forges of Middle-earth
		!include "domains/mlops_and_classic_ml/mlops_and_classic_ml.dsl"

		// Council of the Wise
		!include "domains/genai/genai.dsl"

		// Fellowship of the Ring
		!include "domains/agents/agents.dsl"

		// Listeners
		!include "domains/speech_analytics/speech_analytics.dsl"

		// Runic Workshops
		!include "domains/ocr/ocr.dsl"
	}

	views {
		systemLandscape "Landscape" "Map of Middle-earth" {
			include *
			exclude relationship.tag==Dataflow
		}

		!include "domains/mlops_and_classic_ml/views.dsl"
		!include "domains/genai/views.dsl"
		!include "domains/agents/views.dsl"
		!include "domains/speech_analytics/views.dsl"
		!include "domains/ocr/views.dsl"

		styles {
			element "Person" {
				shape person
				background "#08427b"
				color "#ffffff"
			}

			element "Software System" {
				shape roundedbox
				background "#1168bd"
				color "#ffffff"
			}

			element "Container" {
				shape roundedbox
				background "#438dd5"
				color "#ffffff"
			}

			element "External" {
				background "#666666"
				color "#ffffff"
			}

			element "DB" {
				shape "Cylinder"
			}

			element "Pipe" {
				shape "Pipe"
			}

			relationship "Dataflow" {
				dashed true
				thickness 2
			}

			// Artifacts not yet deployed to production
			element "NotInProd" {
				border dashed
				stroke "#666666"
				strokeWidth 4
				opacity 60
			}

			// New elements — green accent
			element "New" {
				border solid
				stroke "#2EA44F"
				strokeWidth 5
			}

			// Changed elements — blue accent
			element "Changed" {
				border solid
				stroke "#1168bd"
				strokeWidth 5
			}

			// New relationships — green line
			relationship "New" {
				color "#2EA44F"
				thickness 3
			}

			// Changed relationships — blue line
			relationship "Changed" {
				color "#1168bd"
				thickness 3
			}
		}
	}
}

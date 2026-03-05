workspace "Средиземье" {
	!identifiers hierarchical

	model {
		properties {
			"structurizr.groupSeparator" "/"
		}

		// Общие элементы Средиземья
		!include "common.dsl"

		// Кузницы Средиземья
		!include "domains/mlops_and_classic_ml/mlops_and_classic_ml.dsl"

		// Совет Мудрых
		!include "domains/genai/genai.dsl"

		// Братство Кольца
		!include "domains/agents/agents.dsl"

		// Слухачи
		!include "domains/speech_analytics/speech_analytics.dsl"

		// Рунические Мастерские
		!include "domains/ocr/ocr.dsl"
	}

	views {
		systemLandscape "Landscape" "Карта Средиземья" {
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

			// Артефакты, ещё не покинувшие кузницу
			element "NotInProd" {
				border dashed
				stroke "#666666"
				strokeWidth 4
				opacity 60
			}

			// Новые элементы — зелёный акцент
			element "New" {
				border solid
				stroke "#2EA44F"
				strokeWidth 5
			}

			// Изменяемые элементы — синий акцент
			element "Changed" {
				border solid
				stroke "#1168bd"
				strokeWidth 5
			}

			// Новые связи — зелёная линия
			relationship "New" {
				color "#2EA44F"
				thickness 3
			}

			// Изменяемые связи — синяя линия
			relationship "Changed" {
				color "#1168bd"
				thickness 3
			}
		}
	}
}

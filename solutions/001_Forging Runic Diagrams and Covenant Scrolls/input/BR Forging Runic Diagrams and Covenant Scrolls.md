# BR Forging Runic Diagrams and Covenant Scrolls

# 1. General Project Information

## 1.1 Glossary

| Runic Diagrams | Standard for describing Middle-earth rituals as runic inscriptions |
| --- | --- |
| Covenant Scroll | Scroll containing covenants defining the Council's needs |
| Covenant Scroll Template | Approved Covenant Scroll structure |
| Task Palantir | Tool for managing Council assignments |
| Library of Minas Tirith | Repository of Council chronicles and scrolls |
| Validation Tablets | Set of artifact testing criteria |
| Intent Interpretation | Iterative clarification of a request |
| Carrier Dove | Intermediary messenger for linking Middle-earth tools |
| White Tower | Stronghold of the Council of the Wise, using Istari for knowledge interpretation |
| Mirror of the White Tower | Internal mirror for rangers to interact with the White Tower |
| Hidden Chambers of the White Tower | Secret halls of the White Tower where magic is performed |
| Istari | Great Seers gifted with foresight |
| Istari Magic | Sorcery produced by the Great Seers |
| Eye of Sauron | Council of the Wise gateway for Istari magic |
| Knowledge Palantir | Carrier dove for linking with the Task Palantir and Library of Minas Tirith |
| Runic Hammer | Skilled carrier dove for forging and testing runic diagrams and Covenant Scrolls |
| Rune Master | Messenger for working with runic diagrams and Covenant Scrolls |

## 1.2 Project Description

The project outcome must achieve the following goals:

- Easing the burden of preparing and approving runic diagrams and Covenant Scrolls by the Council through magical acceleration of rituals
- Improving the quality and speed of ritual scroll preparation
- Magical forging, testing, and publishing of runic diagrams and Covenant Scrolls by incantation
- Enforcing Council covenants and Validation Tablets through sorcery

The work is commissioned by:

- Council of the Wise

Project result consumers will be:

- Ritual Keepers
- Chroniclers and rune interpreters
- Council Charter Keepers

Interested parties:

- Stewards of Gondor
- Blacksmith services

The project is implemented under the following constraints:

- Mandatory compliance with Council covenants and Validation Tablets
- Use of approved set of runic elements and templates
- Consideration of the ritual library when forging runic diagrams is out of scope
- Consideration of the Keepers' ritual handbook is out of scope
- Consideration of the Middle-earth Tools catalog is out of scope
- Validation Tablets are stored statically within the Knowledge Palantir
- Runic diagrams are formed in pure standard without extensions or special attributes of individual strongholds
- Access to capabilities is through the Mirror of the White Tower (mode/tool selection)
- Exclusion of manual editing of runic diagrams and Covenant Scrolls on the White Tower Mirror side
- Forged artifacts may require user refinement
- Service-level access only to public spaces of the Library of Minas Tirith
- Service-level access only to public projects of the Task Palantir
- Covenant Scrolls are published by default in the Library of Minas Tirith space
- The following static templates are used as Covenant Scroll templates:
    - Council: Covenant Scroll Template (unified)
    - Architecture: Covenant Scroll Template (architectural, optional)
    - Fellowship: Covenant Scroll Template (optional)
    - Forges: Covenant Scroll Template (optional)
- Management of runic diagram and Covenant Scroll forging is through the Rune Master, deployed in the Smiths of Rivendell and linked to the White Tower
- The Runic Hammer is deployed at the Crossroads of Bree as a carrier dove for forging and testing artifacts

## 1.3 Positioning

The White Tower is designed for centralized forging of runic diagrams and Covenant Scrolls, provides integration with Council tools (Task Palantir, Library of Minas Tirith), and supports the full artifact lifecycle: forging, interpretation, testing, publishing.

# 2. Council Covenants

## 2.1 Capabilities

- Magical forging of runic diagrams and Covenant Scrolls based on incantation
- Import and editing of runic diagrams through incantation chains
- Export of runic diagrams and Covenant Scrolls for publishing and further use
- Automatic artifact validation against Council Validation Tablets and reference data
- Integration with the Task Palantir (receiving assignments), Library of Minas Tirith (publishing, updating, retrieving content), Istari (forging and refinement)
- Support for iterative interpretation
- Change history logging and action journaling

## 2.2 Key User Expectations

| **User/Group/Role** | **Role Description** | **Need** | **Capabilities to Fulfill the Need** | **Comment** |
| --- | --- | --- | --- | --- |
| Ritual Keeper | Initiator | Fast forging and publishing of diagrams and Scrolls | Magical acceleration, integration with Library of Minas Tirith |  |
| Chronicler | Creation/editing | Reduced routine labor | Export, import, incantation chains, testing |  |
| Council Charter Keeper | Correctness control | Validation against Tablets, uniformity | Automatic testing, access to Tablets |  |

## 2.3 Assumptions and Dependencies

- Access to capabilities only through the Mirror of the White Tower for all users (via mode/tool selection)
- Access to Access Runes of the Task Palantir, Library of Minas Tirith, Istari for integration and data retrieval
- Mandatory use of approved Covenant Scroll template
- Set of allowed runic elements is static
- Council reference data and Validation Tablets are available statically within the White Tower
- Result quality depends on the quality of ritual descriptions provided by users
- Rune Master is deployed as a component of the Smiths of Rivendell and uses their infrastructure
- Runic Hammer is deployed as a component of the Crossroads of Bree and uses its integration infrastructure

## 2.4 Forging Ritual

[Forging_Runic_Scrolls.bpmn](Forging_Runic_Scrolls.bpmn)

# 3. Functional Requirements

## 4.1 Artifact Forging

- Magical forging of runic diagrams from incantation
- Magical forging of Covenant Scrolls based on incantation using the approved template
- Forming ritual intent based on received context
- Using Istari for wise construction and refinement of artifacts

## 4.2 Artifact Export and Import

- Import of existing runic diagrams from external sources
- Export of runic diagrams in pure format without extensions or special attributes of individual strongholds

## 4.3 Artifact Editing and Refinement

- Editing diagrams through incantation chains (dialog/iterative refinement)
- Storing and displaying artifact change history (within dialog history)

## 4.4 Testing and Quality Control

- Automatic testing of runic diagrams against Council Validation Tablets, standards, and approved element set
- Testing Covenant Scrolls for compliance with the approved template and mandatory sections
- Contextual testing (checking ritual logic, scenarios, branches, information completeness)
- Generating a report of found errors/discrepancies with correction recommendations

## 4.5 Integration with Council Tools

- Integration with the Task Palantir:
    - Receiving and using assignment context (description, participants, links)
- Integration with the Library of Minas Tirith:
    - Automatic publishing/updating of scrolls
    - Receiving and saving links to published artifacts
- Integration with Istari via the Eye of Sauron:
    - Using Istari for forging, refining, interpreting diagrams and scrolls
    - Using the Eye of Sauron for verification, masking/unmasking data when working with Istari

# 5. Non-Functional Requirements

## 5.1 Security

- Microservice secrets are stored only in Dwarven Vaults
- No flows without authorization/authentication
- Rune Master and carrier dove creation follows Citadel Guards covenants
- Logging is performed in accordance with Citadel Guards covenants
- Integration with any magical services only through the Eye of Sauron gateway

## 5.2 Usability

- Single Mirror for all users: Mirror of the White Tower
- Support for incantation chains for iterative editing

## 5.3 Logging and Reporting

- Log White Tower actions to stdout

## 5.4 Performance

- Service must handle up to 1,500 requests per day
- Task Palantir load: no more than 30 requests/min per node
- Library of Minas Tirith load: no more than 30 requests/min per node

## 5.5 Availability

- Operating mode — 24/7

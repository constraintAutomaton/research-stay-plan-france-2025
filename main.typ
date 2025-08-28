#import "@preview/slydst:0.1.4": *

#show: slides.with(
  title: "From Traversal to Dynamic Federation",
  subtitle: "Rethinking Link Traversal Query Processing via Subwebs and RDF Data Shapes",
  authors: "Bryan-Elliott Tam",
)

#show raw: set block(fill: silver.lighten(65%), width: 100%, inset: 1em)

== Outline

#outline()

== Why Link Traversal Query Processing (LTQP)

- Challenges of LTQP
  - Performance Issues
    - Slow query execution
    - High network cost (many HTTP requests)
  - Difficult to determine result trustworthiness and quality

- Why use LTQP
  - Querying of unindexed networks
  - *Facilitate integration across multiple indexed data networks that are only loosely connected*

== LTQP

#align(center,image("./img/LTQP.drawio.png", width: 60%))

== Federated Queries and LTQP
- Both involve a federation of _interfaces_ (SPARQL, TPF, Files)
- Both can involve dynamic federation with a finite number of member
  - Service-Safeness concept for federated queries (#link("https://www.sciencedirect.com/science/article/abs/pii/S157082681200114X")[Federating queries in SPARQL 1.1: Syntax, semantics and evaluation])
  - Reachability Criteria (#link("https://dl.acm.org/doi/10.1145/2309996.2310005")[Foundations of Traversal Based Query Execution over Linked Data])
- We could potentially apply optimization strategies from the federated query world to LTQP 

#pagebreak()

```rq
PREFIX ex: <http://example.org/>
PREFIX dbo: <http://dbpedia.org/ontology/>

SELECT ?scientist ?birthPlace
WHERE {
  ?dataset a ex:Dataset ;
           ex:hasService ?outerService .

  SERVICE ?outerService {
    ?resource ex:providesInnerService ?innerService .

    SERVICE ?innerService {
      ?scientist a dbo:Scientist ;
                 dbo:birthPlace ?birthPlace .
    }
  }
}
```
== FedQPL
- We need a fundation for this transfert of strategies 
- Paper: #link("https://dl.acm.org/doi/10.1145/3428757.3429120")[FedQPL: A Language for Logical Query Plans over
Heterogeneous Federations of RDF Data Sources] (time following definitions and tables are from this paper)

#align(center, image("./img/definition_4_fedqpl.png", width: 50%))

#align(center,image("./img/definition_1_fedqpl.png", width: 50%))

== LTQP Query Plan Using the FedQPL Model

Two interpretations of LTQP:

- *Stream-based Internal Querying* (current interpretations)
  - Query the internal triple store with $Q$ in a streaming way
- *Virtual Resource Federation*  
  - Query the _virtual_ resource (federation member)
  - *Current approach* Engine performs "exhaustive source assignment" (Definition 9)
  - Enables investigation of source assignment strategies
  - Most strategies require statistics about federation members
    - The shape index could provide some of those statistics

#align(center, image("./img/definition_9_fedqpl.png", width: 60%))

#align(center, image("./img/table_1_fedqpl.png", width: 60%))

== FedUp Approach

- *FedUp Framework* (#link("https://dl.acm.org/doi/10.1145/3589334.3645704")[FedUP: Querying Large-Scale Federations of SPARQL Endpoints])
  - Designed to "process SPARQL queries over large federations of SPARQL endpoints"
  - Shows similar analogy with LTQP approach

#align(center, image("./img/problem_1_fedup.png", width: 60%))

#align(center, image("./img/example_3_fedup.png", width: 60%))

- *Key Requirements*
  - Necessitates a summary mechanism
  - Shape index _could_ serve as this summary

#align(center, image("./img/fedup_summary.png", width: 60%))

== Plan

=== Formalization
- Make FedQPL Dynamic
  - Data source discovery in federated queries
  - LTQP reachability integration
    - Expanding plan vs adaptative plan

- Describe the FedUp algorithm with the shape index
  - Describe algorithm with shape index integration

=== Implementation

==== Static File Federation
- Experiment with Fedup algorithm using shape indexes inside of Comunica

==== Provenance Information in the Internal Triple Store
- Add subweb provenance to triples
- Store subweb shape index information in engine

==== Cache Algorithm
- Perform federated query first, then extend results with LTQP

==== Traversal integration
- Use Fedup approach during link traversal with adaptative query planning

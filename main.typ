#import "@preview/slydst:0.1.4": *

#show: slides.with(
  title: "From Traversal to Dynamic Federation",
  subtitle: "Rethinking Link Traversal Query Processing via Subwebs and RDF Data Shapes",
  authors: "Bryan-Elliott Tam",
)

#show raw: set block(fill: silver.lighten(65%), width: 100%, inset: 1em)

#show link: underline
#show link: set text(fill: blue)
== Outline

#outline()

== What Are We Trying to Achieve
Query the web of linked data like one unified database

=== Challenges
  - *Decentralization*: No single endpoint, the data scattered across countless servers
  - *Scale*: Too large to download completely
  - *Data Quality*: Large portions are query-irrelevant or untrusted

== Link Traversal Query Processing (LTQP)

#align(center,image("./img/LTQP.drawio.png", width: 55%))

- Challenges of LTQP
  - Performance Issues
    - Slow query execution
    - High network overhead
  - Trust & quality concerns

- Why use LTQP
  - Query unindexed networks
  - *Integrate loosely connected data networks*

== Federated Queries And LTQP Similarities
- Involve a federation of _interfaces_ (SPARQL, TPF, RDF Files)
- The federation _can be_ dynamic 
  - Service-Safeness concept for federated queries (#link("https://www.sciencedirect.com/science/article/abs/pii/S157082681200114X")[Federating queries in SPARQL 1.1: Syntax, semantics and evaluation])
    - Example in the next slide
  - Reachability Criteria (#link("https://dl.acm.org/doi/10.1145/2309996.2310005")[Foundations of Traversal Based Query Execution over Linked Data])
- *Emulation of optimization strategies across querying models _may_ be possible*
  - Requires a theoretical foundation

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

== Can FedQPL be a Foundation for LTQP 

- Paper: #link("https://dl.acm.org/doi/10.1145/3428757.3429120")[FedQPL: A Language for Logical Query Plans over
Heterogeneous Federations of RDF Data Sources] (time following definitions and tables are from this paper)

#figure(
  image("./img/fedqplOperators.drawio.png", width: 90%),
  caption: [Summary of FedQPL operators as defined in Definition 4],
) <fig:fedqpl-operators>

- Notion of _interface_
  - Tied to a federation member
  - Defines which knowledge graph can be queried
  - Defines the query expressivity supported

#pagebreak()

=== Two interpretations of LTQP

- *Stream-based Internal Querying* (current interpretation without FedQPL)
  - Query the internal triple store with $Q$ in a streaming way
- *Virtual Resource Federation* (proposed interpretation with FedQPL)
  - Query the _virtual_ resource (federation member)
  - *Current approach:* "exhaustive source assignment" (Definition 9)
  - *Future approaches:* emulating other source assignment algorithms in the literature

#pagebreak()

=== Consideration

- Most strategies require statistics about federation members
  - The shape index could provide some of those statistics
  - Already been used to reduce the search space of LTQP
    - #link("https://ceur-ws.org/Vol-3954/paper2300.pdf")[Opportunities for Shape-Based Optimization of Link Traversal Queries]
    - Journal paper currently under submission
- FedQPL does not consider dynamic federations even for federated queries

== Shape Index

#align(center,image("./img/shape_index.png", width: 100%))

== FedUp Approach

- Paper: (#link("https://dl.acm.org/doi/10.1145/3589334.3645704")[FedUP: Querying Large-Scale Federations of SPARQL Endpoints])
  - Designed to "[process] SPARQL queries over large federations of SPARQL endpoints"
  - "[O]nly a few combinations of sources may return result"
  - *Similar problem with LTQP*
    - *Previous research* reduce the search space (source selection)
    - *Current research* reduce the non-contributing join ("Result-Aware query plans")

=== Requirement
  - Summary mechanism
    - To compute the "Result-Aware query plans"
  - Shape index _could_ serve as this summary
== Plan

=== Formalization
- Extend FedQPL to consider dynamic federations
  - Federated queries
  - LTQP
  - Expanding plan
    - _Could_ be a simpler particular case of adaptive plan

- Adapt FedUp for LTQP
  - Use the shape index as a summary mechanism
    - _Note:_ This may already be addressed through FedQPL extensions, as FedQPL is the foundation of FedUp

#pagebreak()

=== Implementation

==== Static File Federation
- Experiment with FedUp algorithm using shape indexes within Comunica

==== Provenance Information in the Internal Triple Store
- Add sub-web and shape index provenance 

==== Cache Algorithm
- Perform federated query first, then extend results with LTQP

==== Traversal Integration
- Use FedUp approach during link traversal with adaptive query planning

==== Considerations
- The separate RDF store by resource implementation of Comunica is significantly slower than the one store implementation
  - A refactoring will soon be done to address this issue
  - The one store implementation would require some "hacks" to implement the proposed approach

==== Evaluation

- We plan to use the #link("https://github.com/SolidBench/SolidBench.js")[SolidBench] benchmark
  - Specifically designed for evaluating Link Traversal Query Processing
  - Based on #link("https://github.com/ldbc/ldbc_snb_datagen_hadoop")[LDBC SNB social network dataset]
  - Includes shape index module
- Additional benchmarks or datasets could be interesting
- Evaluation metrics:
  - Query execution time
  - Query planning overhead
  - First result arrival time
  - Termination time (time between the last result and the end of the query)
  - Waiting time (cumulative time between the arrival of two results)
  - Diefficiency metric
  - Ratio of query-relevant joins
  - Theoretical metrics about query plan efficiency (to be explored)


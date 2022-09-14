EXPLAIN ANALYZE 
SELECT a.corpus_id, b.title, b.publication_year, a.abstract
FROM s2.abstracts a
JOIN s2.papers b
ON a.corpus_id = b.corpus_id
WHERE abstract @@ (to_tsquery('(carbon | co2 | (carbon <-> dioxide)) <-> (capture <2> storage)')
 || to_tsquery('(co2 | (carbon <-> dioxide)) <3> ((capture | recovery) <2> sequestration)')
 || to_tsquery('((co2 | (carbon <-> dioxide)) <3> (captur* | stor* | recover* | extrac*)) & (post <-> combustion | scrub*)'))
LIMIT 100;

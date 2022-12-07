CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;

CREATE SCHEMA IF NOT EXISTS core AUTHORIZATION joe;

CREATE TEMP TABLE tmp_core (
    data jsonb
    );

COPY tmp_core(data)
FROM PROGRAM 'cat /var/data/core/output/output/docs/*/*.jsonl'
csv quote e'\x01' delimiter e'\x02';

WITH tmp as (
SELECT
(data ->> 'coreId')::text as core_id,
(data ->> 'doi')::text as doi,
(data ->> 'magId')::text as mag_id,
(data ->> 'issn')::text as issn,
(data ->> 'oai')::text as oai,
data -> 'identifiers' as identifiers,
(data ->> 'title')::text as title,
(data ->> 'abstract')::text as abstract,
data -> 'authors' as authors,
(data ->> 'provider_id')::text as provider_id,
(data ->> 'publisher')::text as publisher,
data -> 'journals' as publisher_journals,
(data ->> 'year')::int as publishing_year,
(data ->> 'datePublished') as publish_date, --todo: dates seem to be malformed in the sample, how do i handle
(data ->> 'language')::text as document_language, -- todo: can i use this for dynamic index?
data -> 'topics' as document_topics,
data -> 'subjects' as document_evaluation,
data -> 'urls' as document_urls,
data -> 'contributors' as contributors,
(data ->> 'fullTextIdentifier' is not null)::bool has_full_text,
(data ->> 'fullTextIdentifier' as)::text full_text_identifier,
data -> 'enrichments' as enrichments,
data -> 'relations' as relations
FROM jsons.core_docs)

/*
INSERT INTO s2.abstracts SELECT DISTINCT ON (corpus_id) * FROM tmp
ON CONFLICT (corpus_id) DO UPDATE SET
    doi = EXCLUDED.doi,
    mag_id = EXCLUDED.mag_id,
    abstract = EXCLUDED.abstract,
    open_access_status = EXCLUDED.open_access_status,
    open_access_license = EXCLUDED.open_access_license,
    open_access_url = EXCLUDED.open_access_url,
    external_ids = EXCLUDED.external_ids,
    updated_date = EXCLUDED.updated_date;

DROP TABLE tmp_abstracts;*/
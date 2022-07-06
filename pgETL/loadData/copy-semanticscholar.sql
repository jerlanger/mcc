-- ## ABSTRACTS ## --

CREATE TEMP TABLE s2_abstracts (
    data jsonb
    );

COPY s2_abstracts(data)
FROM ‘/var/data/semanticscholar/local/data/json_outputs/abstracts.jsonl’
csv quote e'\x01' delimiter e'\x02';

WITH tmp as (
SELECT
(data ->> 'corpusid')::text as corpus_id,
(data #>> '{openaccessinfo,externalids,DOI}')::text as doi,
(data #>> '{openaccessinfo,externalids,MAG}')::text as mag_id,
(data ->> 'abstract')::text as abstract,
(data #>> '{openaccessinfo,status}')::text as open_access_status,
(data #>> '{openaccessinfo,license}')::text as open_access_license,
(data #>> '{openaccessinfo,url}')::text as open_access_url,
data #> '{openaccessinfo,externalids}' as external_ids,
(data ->> 'updated')::timestamp as updated_date
FROM s2_abstracts
)

INSERT INTO s2.abstracts SELECT * FROM tmp
ON CONFLICT (corpus_id) DO UPDATE;

-- ## AUTHORS ## --

CREATE TEMP TABLE s2_authors (
    data jsonb
);

COPY s2_authors(data)
FROM ‘/var/data/semanticscholar/local/data/json_outputs/authors.jsonl’
csv quote e'\x01' delimiter e'\x02';

with tmp as (
  SELECT
  (data ->> 'authorid')::text as author_id,
  data -> 'externalids' as external_ids,
  (data ->> 'name')::text as name,
  data -> 'aliases' as aliases,
  (data ->> 'url')::text as url,
  (data ->> 'homepage')::text as homepage,
  data -> 'affiliations' as affiliations,
  (data ->> 'papercount')::int as paper_count,
  (data ->> 'citationcount')::int as citation_count,
  (data ->> 'hindex')::int as hindex,
  (data ->> 'updated')::timestamp as updated_date
  FROM jsons.s2_authors
)

INSERT INTO s2.authors SELECT * FROM tmp
ON CONFLICT (author_id) DO UPDATE;

-- ## CITATIONS ## --

-- ## PAPERS ## --

CREATE TEMP TABLE s2_papers (
    data jsonb
    );

COPY s2_papers(data)
FROM ‘/var/data/semanticscholar/local/data/json_outputs/papers.jsonl’
csv quote e'\x01' delimiter e'\x02';

WITH tmp AS (SELECT
(data ->> 'corpusid')::text as corpus_id,
(data #>> '{externalids,DOI}')::text as doi,
(data #>> '{externalids,MAG}')::text as mag_id,
data -> 'externalids' as external_ids,
(data ->> 'title')::text as title,
(data ->> 'year')::int as publication_year,
(data -> 'venue')::text as publication_venue,
data -> 'authors' as authors,
(data ->> 'isopenaccess')::bool as is_open_access,
(data ->> 'url')::text as url,
data -> 's2fieldsofstudy' as s2_fields_of_study,
(data ->> 'citationcount')::int as citation_count,
(data ->> 'referencecount')::int as reference_count,
(data ->> 'influentialcitationcount')::int as influential_citation_count,
(data ->> 'updated')::timestamp as updated_date
FROM s2_papers)

INSERT INTO sscholar.papers SELECT * FROM tmp
ON CONFLICT (corpus_id) DO UPDATE;

-- ## S2ORC ## --

CREATE TEMP TABLE s2_s2orc (
    data jsonb
    );

COPY s2_s2orc(data)
FROM ‘/var/data/semanticscholar/local/data/json_outputs/s2orc.jsonl’
csv quote e'\x01' delimiter e'\x02';

with tmp as (SELECT
(data ->> 'corpusid')::text corpus_id,
(data #>> '{externalids,doi}')::text doi,
(data #>> '{externalids,mag}')::text mag_id,
(data -> 'externalids') external_ids,
(data #> '{content,source,oainfo}') open_access_metadata,
quote_nullable(data #>> '{content,text}')::text as full_text,
(data #> '{content,annotations}') annotations,
(data ->> 'updated')::timestamp updated_date
FROM s2_s2orc)

INSERT INTO s2.s2orc SELECT * FROM tmp
ON CONFLICT (corpus_id) DO UPDATE;

-- ## TLDRS ## --

CREATE TEMP TABLE s2_tldrs (
    data jsonb
    );

COPY s2_tldrs(data)
FROM ‘/var/data/semanticscholar/local/data/json_outputs/tldrs.jsonl’
csv quote e'\x01' delimiter e'\x02';

with tmp as (
SELECT
(data ->> 'corpusid')::text as corpus_id,
(data ->> 'model')::text as model,
(data ->> 'text')::text as summary
FROM s2_tldrs
)

INSERT INTO s2.tldrs SELECT * FROM tmp
ON CONFLICT (corpus_id) DO UPDATE;
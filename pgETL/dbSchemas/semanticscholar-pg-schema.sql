CREATE SCHEMA IF NOT EXISTS s2 AUTHORIZATION joe;

SET default_tablespace = '';
SET default_table_access_method = heap;

CREATE TABLE s2.authors (
	author_id text NOT NULL,
	external_ids jsonb,
	name text,
	aliases jsonb,
	url text,
    homepage text,
	affiliations jsonb,
	paper_count integer,
	citation_count integer,
	hindex integer,
	updated_date timestamp without time zone,
	PRIMARY KEY (author_id)
);

CREATE INDEX author_name ON s2.authors(name);

COMMENT ON TABLE s2.authors
IS 'Provides summary information about authors';

CREATE TABLE s2.abstracts (
	corpus_id text NOT NULL,
    doi text,
    mag_id text,
    abstract text,
    open_access_status text,
    open_access_license text,
    open_access_url text,
    external_ids jsonb,
	updated timestamp without time zone,
	PRIMARY KEY (corpus_id)
);

-- todo: can i make an index for the abstract text?

COMMENT ON TABLE s2.abstracts
IS 'provides abstract text for selected papers';

CREATE TABLE s2.citations (
	citation_id SERIAL NOT NULL
	citing_corpus_id text NOT NULL,
	cited_corpus_id text,
	is_influential boolean, -- s2 evaluation of the "importance" of the citation to the citing corpus
	contexts text[], -- Text surrounding the citation in the source paper's body
	intents text[], -- Classification of the intent behind the citations.
	updated timestamp without time zone,
	PRIMARY KEY (citation_id)
);

CREATE INDEX citing_id ON s2.citations(citing_corpus_id);
CREATE INDEX cited_id ON s2.citations(cited_corpus_id);

COMMENT ON TABLE s2.citations
IS 'provides details about the relationship between citing and cited corpus ids.';

CREATE TABLE IF NOT EXISTS s2.papers (
  corpus_id text NOT NULL,
  doi text,
  mag_id text,
  external_ids jsonb,
  title text,
  publication_year int,
  publication_venue text,
  authors jsonb,
  is_open_access bool,
  url text,
  s2_fields_of_study jsonb,
  citation_count int,
  reference_count int,
  influential_citation_count int,
  updated timestamp without time zone,
  PRIMARY KEY (corpus_id)
);

CREATE INDEX paper_pubyear ON s2.papers(publication_year);
CREATE INDEX paper_pubname ON s2.papers(publication_venue);
CREATE INDEX paper_papername ON s2.papers(title);
CREATE INDEX paper_doi ON s2.papers(doi);
CREATE INDEX paper_mag ON s2.papers(mag_id);

COMMENT ON TABLE s2.papers
IS 'provides core metadata about papers. For abstract or citation information join corpus_id on the relevant tables';

CREATE TABLE IF NOT EXISTS s2.s2orc (
    corpus_id text NOT NULL,
    doi text,
    mag_id text,
    external_ids jsonb,
    open_access_metadata jsonb,
    full_text text,
    annotations jsonb,
    updated_date timestamp without time zone,
    PRIMARY KEY (corpus_id)
    );

-- todo s2orc contains full-text-- need to investigate best way to incorporate for index
-- todo table comment explainer

CREATE TABLE IF NOT EXISTS  s2.tldrs (
	corpus_id text NOT NULL,
	model text,
	summary text,
	PRIMARY KEY (corpus_id)
);

COMMENT ON TABLE s2.tldrs
IS 'semantic scholar auto-generated natural-language summaries of paper content using SciTLDR model available at https://github.com/allenai/scitldr';


CREATE SCHEMA IF NOT EXISTS sscholar AUTHORIZATION joe;

SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE TABLE sscholar.authors (
	author_id text NOT NULL,
	external_ids text,
	url text,
	name text,
	alias text[],
	affiliations text[],
	papercount integer,
	citationcount integer,
	hindex integer,
	updated timestamp without time zone
	PRIMARY KEY (author_id)
);

CREATE INDEX author_name ON sscholar.authors(name);

COMMENT ON TABLE sscholar.authors
IS 'Provides summary information about authors';

CREATE TABLE sscholar.abstracts (
	corpus_id text NOT NULL,
	mag_id text,
	acl_id text,
	doi text,
	pubmedcentral_id text,
	arxiv_id text,
	openaccess_license text,
	openaccess_url text,
	openaccess_status text,
	abstract text,
	updated timestamp without time zone
	PRIMARY KEY (corpus_id)
);

COMMENT ON TABLE sscholar.abstracts
IS 'provides abstract text for selected papers';

CREATE TABLE sscholar.citations (
	citation_id SERIAL NOT NULL
	citing_corpus_id text NOT NULL,
	cited_corpus_id text,
	is_influential boolean, -- sscholar evaluation of the "importance" of the citation to the citing corpus
	contexts text[], -- Text surrounding the citation in the source paper's body
	intents text[], -- Classification of the intent behind the citations.
	updated timestamp without time zone
	PRIMARY KEY (citation_id)
);

CREATE INDEX citing_id ON sscholar.citations(citing_corpus_id);
CREATE INDEX cited_id ON sscholar.citations(cited_corpus_id);

COMMENT ON TABLE sscholar.citations
IS 'provides details about the relationship between citing and cited corpus ids.';

CREATE TABLE sscholar.papers (
	corpus_id text NOT NULL,
	acl_id text,
	dblp_id text,
	arxiv_id text,
	mag_id text,
	ext_corpus_id
	pubmed_id text,
	doi text,
	pubmedcentral_id text,
	url text,
	title text,
	authors text[][], --todo check how to properly implement this column. Is this a json or an array? Can pg do kvp?
	venue text,
	year integer,
	referencecount integer,
	citationcount integer,
	influentialcitationcount integer,
	is_openaccess boolean,
	s2fieldsofstudy text,
	updated timestamp without time zone
	PRIMARY KEY (corpus_id)
);

CREATE INDEX pubyear ON sscholar.papers(year);
CREATE INDEX pubname ON sscholar.papers(venue);
CREATE INDEX papername ON sscholar.papers(title);

COMMENT ON TABLE sscholar.papers
IS 'provides core metadata about papers. For abstract or citation information join corpus_id on the relevant tables';

-- todo s2orc contains full-text and complex schema, need to investigate best way to incorporate

-- CREATE TABLE sscholar.s2orc

CREATE TABLE IF NOT EXISTS  sscholar.tldrs (
	corpus_id text NOT NULL,
	model text,
	summary text
	PRIMARY KEY (corpus_id)
);

COMMENT ON TABLE sscholar.tldrs
IS 'semantic scholar auto-generated natural-language summaries of paper content using SciTLDR model available at https://github.com/allenai/scitldr';


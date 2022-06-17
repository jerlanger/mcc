CREATE SCHEMA sscholar;

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
);

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
);

CREATE TABLE sscholar.citations (
	citing_corpus_id text NOT NULL,
	cited_corpus_id text,
	is_influential boolean,
	contexts text[],
	intents text[],
	updated timestamp without time zone
);

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
);

-- todo s2orc contains full-text and complex schema, need to investigate best way to incorporate

-- CREATE TABLE sscholar.s2orc

CREATE TABLE IF NOT EXISTS  sscholar.tldrs (
	corpus_id text NOT NULL PRIMARY KEY,
	model text,
	summary text
);

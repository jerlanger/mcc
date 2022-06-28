
-- Default settings given by dev_openalex in original script

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE SCHEMA IF NOT EXISTS dev_openalex;

SET default_tablespace = '';
SET default_table_access_method = heap;

-- AUTHORS TABLES

CREATE TABLE IF NOT EXISTS dev_openalex.authors (
    id text NOT NULL,
    orcid text, -- canonical external id
    display_name text,
    display_name_alternatives json,
    works_count integer,
    cited_by_count integer,
    last_known_institution text,
    works_api_url text,
    updated_date timestamp without time zone,
    PRIMARY KEY (id)
);

CREATE INDEX author_name ON dev_openalex.authors (display_name);
CREATE INDEX last_institution ON dev_openalex.authors (last_known_institution);

COMMENT ON TABLE dev_openalex.authors
IS 'provides summary information about authors. linked to works via works_authorships';

CREATE TABLE IF NOT EXISTS dev_openalex.authors_counts_by_year (
    author_id text NOT NULL,
    year integer NOT NULL,
    works_count integer,
    cited_by_count integer,
    PRIMARY KEY (author_id, year)
);

COMMENT ON TABLE dev_openalex.authors_counts_by_year
IS 'yearly aggregate statistics on authors';

CREATE TABLE IF NOT EXISTS dev_openalex.authors_ids (
    author_id text NOT NULL,
    openalex text,
    orcid text, -- canonical external id
    scopus text,
    twitter text,
    wikipedia text,
    mag bigint,
    PRIMARY KEY (author_id)
);

COMMENT ON TABLE dev_openalex.authors_ids
IS 'contains external ids for authors';

-- CONCEPTS TABLES

CREATE TABLE IF NOT EXISTS dev_openalex.concepts (
    id text NOT NULL,
    wikidata text,
    display_name text,
    level integer,
    description text,
    works_count integer,
    cited_by_count integer,
    image_url text,
    image_thumbnail_url text,
    works_api_url text,
    updated_date timestamp without time zone,
    PRIMARY KEY (id)
);

CREATE INDEX concept_name ON dev_openalex.concepts (display_name);
CREATE INDEX concept_level ON dev_openalex.concepts (level);

COMMENT ON TABLE dev_openalex.concepts
IS 'primary table for concepts. abstracted topics which are assigned to works and related hierarchically. for more modeling info please see https://github.com/ourresearch/dev_openalex-concept-tagging';

CREATE TABLE IF NOT EXISTS dev_openalex.concepts_ancestors (
    concept_id text,
    ancestor_id text,
    PRIMARY KEY (concept_id, ancestor_id)
);

CREATE INDEX concepts_ancestors_concept_id_idx ON dev_openalex.concepts_ancestors USING btree (concept_id);

COMMENT ON TABLE dev_openalex.concepts_ancestors
IS 'relationship table for concepts and their hierarchical ancestors';

CREATE TABLE IF NOT EXISTS dev_openalex.concepts_counts_by_year (
    concept_id text NOT NULL,
    year integer NOT NULL,
    works_count integer,
    cited_by_count integer,
    PRIMARY KEY (concept_id, year)
);

COMMENT ON TABLE dev_openalex.concepts_counts_by_year
IS 'yearly aggregate statistics on concepts';

CREATE TABLE IF NOT EXISTS dev_openalex.concepts_ids (
    concept_id text NOT NULL,
    openalex text,
    wikidata text,
    wikipedia text,
    umls_aui json,
    umls_cui json,
    mag bigint,
    PRIMARY KEY (concept_id)
);

COMMENT ON TABLE dev_openalex.concepts_ids
IS 'contains external ids for concepts';

CREATE TABLE IF NOT EXISTS dev_openalex.concepts_related_concepts (
    concept_id text,
    related_concept_id text,
    score real, -- openalex model likeness score
    PRIMARY KEY (concept_id, related_concept_id)
);

CREATE INDEX concepts_related_concepts_concept_id_idx ON dev_openalex.concepts_related_concepts USING btree (concept_id);
CREATE INDEX concepts_related_concepts_related_concept_id_idx ON dev_openalex.concepts_related_concepts USING btree (related_concept_id);

COMMENT ON TABLE dev_openalex.concepts_related_concepts
IS 'horizontal relationship between concepts';

-- INSTITUTIONS TABLES

CREATE TABLE IF NOT EXISTS dev_openalex.institutions (
    id text NOT NULL,
    ror text, -- canonical external id
    display_name text,
    country_code text,
    type text,
    homepage_url text,
    image_url text,
    image_thumbnail_url text,
    display_name_acroynyms json,
    display_name_alternatives json,
    works_count integer,
    cited_by_count integer,
    works_api_url text,
    updated_date timestamp without time zone,
    PRIMARY KEY (id)
);

CREATE INDEX institution_name ON dev_openalex.institutions (display_name);
CREATE INDEX institution_country ON dev_openalex.institutions (country_code);
CREATE INDEX institution_type ON dev_openalex.institutions (type);

COMMENT ON TABLE dev_openalex.institutions
IS 'institutions are organizations to which authors claim affiliations. linked to works via works_authorships.';

CREATE TABLE IF NOT EXISTS dev_openalex.institutions_associated_institutions (
    institution_id text,
    associated_institution_id text,
    relationship text,
    PRIMARY KEY (institution_id, associated_institution_id)
);

COMMENT ON TABLE dev_openalex.institutions_associated_institutions
IS 'relationship table between institutions';

CREATE TABLE IF NOT EXISTS dev_openalex.institutions_counts_by_year (
    institution_id text NOT NULL,
    year integer NOT NULL,
    works_count integer,
    cited_by_count integer,
    PRIMARY KEY (institution_id, year)
);

COMMENT ON TABLE dev_openalex.institutions_counts_by_year
IS 'yearly aggregate statistics on institutions';

CREATE TABLE IF NOT EXISTS dev_openalex.institutions_geo (
    institution_id text NOT NULL,
    city text,
    geonames_city_id text,
    region text,
    country_code text,
    country text,
    latitude real,
    longitude real,
    PRIMARY KEY (institution_id)
);

COMMENT ON TABLE dev_openalex.institutions_geo
IS 'physical location of institutions';

CREATE TABLE IF NOT EXISTS dev_openalex.institutions_ids (
    institution_id text NOT NULL,
    openalex text,
    ror text, -- canonical external id
    grid text,
    wikipedia text,
    wikidata text,
    mag bigint,
    PRIMARY KEY (institution_id)
);

COMMENT ON TABLE dev_openalex.institutions_ids
IS 'contains external ids for institutions';

-- VENUES TABLES

CREATE TABLE IF NOT EXISTS dev_openalex.venues (
    id text NOT NULL,
    issn_l text, -- canonical external id
    issn json,
    display_name text,
    publisher text,
    works_count integer,
    cited_by_count integer,
    is_oa boolean, -- open access
    is_in_doaj boolean, -- directory of open access journals
    homepage_url text,
    works_api_url text,
    updated_date timestamp without time zone,
    PRIMARY KEY (id)
);

CREATE INDEX venue_issn ON dev_openalex.venues (issn_l);
CREATE INDEX venue_name ON dev_openalex.venues (display_name);
CREATE INDEX venue_publisher ON dev_openalex.venues (publisher);

COMMENT ON TABLE dev_openalex.venues
IS 'where works are hosted. information comes from crossref, issn network, and mag. linked to works via works_host_venue and works_alternate host venues.';

CREATE TABLE IF NOT EXISTS dev_openalex.venues_counts_by_year (
    venue_id text NOT NULL,
    year integer NOT NULL,
    works_count integer,
    cited_by_count integer,
    PRIMARY KEY (venue_id, year)
);

COMMENT ON TABLE dev_openalex.venues_counts_by_year
IS 'yearly aggregate statistics on venues';

CREATE TABLE IF NOT EXISTS dev_openalex.venues_ids (
    venue_id text,
    openalex text,
    issn_l text,
    issn json,
    mag bigint,
    PRIMARY KEY (venue_id)
);

COMMENT ON TABLE dev_openalex.venues_ids
IS 'contains external ids for venues';

-- WORKS TABLES

CREATE TABLE IF NOT EXISTS dev_openalex.works (
    id text NOT NULL,
    doi text, -- canonical external id
    title text,
    display_name text,
    publication_year integer,
    publication_date text,
    type text,
    cited_by_count integer,
    is_retracted boolean,
    is_paratext boolean,
    cited_by_api_url text,
    abstract_inverted_index json,
    PRIMARY KEY (id)
);

CREATE INDEX works_title ON dev_openalex.works (title);
CREATE INDEX works_pubyear ON dev_openalex.works (publication_year);
CREATE INDEX works_type ON dev_openalex.works (type);
CREATE INDEX works_doi ON dev_openalex.works (doi);

COMMENT ON TABLE dev_openalex.works
IS 'documents like journal articles, books, datasets, and theses. sources include crossref, pubmed, institutional and discipline-specific repositories (eg, arxiv). older works come from the now-defunct microsoft academic graph. works are clustered together using fuzzy matching on publication date, title, and author list';

CREATE TABLE IF NOT EXISTS dev_openalex.works_alternate_host_venues (
    work_id text,
    venue_id text,
    url text,
    is_oa boolean,
    version text,
    license text,
    PRIMARY KEY (work_id, venue_id)
);

CREATE INDEX works_alternate_host_venues_work_id_idx ON dev_openalex.works_alternate_host_venues USING btree (work_id);

COMMENT ON TABLE dev_openalex.works_alternate_host_venues
IS 'relationship table between works and secondary venues';

CREATE TABLE IF NOT EXISTS dev_openalex.works_authorships (
    work_id text,
    author_position text,
    author_id text,
    institution_id text,
    raw_affiliation_string text,
    PRIMARY KEY (work_id, author_id)
);

CREATE INDEX works_authorships_work_id ON dev_openalex.works_authorships (work_id);
CREATE INDEX works_position ON dev_openalex.works_authorships (author_position);
CREATE INDEX works_authorships_author_id ON dev_openalex.works_authorships (author_id);

COMMENT ON TABLE dev_openalex.works_authorships
IS 'relationship table between works and authors';

CREATE TABLE IF NOT EXISTS dev_openalex.works_biblio (
    work_id text NOT NULL,
    volume text,
    issue text,
    first_page text,
    last_page text,
    PRIMARY KEY (work_id)
);

COMMENT ON TABLE dev_openalex.works_biblio
IS 'biblio location information for works';

CREATE TABLE IF NOT EXISTS dev_openalex.works_concepts (
    work_id text,
    concept_id text,
    score real,
    PRIMARY KEY (work_id, concept_id)
);

CREATE INDEX works_concepts_work_id ON dev_openalex.works_concepts (work_id);
CREATE INDEX works_concepts_concept_id ON dev_openalex.works_concepts (concept_id);

COMMENT ON TABLE dev_openalex.works_concepts
IS 'relationship table between works and concepts. for more information on concepts see comment on concepts table.';

CREATE TABLE IF NOT EXISTS dev_openalex.works_host_venues (
    work_id text,
    venue_id text,
    url text,
    is_oa boolean,
    version text,
    license text,
    PRIMARY KEY (work_id, venue_id)
);

CREATE INDEX works_host_venues_work_id_idx ON dev_openalex.works_host_venues USING btree (work_id);
CREATE INDEX works_host_venues_venue_id ON dev_openalex.works_host_venues (venue_id);

COMMENT ON TABLE dev_openalex.works_host_venues
IS 'relationship table between works and primary venue';

CREATE TABLE IF NOT EXISTS dev_openalex.works_ids (
    work_id text NOT NULL,
    openalex text,
    doi text, -- canonical external id
    mag bigint,
    pmid text,
    pmcid text,
    PRIMARY KEY (work_id)
);

COMMENT ON TABLE dev_openalex.works_ids
IS 'contains external ids for works';

-- I don't have a good understanding of the data in this table. Need to look into
CREATE TABLE IF NOT EXISTS dev_openalex.works_mesh (
    work_id text,
    descriptor_ui text,
    descriptor_name text,
    qualifier_ui text,
    qualifier_name text,
    is_major_topic boolean
    -- todo: primary key
);

COMMENT ON TABLE dev_openalex.works_mesh
IS 'pubmed works only. list of medical subject headings. for more information see https://www.nlm.nih.gov/mesh/meshhome.html';

CREATE TABLE IF NOT EXISTS dev_openalex.works_open_access (
    work_id text NOT NULL,
    is_oa boolean,
    oa_status text,
    oa_url text,
    PRIMARY KEY (work_id)
);

COMMENT ON TABLE dev_openalex.works_open_access
IS 'open access status of works';

CREATE TABLE IF NOT EXISTS dev_openalex.works_referenced_works (
    work_id text,
    referenced_work_id text,
    PRIMARY KEY (work_id, referenced_work_id)
);

CREATE INDEX works_referenced_works_work_id ON dev_openalex.works_referenced_works (work_id);
CREATE INDEX works_referenced_Works_referenced_id ON dev_openalex.works_referenced_works (referenced_work_id);

COMMENT ON TABLE dev_openalex.works_referenced_works
IS 'relationship table between works and other works it references';

CREATE TABLE IF NOT EXISTS dev_openalex.works_related_works (
    work_id text,
    related_work_id text,
    PRIMARY KEY (work_id, related_work_id)
);

CREATE INDEX works_related_works_work_id ON dev_openalex.works_related_works (work_id);
CREATE INDEX works_related_works_related_id ON dev_openalex.works_related_works (related_work_id);

COMMENT ON TABLE dev_openalex.works_related_works
IS 'relationship table for related works. computed algorithmically; the algorithm finds recent papers with the most concepts in common with the work_id';
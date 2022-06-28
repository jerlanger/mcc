CREATE EXTENSION pg_trgm; -- This is to enable GIN indexing see https://www.postgresql.org/docs/9.1/pgtrgm.html
CREATE SCHEMA IF NOT EXISTS core AUTHORIZATION joe;

SET default_tablespace = '';
SET default_table_access_method = heap;

CREATE TABLE IF NOT EXISTS core.works (
    doi text,
    core_id text NOT NULL,
    oai text,
    mag_id text,
    identifiers[] text,
    title text,
    authors[] text,
    enrichments jsonb,
    contributors[] text,
    date_published timestamp without time zone,
    abstract text,
    download_url text,
    full_text_identifier text, --todo see if this is bool
    pdf_hash_value text, -- can probably be removed
    publisher text,
    journals[] text,
    language text,
    relations[] text,
    pub_year integer,
    topics[] text,
    subjects[] text,
    full_text text, -- can probably be removed for now
    urls[] text,
    issn text,
    PRIMARY KEY (core_id)
);

CREATE INDEX works_title ON core.works (title);
CREATE INDEX works_publisher ON core.works (publisher);
CREATE INDEX works_year ON core.works (pub_year);
CREATE INDEX works_language ON core.works (language);
CREATE INDEX works_date ON core.works (date_published);
CREATE INDEX works_issn ON core.works (issn);
CREATE INDEX works_abstract_idx ON core.works (abstract) USING gin(abstract gin_trgm_ops); --todo see if this works properly
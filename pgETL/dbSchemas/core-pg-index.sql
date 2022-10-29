
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;

CREATE INDEX idx_core_works_title ON core.works USING btree (title);
CREATE INDEX idx_core_works_title_tsv ON core.works USING gin (to_tsvector('english',title)); -- todo: see if I can use language col for dynamic tsvector
CREATE INDEX idx_core_works_publisher ON core.works USING btree (publisher);
CREATE INDEX idx_core_works_year ON core.works USING btree (pub_year);
CREATE INDEX idx_core_works_language ON core.works USING btree (language);
CREATE INDEX idx_core_works_date ON core.works USING btree (date_published);
CREATE INDEX idx_core_works_issn ON core.works USING btree (issn);
CREATE INDEX idx_core_works_abstract_tsv ON core.works (abstract) USING gin (to_tsvector('english',abstract)); -- todo: see if I can use language col for dynamic tsvector
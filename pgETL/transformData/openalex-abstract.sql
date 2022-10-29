
WITH upd AS (
    SELECT
    id,
    doi,
    array_to_string(ARRAY_AGG(b.key ORDER BY c.value::INT),' ') abstract,
    to_tsvector('english',array_to_string(ARRAY_AGG(b.key ORDER BY c.value::INT),' ')) ts_abstract
    FROM openalex.works a
    JOIN json_each(abstract_inverted_index) b ON TRUE
    JOIN json_array_elements_text(b.value) c ON TRUE
    GROUP BY 1,2;
    )

INSERT INTO openalex.abstracts SELECT * FROM upd
ON CONFLICT (id) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_oa_abstracts_tsv AS gin (ts_abstract);
CREATE INDEX IF NOT EXISTS idx_oa_abstracts_doi AS btree (doi);
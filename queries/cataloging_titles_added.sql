--metadb:function titles_added

DROP FUNCTION IF EXISTS titles_added;

CREATE FUNCTION titles_added(
    start_date date DEFAULT '2010-01-01',
    end_date date DEFAULT '2050-12-31'
)
RETURNS TABLE(
    hrid text,
    title text,
    contributors text,
    created_date timestamp
)
AS
$$
SELECT
    jsonb_extract_path_text(i.jsonb,'hrid') AS hrid,
    jsonb_extract_path_text(i.jsonb,'title') AS title,
    jsonb_extract_path_text(i.jsonb,'contributors') AS contributors,
    jsonb_extract_path_text(i.jsonb,'metadata','createdDate')::timestamp AS created_date
FROM folio_inventory.instance AS i
WHERE jsonb_extract_path_text(i.jsonb,'metadata','createdDate')::timestamp >= start_date
  AND jsonb_extract_path_text(i.jsonb,'metadata','createdDate')::timestamp < end_date + INTERVAL '1 day'
ORDER BY created_date DESC
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;

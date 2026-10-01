--metadb:function titles_added

DROP FUNCTION IF EXISTS titles_added;

CREATE FUNCTION titles_added(
    start_date date DEFAULT '2010-01-01',
    end_date date DEFAULT '2050-12-31'
)
RETURNS TABLE(
    hrid text,
    inventory_url text,
    title text,
    place_of_publication text,
    publisher text,
    publication_year text,
    created_date timestamp
)
AS
$$
SELECT
    jsonb_extract_path_text(i.jsonb,'hrid') AS hrid,

    'https://demo1.folio.ebsco.com/inventory?query=' ||
    jsonb_extract_path_text(i.jsonb,'hrid') ||
    '&sort=relevance' AS inventory_url,

    jsonb_extract_path_text(i.jsonb,'title') AS title,

    i.jsonb #>> '{publication,0,place}' AS place_of_publication,
    i.jsonb #>> '{publication,0,publisher}' AS publisher,
    i.jsonb #>> '{publication,0,dateOfPublication}' AS publication_year,

    jsonb_extract_path_text(i.jsonb,'metadata','createdDate')::timestamp AS created_date

FROM folio_inventory.instance AS i

WHERE jsonb_extract_path_text(i.jsonb,'metadata','createdDate')::timestamp >= start_date
  AND jsonb_extract_path_text(i.jsonb,'metadata','createdDate')::timestamp < end_date + INTERVAL '1 day'

ORDER BY created_date DESC
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;

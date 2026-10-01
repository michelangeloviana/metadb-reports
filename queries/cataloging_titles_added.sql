--metadb:function titles_added

DROP FUNCTION IF EXISTS titles_added;

CREATE FUNCTION titles_added(
    start_date date DEFAULT '1000-01-01',
    end_date date DEFAULT '3000-01-01'
)
RETURNS TABLE(
    instance_hrid text,
    title text,
    cataloged_date timestamp
)
AS $$
SELECT
    instance_hrid,
    title,
    cataloged_date
FROM inventory_ext.instance
WHERE start_date <= cataloged_date::date
  AND cataloged_date::date < end_date
ORDER BY cataloged_date DESC
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;

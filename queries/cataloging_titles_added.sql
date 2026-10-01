SELECT
    instance_hrid,
    title,
    cataloged_date
FROM inventory_ext.instance
WHERE cataloged_date BETWEEN :start_date AND :end_date
ORDER BY cataloged_date DESC;

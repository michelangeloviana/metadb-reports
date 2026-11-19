--metadb:function listagem_actualizacao_exemplares

DROP FUNCTION IF EXISTS listagem_actualizacao_exemplares(date, date);

CREATE FUNCTION listagem_actualizacao_exemplares(
    start_date date DEFAULT '2020-01-01',
    end_date   date DEFAULT '2050-01-01'
)
RETURNS TABLE(
    Hrid                 text,
    CodBarras            text,
    Chamada              text,
    Prefixo_localizacao  text,
    Data_criacao         text,
    Timestamp_criacao    timestamptz,
    IdUsuarioCriador     uuid,
    Codigousuario        text,
    Nomeusuario          text,
    Grupousuario         text
)
AS $$

SELECT
    i.jsonb->>'Hrid',
    i.jsonb->>'CodBarras',
    concat_ws(' ',
        i.jsonb->'effectiveCallNumberComponents'->>'prefix',
        i.jsonb->'effectiveCallNumberComponents'->>'callNumber',
        i.jsonb->'effectiveCallNumberComponents'->>'suffix'),
    split_part(l.jsonb->>'code', '/', 1),
    to_char((i.jsonb->'metadata'->>'updatedDate')::date, 'YYYY-MM-DD'),
    (i.jsonb->'metadata'->>'updatedDate')::timestamptz,
    u.id,
    u.jsonb->>'username',
    concat_ws(' ',
        u.jsonb->'personal'->>'firstName',
        u.jsonb->'personal'->>'lastName'),
    g.desc
FROM folio_inventory.item__ i
LEFT JOIN folio_inventory.location__ l
       ON l.id = (i.jsonb->>'effectiveLocationId')::uuid
      AND l.__current
LEFT JOIN folio_users.users__ u
       ON u.id = (i.jsonb->'metadata'->>'updatedByUserId')::uuid
      AND u.__current
LEFT JOIN folio_users.groups__t__ g
       ON g.id = (u.jsonb->>'patronGroup')::uuid
      AND g.__current
WHERE (i.jsonb->'metadata'->>'updatedDate')::date BETWEEN start_date AND end_date
  AND i.__current
ORDER BY
    (i.jsonb->'metadata'->>'updatedDate')::timestamptz DESC,
    concat_ws(' ',
        u.jsonb->'personal'->>'firstName',
        u.jsonb->'personal'->>'lastName')

$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;

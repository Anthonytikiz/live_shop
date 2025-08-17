-- Générer et exécuter des DROP pour toutes les tables
DO $$ DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = current_schema()) LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;


SELECT table_name
  FROM information_schema.tables
 WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
   AND table_type = 'BASE TABLE';

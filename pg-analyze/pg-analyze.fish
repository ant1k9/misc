#!/usr/bin/env fish
set PG_ANALYZE_TEMPORARY_CONFIG_FILE /tmp/.pg-analyze.db.credentials

function _pg_analyze_usage
    echo 'Usage:
    pg-analyze <command>

Commands:
    setup <db-dsn>       - Setup database connection
    cache-hit-ratio      - Cache hit ratio for tables and indexes
    database-bloat       - Analyze bloat for database
    database-size        - Size of tables and indexes
    foreign-keys         - Number of foreign keys for all tables
    full-overview        - Full overview including most of pg-analyze subcommands
    index-usage          - Index usage
    long-running-queries - Current long-running queries
    queries-to-optimize  - The top 5 queries that could be optimized
    table-accesses       - Number of scans for tables
    unused-indexes       - Unused indexes for current workload'
end

function _setup
    if test -z "$argv[1]"
        echo -e "⚠️  Please provide db-dsn to setup database\n"
        _pg_analyze_usage
        exit
    end

    echo "$argv[1]" > "$PG_ANALYZE_TEMPORARY_CONFIG_FILE"
    echo "Configured successfully"
end

function _ensure_setup
    if not test -s "$PG_ANALYZE_TEMPORARY_CONFIG_FILE"
        echo -e "⚠️  Please setup database first\n"
        _pg_analyze_usage
        exit
    end
end

function _pretty_print
    echo -e "\t\033[1m$argv[1]\033[0m:\n"
end

function _database_bloat
    _ensure_setup
    _pretty_print "Database bloat"

    psql (cat "$PG_ANALYZE_TEMPORARY_CONFIG_FILE") -c "
    WITH constants AS (
        SELECT current_setting('block_size')::numeric AS bs, 23 AS hdr, 8 AS ma
    ),
    no_stats AS (
        SELECT table_schema, table_name, 
            n_live_tup::numeric as est_rows,
            pg_table_size(relid)::numeric as table_size
        FROM information_schema.columns
        JOIN pg_stat_user_tables as psut
           ON table_schema = psut.schemaname
           AND table_name = psut.relname
        LEFT OUTER JOIN pg_stats
        ON table_schema = pg_stats.schemaname
            AND table_name = pg_stats.tablename
            AND column_name = attname 
        WHERE attname IS NULL
            AND table_schema NOT IN ('pg_catalog', 'information_schema')
        GROUP BY table_schema, table_name, relid, n_live_tup
    ),
    null_headers AS (
        SELECT
            hdr+1+(sum(case when null_frac <> 0 THEN 1 else 0 END)/8) as nullhdr,
            SUM((1-null_frac)*avg_width) as datawidth,
            MAX(null_frac) as maxfracsum,
            schemaname,
            tablename,
            hdr, ma, bs
        FROM pg_stats CROSS JOIN constants
            LEFT OUTER JOIN no_stats
                ON schemaname = no_stats.table_schema
                AND tablename = no_stats.table_name
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND no_stats.table_name IS NULL
            AND EXISTS ( SELECT 1
                FROM information_schema.columns
                    WHERE schemaname = columns.table_schema
                        AND tablename = columns.table_name )
        GROUP BY schemaname, tablename, hdr, ma, bs
    ),
    data_headers AS (
        SELECT
            ma, bs, hdr, schemaname, tablename,
            (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
            (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
        FROM null_headers
    ),
    table_estimates AS (
        SELECT schemaname, tablename, bs,
            reltuples::numeric as est_rows, relpages * bs as table_bytes,
        CEIL((reltuples*
                (datahdr + nullhdr2 + 4 + ma -
                    (CASE WHEN datahdr%ma=0
                        THEN ma ELSE datahdr%ma END)
                    )/(bs-20))) * bs AS expected_bytes,
            reltoastrelid
        FROM data_headers
            JOIN pg_class ON tablename = relname
            JOIN pg_namespace ON relnamespace = pg_namespace.oid
                AND schemaname = nspname
        WHERE pg_class.relkind = 'r'
    ),
    estimates_with_toast AS (
        SELECT schemaname, tablename, 
            TRUE as can_estimate,
            est_rows,
            table_bytes + ( coalesce(toast.relpages, 0) * bs ) as table_bytes,
            expected_bytes + ( ceil( coalesce(toast.reltuples, 0) / 4 ) * bs ) as expected_bytes
        FROM table_estimates LEFT OUTER JOIN pg_class as toast
            ON table_estimates.reltoastrelid = toast.oid
                AND toast.relkind = 't'
    ),
    table_estimates_plus AS (
        SELECT current_database() as databasename,
                schemaname, tablename, can_estimate, 
                est_rows,
                CASE WHEN table_bytes > 0
                    THEN table_bytes::NUMERIC
                    ELSE NULL::NUMERIC END
                    AS table_bytes,
                CASE WHEN expected_bytes > 0 
                    THEN expected_bytes::NUMERIC
                    ELSE NULL::NUMERIC END
                        AS expected_bytes,
                CASE WHEN expected_bytes > 0 AND table_bytes > 0
                    AND expected_bytes <= table_bytes
                    THEN (table_bytes - expected_bytes)::NUMERIC
                    ELSE 0::NUMERIC END AS bloat_bytes
        FROM estimates_with_toast
        UNION ALL
        SELECT current_database() as databasename, 
            table_schema, table_name, FALSE, 
            est_rows, table_size,
            NULL::NUMERIC, NULL::NUMERIC
        FROM no_stats
    ),
    bloat_data AS (
        select current_database() as databasename,
            schemaname, tablename, can_estimate, 
            table_bytes, round(table_bytes/(1024^2)::NUMERIC,3) as table_mb,
            expected_bytes, round(expected_bytes/(1024^2)::NUMERIC,3) as expected_mb,
            round(bloat_bytes*100/table_bytes) as pct_bloat,
            round(bloat_bytes/(1024::NUMERIC^2),2) as mb_bloat,
            table_bytes, expected_bytes, est_rows
        FROM table_estimates_plus
    )
    SELECT databasename, schemaname, tablename,
        can_estimate,
        est_rows,
        pct_bloat, mb_bloat,
        table_mb
    FROM bloat_data
    WHERE ( pct_bloat >= 50 AND mb_bloat >= 20 )
        OR ( pct_bloat >= 25 AND mb_bloat >= 1000 )
    ORDER BY pct_bloat DESC"
end

function _database_size
    _ensure_setup
    _pretty_print "Database size"

    psql (cat "$PG_ANALYZE_TEMPORARY_CONFIG_FILE") -c "
    SELECT
        relname AS table_name,
        pg_size_pretty(pg_total_relation_size(relid)) AS total,
        pg_size_pretty(pg_relation_size(relid)) AS internal,
        pg_size_pretty(pg_table_size(relid) - pg_relation_size(relid)) AS external,
        pg_size_pretty(pg_indexes_size(relid)) AS indexes
    FROM
        pg_catalog.pg_statio_user_tables
    ORDER BY
        pg_total_relation_size(relid) DESC"
end

function _foreign_keys
    _ensure_setup
    _pretty_print "Foreign keys"

    psql (cat "$PG_ANALYZE_TEMPORARY_CONFIG_FILE") -c "
    SELECT
        t.oid::regclass::text AS table_name, count(1) AS total
    FROM
        pg_constraint c
    JOIN
        pg_class t ON (t.oid = c.confrelid)
    GROUP BY
        table_name
    ORDER BY
        total DESC"
end

function _cache_hit_ratio
    _ensure_setup
    _pretty_print "Cache hit ratio"

    psql (cat "$PG_ANALYZE_TEMPORARY_CONFIG_FILE") -c "
    SELECT
        'index hit rate' AS name,
        (sum(idx_blks_hit)) / nullif(sum(idx_blks_hit + idx_blks_read),0) AS ratio
    FROM pg_statio_user_indexes
    UNION ALL
    SELECT
        'table hit rate' AS name,
        sum(heap_blks_hit) / nullif(sum(heap_blks_hit) + sum(heap_blks_read),0) AS ratio
    FROM pg_statio_user_tables"
end

function _index_usage
    _ensure_setup
    _pretty_print "Index usage"

    psql (cat "$PG_ANALYZE_TEMPORARY_CONFIG_FILE") -c "
    SELECT
        relname,
        CASE idx_scan
            WHEN 0 THEN 'Insufficient data'
            ELSE (100 * idx_scan / (seq_scan + idx_scan))::text
        END percent_of_times_index_used,
        n_live_tup rows_in_table
    FROM
        pg_stat_user_tables
    ORDER BY
        n_live_tup DESC"
end

function _unused_indexes
    _ensure_setup
    _pretty_print "Unused indexes"

    psql (cat "$PG_ANALYZE_TEMPORARY_CONFIG_FILE") -c "
    SELECT
        schemaname || '.' || relname AS table,
        indexrelname AS index,
        pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
        idx_scan as index_scans
    FROM
        pg_stat_user_indexes ui
    JOIN
        pg_index i ON ui.indexrelid = i.indexrelid
    WHERE
        NOT indisunique AND idx_scan < 50 AND pg_relation_size(relid) > 5 * 8192
    ORDER BY
        pg_relation_size(i.indexrelid) / nullif(idx_scan, 0) DESC NULLS FIRST,
        pg_relation_size(i.indexrelid) DESC"
end

function _queries_to_optimize
    _ensure_setup
    _pretty_print "Queries to optimize"

    # TOTAL_TIME_COLUMN depends on postgresql version (total_time or total_exec_time)
    export TOTAL_TIME_COLUMN=total_exec_time

    psql (cat "$PG_ANALYZE_TEMPORARY_CONFIG_FILE") -c "
    WITH ttl AS (
        SELECT
            sum($TOTAL_TIME_COLUMN) AS total_time, sum(blk_read_time + blk_write_time) AS io_time,
            sum($TOTAL_TIME_COLUMN - blk_read_time - blk_write_time) AS cpu_time,
            sum(calls) AS ncalls, sum(rows) AS total_rows
        FROM
            pg_stat_statements WHERE dbid IN (
                SELECT oid FROM pg_database WHERE datname=current_database()
            )
    )
    
    SELECT
        query, calls, round(min_exec_time) min, round(max_exec_time) max, round(mean_exec_time) mean,
        round((pss.$TOTAL_TIME_COLUMN - pss.blk_read_time - pss.blk_write_time) / ttl.cpu_time * 100) cpu_pct
    FROM
        pg_stat_statements pss, ttl
    WHERE
        (pss.$TOTAL_TIME_COLUMN - pss.blk_read_time - pss.blk_write_time) / ttl.cpu_time >= 0.05
    ORDER BY
        pss.$TOTAL_TIME_COLUMN - pss.blk_read_time - pss.blk_write_time DESC
    LIMIT 5"
end

function _long_running_queries
    _ensure_setup
    _pretty_print "Long running queries"

    psql (cat "$PG_ANALYZE_TEMPORARY_CONFIG_FILE") -c "
    SELECT
        psa.datname as database,
        psa.query as current_query,
        clock_timestamp() - psa.xact_start AS transaction_age,
        array_agg(distinct c.relname) AS tables_with_locks
    FROM
        pg_catalog.pg_stat_activity psa
    JOIN
        pg_catalog.pg_locks l ON (psa.pid = l.pid)
    JOIN
        pg_catalog.pg_class c ON (l.relation = c.oid)
    JOIN
        pg_catalog.pg_namespace ns ON (c.relnamespace = ns.oid)
    WHERE
        psa.pid != pg_backend_pid()
        AND ns.nspname != 'pg_catalog'
        AND c.relkind = 'r'
        AND psa.xact_start < clock_timestamp() - '5 seconds'::interval
    GROUP BY
        psa.datname, psa.query, psa.xact_start"
end

function _table_accesses
    _ensure_setup
    _pretty_print "Table accesses"

    psql (cat "$PG_ANALYZE_TEMPORARY_CONFIG_FILE") -c "
    SELECT
        relname,
        seq_scan,
        seq_tup_read,
        idx_scan,
        idx_tup_fetch,
        n_tup_ins,
        n_tup_upd
    FROM
        pg_catalog.pg_stat_user_tables
    "
end

function _full_overview
    _database_bloat
    _database_size
    _cache_hit_ratio
    _index_usage
    _unused_indexes
    _queries_to_optimize
    _table_accesses
end

# main
if test "$argv[1]" = "setup"
    _setup "$argv[2]"
else if test "$argv[1]" = "database-bloat"
    _database_bloat
else if test "$argv[1]" = "database-size"
    _database_size
else if test "$argv[1]" = "foreign-keys"
    _foreign_keys
else if test "$argv[1]" = "cache-hit-ratio"
    _cache_hit_ratio
else if test "$argv[1]" = "index-usage"
    _index_usage
else if test "$argv[1]" = "unused-indexes"
    _unused_indexes
else if test "$argv[1]" = "queries-to-optimize"
    _queries_to_optimize
else if test "$argv[1]" = "long-running-queries"
    _long_running_queries
else if test "$argv[1]" = "table-accesses"
    _table_accesses
else if test "$argv[1]" = "full-overview"
    _full_overview
else 
    _pg_analyze_usage
end

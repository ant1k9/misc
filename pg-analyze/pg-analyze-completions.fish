set -l _pg_analyze_commands \
    setup \
    database-size \
    foreign-keys \
    cache-hit-ratio \
    index-usage \
    unused-indexes \
    queries-to-optimize \
    long-running-queries \
    table-accesses \
    full-overview

complete -f pg-analyze \
    -n "not __fish_seen_subcommand_from $_pg_analyze_commands" \
    -a setup \
    -d "Setup database connection"

complete -f pg-analyze \
    -n "not __fish_seen_subcommand_from $_pg_analyze_commands" \
    -a database-size \
    -d "Size of tables and indexes"

complete -f pg-analyze \
    -n "not __fish_seen_subcommand_from $_pg_analyze_commands" \
    -a foreign-keys \
    -d "Number of foreign keys for all tables"

complete -f pg-analyze \
    -n "not __fish_seen_subcommand_from $_pg_analyze_commands" \
    -a cache-hit-ratio \
    -d "Cache hit ratio for tables and indexes"

complete -f pg-analyze \
    -n "not __fish_seen_subcommand_from $_pg_analyze_commands" \
    -a index-usage \
    -d "Index usage"

complete -f pg-analyze \
    -n "not __fish_seen_subcommand_from $_pg_analyze_commands" \
    -a unused-indexes \
    -d "Unused indexes for current workload"

complete -f pg-analyze \
    -n "not __fish_seen_subcommand_from $_pg_analyze_commands" \
    -a queries-to-optimize \
    -d "The top 5 queries that could be optimized"

complete -f pg-analyze \
    -n "not __fish_seen_subcommand_from $_pg_analyze_commands" \
    -a long-running-queries \
    -d "Current long-running queries"

complete -f pg-analyze \
    -n "not __fish_seen_subcommand_from $_pg_analyze_commands" \
    -a table-accesses \
    -d "Number of scans for tables"

complete -f pg-analyze \
    -n "not __fish_seen_subcommand_from $_pg_analyze_commands" \
    -a full-overview \
    -d "Full overview including most of pg-analyze subcommands"

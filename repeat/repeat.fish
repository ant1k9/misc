#!/usr/bin/env fish

## body
argparse \
    'h/help' \
    'd/duration=' \
    'n/times=' \
    'ignore-errors' \
    'only-diff' -- $argv

if set -q _flag_help
    echo -n 'Usage:
    repeat --help           # show help information
    repeat --duration 2     # sleep duration between repeats
    repeat --times 10       # limit number of repeations
    repeat --only-diff      # refresh screen only if output has diff
    repeat --ignore-errors  # continue executions despite error from command
'
else
    set -l DURATION 2
    if set -q _flag_duration
        set DURATION "$_flag_duration"
    end

    set -l REPEATIONS 0
    if set -q _flag_times
        set REPEATIONS "$_flag_times"
    end

    set -l MASTERCOPY (mktemp)
    set -l CMD "$argv[1]"

    set -l loop 0
    while true
        set -l status_code
        if set -q _flag_only_diff
            set -g TMP_FILE (mktemp)
            sh -c "$CMD" > "$TMP_FILE"
            set status_code "$status"

            diff "$MASTERCOPY" "$TMP_FILE" &> /dev/null
            if test "$status" -ne 0
                clear
                mv "$TMP_FILE" "$MASTERCOPY"
                cat "$MASTERCOPY"
            else
                rm "$TMP_FILE"
            end
        else
            clear
            sh -c "$CMD"
            set status_code "$status"
        end

        if test "$status_code" -ne "0"
            if ! set -q _flag_ignore_errors
                echo "command exited with status code $status_code"
                break
            end
        end

        set loop (math "$loop + 1")
        if test "$loop" -eq "$REPEATIONS"
            break
        end

        sleep "$DURATION"
    end
end

complete -f -c repeat \
	-s h \
	-l help

complete -f -c repeat \
	-l "ignore-errors" \
	-d "continue executions despite error from command"

complete -f -c repeat \
	-l "only-diff" \
	-d "refresh screen only if output has diff"

complete -f -c repeat \
	-s "n" \
	-l "times" \
	-d "limit number of repeations" 

complete -f -c repeat \
    -s "d" \
	-l "duration" \
	-d "sleep duration between repeats"

set -l _pdf_picker_commands add clean generate last list

complete -f -c pdf-picker \
    -n "not __fish_seen_subcommand_from $_pdf_picker_commands" \
    -a add \
    -d "Add book to a library"

complete -f -c pdf-picker \
    -n "not __fish_seen_subcommand_from $_pdf_picker_commands" \
    -a clean \
    -d "Remove all generated chapters"

complete -f -c pdf-picker \
    -n "not __fish_seen_subcommand_from $_pdf_picker_commands" \
    -a generate \
    -d "Generate a new chapter"

complete -f -c pdf-picker \
    -n "not __fish_seen_subcommand_from $_pdf_picker_commands" \
    -a last \
    -d "Open the last generated chapter"

complete -f -c pdf-picker \
    -n "not __fish_seen_subcommand_from $_pdf_picker_commands" \
    -a list \
    -d "List topics available for a new chapter"

complete -f -c pdf-picker \
    -n "__fish_seen_subcommand_from generate" \
    -a "(pdf-picker list)"

complete -F -c pdf-picker \
    -n "__fish_seen_subcommand_from add"

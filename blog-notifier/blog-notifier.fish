#!/usr/bin/env fish

ssh "$BLOG_NOTIFIER_HOST" \
    -i "$BLOG_NOTIFIER_KEY_RSA" \
    "cd ~/blog-notifier && ./blog_notifier.py $argv"

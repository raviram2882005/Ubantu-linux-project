
#!/bin/bash
# lib/functions.sh - L62 Notice Board CLI

DATA="data/notices.txt"
LOG="logs/activity.log"
ARCHIVE="data/archive.txt"

# Write activity into log file
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" >> "$LOG"
}

# Check whether data file exists
check_data() {
    if [ ! -f "$DATA" ]; then
        echo "Data file not found: $DATA"
        return 1
    fi
}

# Display help
show_help() {
    echo "Notice Board CLI"
    echo "./main.sh       - Open menu"
    echo "./main.sh --help - Show help"
    echo "./main.sh --backup - Backup data"
    echo "./main.sh --cron - Archive old notices"
}

# View notice data
view_data() {
    check_data || return
    cat -n "$DATA"
}

# Create backup
do_backup() {
    mkdir -p backups
    f="backups/data_$(date +%Y%m%d_%H%M%S).tar.gz"
    if tar -czf "$f" data/; then
        echo "Backup saved: $f"
        du -h "$f"
        log "Backup created: $f"
    else
        echo "Backup failed."
    fi
}

# View activity log
view_log() {
    if [ -f "$LOG" ]; then
        tail -n 15 "$LOG"
    else
        echo "No activity yet."
    fi
}

# FEATURE 1: Post a new notice
feature_1() {
    check_data || return

    echo "== Post a new notice =="

    today=$(date +%Y-%m-%d)

    read -p "Enter notice title: " title
    read -p "Enter priority (HIGH/MEDIUM/LOW): " priority

    if [ -z "$title" ] || [ -z "$priority" ]; then
        echo "Values cannot be empty."
        return
    fi

    priority=$(echo "$priority" | tr '[:lower:]' '[:upper:]')

    if [[ "$priority" != "HIGH" && "$priority" != "MEDIUM" && "$priority" != "LOW" ]]; then
        echo "Invalid priority."
        return
    fi

    echo "$today|$title|$priority" >> "$DATA"

    echo "Notice saved successfully!"
    log "New notice added: $title"
}

# FEATURE 2: Show latest 5 notices
feature_2() {
    check_data || return

    echo "== Latest 5 notices =="

    sort -r "$DATA" | head -n 6
    log "Latest 5 notices viewed"
}

# FEATURE 3: Search notices by keyword
feature_3() {
    check_data || return

    read -p "Enter keyword to search: " word

    if [ -z "$word" ]; then
        echo "Keyword cannot be empty."
        return
    fi

    echo "== Search results =="

    if grep -i "$word" "$DATA" | grep -v '^date|'; then
        log "Notice searched: $word"
    else
        echo "No matching notice found."
    fi
}

# FEATURE 4: Show HIGH priority notices
feature_4() {
    check_data || return

    echo "== HIGH priority notices =="

    if grep -i '|HIGH$' "$DATA"; then
        log "HIGH priority notices viewed"
    else
        echo "No HIGH priority notices found."
    fi
}

# FEATURE 5: Archive notices older than 30 days
archive_old_notices() {
    check_data || return

    mkdir -p data

    touch "$ARCHIVE"

    today=$(date +%s)
    cutoff=$((today - 30 * 24 * 60 * 60))

    temp=$(mktemp)

    head -n 1 "$DATA" > "$temp"

    while IFS='|' read -r notice_date title priority
    do
        if [[ "$notice_date" == "date" ]]; then
            continue
        fi

        notice_time=$(date -d "$notice_date" +%s 2>/dev/null)

        if [[ -n "$notice_time" && "$notice_time" -lt "$cutoff" ]]; then
            echo "$notice_date|$title|$priority" >> "$ARCHIVE"
            echo "Archived: $title"
        else
            echo "$notice_date|$title|$priority" >> "$temp"
        fi
    done < <(tail -n +2 "$DATA")

    mv "$temp" "$DATA"

    echo "Old notices archived successfully."
    log "Old notices archived"
}

feature_5() {
    echo "== Archive notices older than 30 days =="
    archive_old_notices
}

# CRON TASK: Archive old notices automatically
cron_task() {
    echo "Running automatic archive task..."

    archive_old_notices

    echo "$(date '+%Y-%m-%d %H:%M') cron task ran" >> reports/cron_output.txt

    log "Cron task completed"
}


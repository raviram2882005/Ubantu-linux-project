# L62 – Notice Board CLI

**Student:** RAVI RAM | **Roll:** E38 | **Division:** H | **Enrollment:** 24004501210350

## Problem
Build a terminal notice board where notices can be posted, searched and archived.

## Who will use it
Class committees and department offices.

## Folder structure
- main.sh – menu (run with ./main.sh)
- lib/functions.sh – all functions
- data/ – data files
- reports/ – reports created by the script
- backups/ – tar.gz backups
- logs/ – activity.log and cron.log

## Features
1. Post a new notice with today's date
2. Show the latest 5 notices (sort -r | head)
3. Search notices by keyword (grep -i)
4. Show only HIGH priority notices
5. Move notices older than 30 days to archive.txt

## How to run
    cd ~/linux_project/noticeboard
    ./main.sh
    ./main.sh --help

## Crontab task
Every Monday at 8 AM, archive notices older than 30 days

    0 8 * * 1 /bin/bash $HOME/linux_project/noticeboard/main.sh --cron >> $HOME/linux_project/noticeboard/logs/cron.log 2>&1

## Commands used
date, sort -r, head, grep -i, awk, sed

## What I learned
(write 3-5 lines here)

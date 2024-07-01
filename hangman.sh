#!/bin/bash

source "$(dirname "$0")/colors.sh"
source "$(dirname "$0")/subjects_and_stages.sh"
source "$(dirname "$0")/functions.sh"

clear
print_color_message blue_text "welcome to hangman!!"
sleep 1

evaluate_terminal_dimensions

all_guesses=""
stage=0

choose_subject
process_guess
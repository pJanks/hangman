#!/bin/bash

source "$(dirname "$0")/colors.sh"
source "$(dirname "$0")/subjects_and_stages.sh"
source "$(dirname "$0")/functions.sh"

clear
print_color_message blue_text "welcome to hangman!!"
sleep 1

evaluate_terminal_dimensions

clear
display_subjects
read subject_choice

if [[ $subject_choice -ge 1 && $subject_choice -le ${#subjects[@]} ]]; then
  subject_index=$(( subject_choice - 1 ))
  selected_words=(${words[$subject_index]})
  
  random_word_index=$(( RANDOM % ${#selected_words[@]} ))
  random_word=${selected_words[$random_word_index]}
  uppercase_random_word=$(echo "$random_word" | tr '[:lower:]' '[:upper:]')

  if [[ -n $uppercase_random_word ]]; then
    clear
    print_color_message green_text "word chosen from ${subjects[$subject_index]}"
    sleep 1
    redacted_word=""
    for (( i=0; i<${#uppercase_random_word}; i++ )); do
      redacted_word+="_ "
    done
  else
    clear
    print_color_message red_text "an unexpected error occured"
    exit 1
  fi
else
  clear
  print_color_message red_text "select a valid subject"
  sleep 1
  clear
  bash "$0"
  exit 1
fi

all_guesses=""
stage=0

process_guess
print_color_message() {
  color=$1
  message=$2
  uppercase_message=$(echo "$message" | tr "[:lower:]" "[:upper:]")
  echo -e "${!color}${uppercase_message}${close_color_text}"
}

evaluate_terminal_dimensions() {
  dimensions=($(stty size))

  if [[ ${dimensions[0]} -lt 20 || ${dimensions[1]} -lt 60 ]]; then
    clear
    print_color_message red_text "recommended terminal size is 20 rows by 60 columns"
    sleep 3
  fi
}

display_subjects() {
  print_color_message blue_text "select a subject:"
  for i in "${!subjects[@]}"; do
    print_color_message yellow_text  "  $((i + 1)) ${subjects[$i]}"
  done
  print_color_message blue_text  "enter only the number that corresponds to your choice"
}

process_guess() {
  clear
  while true; do
    echo -e "${stages[$stage]}\n\n"
    echo -e "$redacted_word\n\n"
    echo "$all_guesses"

    print_color_message blue_text "enter your guess:"
    read current_guess

    if [[ -z "$current_guess" ]]; then
      clear
      print_color_message red_text "guess can't be empty"
    elif [[ ${#current_guess} -ne 1 ]]; then
      clear
      print_color_message red_text "guess can't be more than one character"
    elif [[ ! "$current_guess" =~ [a-zA-Z] ]]; then
      clear
      print_color_message red_text "guess must be a letter"
    else
      uppercase_current_guess=$(echo "$current_guess" | tr '[:lower:]' '[:upper:]')
      if [[ "$all_guesses" == *"$uppercase_current_guess"* ]]; then
        clear
        print_color_message red_text "that letter has already been guessed"
      else
        validate_guess
        break
      fi
    fi
  done
}

validate_guess() {
  all_guesses+="$uppercase_current_guess "
  if [[ $uppercase_random_word == *"$uppercase_current_guess"* ]]; then
    update_graphic_for_correct_guess
  else
    update_graphic_for_incorrect_guess
  fi
}

update_graphic_for_correct_guess() {
  new_redacted_word=""
  for (( i=0; i<${#uppercase_random_word}; i++ )); do
    if [[ "${uppercase_random_word:$i:1}" == "$uppercase_current_guess" ]]; then
      new_redacted_word+="$uppercase_current_guess "
    else
      new_redacted_word+="${redacted_word:2*i:1} "
    fi
  done
  redacted_word="$new_redacted_word"
  
  if [[ "${redacted_word// /}" == "$uppercase_random_word" ]]; then
    clear
    print_color_message blue_text "$redacted_word"
    echo ""
    print_color_message green_text "you win!!"
    sleep 2
    clear
    exit 0
  else
    process_guess
  fi
}

update_graphic_for_incorrect_guess() {
  (( stage++ ))
  if [[ $stage -lt $((${#stages[@]} - 1)) ]]; then
    process_guess
  else
    clear
    echo -e "${stages[$stage]}\n\n"
    echo -e "$redacted_word\n\n"
    echo -e "$all_guesses\n\n"
    print_color_message red_text "game over!!"
    echo ""
    print_color_message blue_text "the word was $random_word"
    sleep 5
    clear
    exit 0
  fi
}
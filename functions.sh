print_color_message() {
  color=$1
  message=$2
  uppercase_message=$(uppercase_string "$message")
  echo -e "${!color}${uppercase_message}${close_color_text}"
}

evaluate_terminal_dimensions() {
  dimensions=($(stty size))

  if [[ ${dimensions[0]} -lt 25 || ${dimensions[1]} -lt 60 ]]; then
    clear
    print_color_message red_text "recommended terminal size is 25 rows by 60 columns"
    sleep 3
  fi
}

display_subjects() {
  print_color_message blue_text "select a subject:"
  for i in "${!subjects[@]}"; do
    print_color_message yellow_text  "  $(( i + 1 )) ${subjects[$i]}"
  done
  print_color_message blue_text  "enter only the number that corresponds to your choice"
}

uppercase_string() {
  echo "$1" | tr "[:lower:]" "[:upper:]"
}

show_current_game_data() {
  echo -e "\n$uppercase_subject\n"
  echo -e "${stages[$stage]}\n\n"
  echo -e "$redacted_word\n\n"
  echo -e "$all_guesses\n\n"
}

choose_subject() {
  while true; do
    clear
    display_subjects
    read subject_choice

    if [[ $subject_choice -ge 1 && $subject_choice -le ${#subjects[@]} ]]; then
      subject_index=$(( subject_choice - 1 ))
      selected_words=(${words[$subject_index]})
      uppercase_subject=$(uppercase_string ${subjects[$subject_index]})
      
      random_word_index=$(( RANDOM % ${#selected_words[@]} ))
      random_word=${selected_words[$random_word_index]}
      word_with_spaces=$(echo "$random_word" | tr "_" " ")
      uppercase_random_word=$(uppercase_string "$word_with_spaces")

      if [[ -n $uppercase_random_word ]]; then
        clear
        print_color_message green_text "word chosen from ${subjects[$subject_index]}"
        sleep 1
  
        redacted_word=""
        for (( i = 0; i < ${#uppercase_random_word}; i++ )); do
           if [[ "${uppercase_random_word:$i:1}" == " " ]]; then
            redacted_word+="  "
          else
            redacted_word+="_ "
          fi
        done
        break
      else
        clear
        print_color_message red_text "an unexpected error occurred"
        exit 1
      fi
    else
      clear
      print_color_message red_text "select a valid subject"
      sleep 1
    fi
  done
}

process_guess() {
  clear
  while true; do
    show_current_game_data

    print_color_message blue_text "enter one letter or a complete guess:"
    read current_guess

    uppercase_current_guess=$(uppercase_string "$current_guess")

    if [[ -z "$uppercase_current_guess" ]]; then
      clear
      print_color_message red_text "guess cannot be empty"
    elif [[ ! "$uppercase_current_guess" =~ [A-Z] ]]; then
      clear
      print_color_message red_text "guess must be a letter"
    elif [[ ${#uppercase_current_guess} -ne 1 ]]; then
      clear
      if [[ $uppercase_current_guess == $uppercase_random_word ]]; then
        handle_win_or_loss green_text "you win!!"
      else
        update_graphic_for_incorrect_guess
      fi
    else
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
  for (( i = 0; i < ${#uppercase_random_word}; i++ )); do
    if [[ "${uppercase_random_word:$i:1}" == "$uppercase_current_guess" ]]; then
      new_redacted_word+="$uppercase_current_guess "
    else
      new_redacted_word+="${redacted_word:2 * i:1} "
    fi
  done
  redacted_word="$new_redacted_word"
  modified_redacted_word=$(echo "$redacted_word" | sed 's/  /__/g' | sed 's/ //g' | sed 's/__/ /g')
  
  if [[ "$modified_redacted_word" == "$uppercase_random_word" ]]; then
    handle_win_or_loss green_text "you win!!"
  else
    process_guess
  fi
}

update_graphic_for_incorrect_guess() {
  (( stage++ ))
  if [[ $stage -lt $(( ${#stages[@]} - 1 )) ]]; then
    process_guess
  else
    handle_win_or_loss red_text "game over!!"
  fi
}

handle_win_or_loss() {
  color=$1
  message=$2
  clear
  show_current_game_data
  print_color_message "$color" "$message"
  echo ""
  print_color_message blue_text "the solution was $word_with_spaces"
  sleep 5
  clear
  exit 0
}
#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -t --no-align -c"

echo -e "Enter your username:" 
read USERNAME

USER_VERIFY=$($PSQL "SELECT nm_username FROM users WHERE nm_username = '$USERNAME' ")
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING (username_id) WHERE nm_username = '$USERNAME' ")
BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games INNER JOIN users USING (username_id) WHERE nm_username = '$USERNAME'")


if [[ -z "$USER_VERIFY" ]]; then
  INSERT_USER=$($PSQL "INSERT INTO users(nm_username) VALUES ('$USERNAME') ")
  if [[ $INSERT_USER == "INSERT 0 1" ]]; then
    echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  fi
  else 
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

RANDOM_NUMBER=$((1 + $RANDOM % 1000))
GUESS_TRY=1
echo "RANDOM NUMBER" $RANDOM_NUMBER

echo "Guess the secret number between 1 and 1000:"
while read NUM; do
  
  if [[ ! $NUM =~ ^[0-9]+$ ]] || [[ -z $NUM ]]; then
     echo "That is not an integer, guess again:"
  else
      if (( $NUM == $RANDOM_NUMBER )); then
        break;
      else
          if (( $RANDOM_NUMBER > $NUM )); then
            echo "It's higher than that, guess again:"
          fi
          if (( $RANDOM_NUMBER < $NUM )); then
            echo "It's lower than that, guess again:"
          fi
      fi
  fi
GUESS_TRY=$((GUESS_TRY + 1))
done

echo "You guessed it in $GUESS_TRY tries. The secret number was $RANDOM_NUMBER. Nice job!"

SELECT_USER_ID=$($PSQL "SELECT username_id FROM users WHERE nm_username = '$USERNAME' ")
INSERT_GAME=$($PSQL "INSERT INTO games(number_guesses, username_id) VALUES ($GUESS_TRY, $SELECT_USER_ID) ")

#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$(( $RANDOM % 1000 + 1 ))
echo $NUMBER
USER_INPUT_VALIDATE() {
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    do
      echo "That is not an integer, guess again:"
      read USER_GUESS
    done
  fi
}
echo "Enter your username:"
read USERNAME
USER_GAMES=$($PSQL "select games_played, best_game from games where username='$USERNAME'")
if [[ -z $USER_GAMES ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_USER=$($PSQL "insert into games(username, games_played) values('$USERNAME', 0)")
else
  echo $USER_GAMES | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi
BEST_GUESS_THIS_GAME=1
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS
USER_INPUT_VALIDATE $USER_GUESS
if [[ $USER_GUESS = $NUMBER ]]
then
  INSERT_NEW_GAME_INFO=$($PSQL "update games set games_played = games_played + 1, best_game = $BEST_GUESS_THIS_GAME where username='$USERNAME'")
else
  until [[ $USER_GUESS = $NUMBER ]]
  do
    if [[ $USER_GUESS < $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    fi
    if [[ $USER_GUESS > $NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
    BEST_GUESS_THIS_GAME=$((BEST_GUESS_THIS_GAME + 1))
    read USER_GUESS
    USER_INPUT_VALIDATE $USER_GUESS
  done
  if [[ $BEST_GUESS_THIS_GAME < $BEST_GAME || -z $BEST_GAME ]]
  then
    BEST_GAME=$BEST_GUESS_THIS_GAME
  fi
  INSERT_NEW_GAME_INFO=$($PSQL "update games set games_played = games_played + 1, best_game = $BEST_GAME where username='$USERNAME'")
fi
echo "You guessed it in $BEST_GUESS_THIS_GAME tries. The secret number was $NUMBER. Nice job!"

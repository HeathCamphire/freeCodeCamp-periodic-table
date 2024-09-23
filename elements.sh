#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

MAIN_OUTPUT() {
  # if no input
  if [[ $1 ]]
  then
    # take atomic number from input
    # if input is number
    if [[ $1 =~ ^[0-9]+$ ]]
    then
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
    else
      # if not a number, either symbol or name
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1' OR name = '$1'")
    fi

    # if not found in database
    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo I could not find that element in the database.
    else
      # if found, output info
      ELEMENT_OUTPUT
    fi

  else
    # input not in database
    echo Please provide an element as an argument.
  fi
}

ELEMENT_OUTPUT() {
  # set variables
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
  NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")

  TYPE=$($PSQL "SELECT types.type FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
  ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM elements FULL JOIN properties USING(atomic_number) WHERE atomic_number=$ATOMIC_NUMBER")
  MELTING_POINT_CELSIUS=$($PSQL "SELECT melting_point_celsius FROM elements FULL JOIN properties USING(atomic_number) WHERE atomic_number=$ATOMIC_NUMBER")
  BOILING_POINT_CELSIUS=$($PSQL "SELECT boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) WHERE atomic_number=$ATOMIC_NUMBER")

  # output text
  echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
}

MAIN_OUTPUT $1
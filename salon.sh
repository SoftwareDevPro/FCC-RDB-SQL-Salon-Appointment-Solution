#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

DISPLAY_MENU()
{
  echo -e "Welcome to My Salon, how can I help you?\n"
  COUNT=$($PSQL "SELECT COUNT(*) FROM services")
  IDX=1
  while [[ $IDX -le $COUNT ]]
  do
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$IDX")
    echo "$IDX)$SERVICE"
    IDX=$(( IDX + 1 ))
  done
  GET_INPUT
}

CREATE_APPOINTMENT()
{
  customer_id=$($PSQL "SELECT customer_id FROM customers WHERE name='$2'")
  result=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($1, $customer_id, '$3')")
  if [[ -z $result ]]
  then
    echo -e "\nCreation of appointment failed."
  else
    echo -e "\nI have put you down for a$4 at $3, $2."
  fi
} 

GET_INPUT()
{
  read SERVICE_SELECTED
  
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_SELECTED'")
  echo $SERVICE

  if [[ -z $SERVICE ]]
  then 
    echo "I could not find that service. What would you like today?"
    DISPLAY_MENU
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    PHONE_RESULT=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    if [[ -z $PHONE_RESULT ]]
    then 
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      
      ADD_CUST=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
      
      read SERVICE_TIME
      CREATE_APPOINTMENT $SERVICE_SELECTED $CUSTOMER_NAME $SERVICE_TIME "$SERVICE"
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
      
      read SERVICE_TIME
      CREATE_APPOINTMENT $SERVICE_SELECTED $CUSTOMER_NAME $SERVICE_TIME "$SERVICE"
    fi
  fi
}

DISPLAY_MENU

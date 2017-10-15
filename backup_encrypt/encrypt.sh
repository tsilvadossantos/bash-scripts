#!/bin/env bash
# Encrypt file, version 1
# Run as root.
#Usage: bash encrypt.sh FILENAME or bash encrypt.sh --help

#get ENCRYPTION_KEY env variable
key=$(printenv ENCRYPTION_KEY)

#Check if user passed filename parameter
if [ -z "$1" ]
then
  echo "Error: Filename parameter was not provided "
  exit 2
elif [ "$1" == "--help" ]
then
  echo "Usage: `basename $0` Encrypt files, filename must be provided as parameter"
fi

#execute openssl to encrypt $1, however it will test whether env variable has been created
#if ENCRYPTION_KEY is not created, user is required to type a password
if [ -z "$key" ]
then
  echo "Enter the password: "
  read ENCRYPTION_KEY
  openssl enc -e -aes256 -in $1 -out $1.enc -pass pass:$ENCRYPTION_KEY
else
  openssl enc -e -aes256 -in $1 -out $1.enc -pass env:ENCRYPTION_KEY
fi

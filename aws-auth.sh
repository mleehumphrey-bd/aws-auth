#!/bin/bash

function usage () {
   cat <<EOF

Usage: $0 options

options:
   -m   arn of your virtual mfa device
EOF
   exit
}

while getopts "m:" OPTION
do
  case $OPTION in
    m)
      mfa_serial_number=$OPTARG
      ;;
    *)
      usage;
      exit 1
      ;;
  esac
done

if [ ! "$mfa_serial_number" ]
then
  usage
  exit 1
else
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN

  token_code=$(ykman oath code | perl -pe "s/.* +(\d+)$/\1/g;")
  output=$(aws sts get-session-token --serial-number $mfa_serial_number --token-code $token_code)

  aws_access_key_id=$(echo $output | jq -r '.Credentials.AccessKeyId')
  aws_secret_access_key=$(echo $output | jq -r '.Credentials.SecretAccessKey')
  aws_session_token=$(echo $output | jq -r '.Credentials.SessionToken')

  export AWS_ACCESS_KEY_ID=$aws_access_key_id
  export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
  export AWS_SESSION_TOKEN=$aws_session_token

  echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
  echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
  echo "AWS_SESSION_TOKEN: $AWS_SESSION_TOKEN"
fi


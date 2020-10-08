#!/bin/bash

OPTIND=1

usage () {
echo "
Usage: . ./aws-auth.sh options

options:
   -m   arn of your virtual mfa device
   -t   token generated by your mfa device
"
   return
}

while getopts ":m:t:p:" OPTION
do
  case $OPTION in
    m)
      mfa_serial_number=$OPTARG
      ;;
    t)
      token_code=$OPTARG
      ;;
    p)
      aws_profile=$OPTARG
      ;;
    *)
      usage;
      return 1
      ;;
  esac
done

shift "$((OPTIND-1))"

if [ ! "$mfa_serial_number" ] || [ ! "$token_code" ] || [ ! "$aws_profile" ]
then
  # require mfa arn and token code
  usage
  return 1
else
  if [ -z "$AWS_EXPIRATION" ]
  then
    # haven't authorized
    do_auth=true
  else
    current_date=($(date -u +"%Y-%m-%dT%H:%M:%SZ"))

    if [[ "$current_date" < "$AWS_EXPIRATION" ]]
    then
      # valid session token
      do_auth=false
    else
      # expired session token
      do_auth=true
    fi
  fi

  if [ "$do_auth" = true ]
  then
    echo -e "session token expired. retrieving temporary credentials...\n"

    # unset and set authorization temporary credentials via environment variables
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_EXPIRATION

    output=($(aws sts get-session-token --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken,Expiration]' --output text --serial-number $mfa_serial_number --token-code $token_code --profile $aws_profile --duration-seconds 19200))
    export AWS_ACCESS_KEY_ID="${output[1]}" AWS_SECRET_ACCESS_KEY="${output[2]}" AWS_SESSION_TOKEN="${output[3]}" AWS_EXPIRATION="${output[4]}"

    # echo "token_code: $token_code"
    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
    echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
    echo "AWS_SESSION_TOKEN: $AWS_SESSION_TOKEN"
    echo "AWS_EXPIRATION: $AWS_EXPIRATION"
  else
    echo -e "session token valid. expiration date: $AWS_EXPIRATION\n"
  fi
fi

# aws-auth
bash script for aws cli authentication using an mfa token

# REQUIREMENTS
  oauth totp code generator (e.g https://developers.yubico.com/yubikey-manager/)
  jq (https://stedolan.github.io/jq/)

# USAGE

```
  . ./aws-auth.sh {OPTIONS}
  
  Example:  ./aws-auth -m arn:aws:iam::12345678:mfa/reuel -t 884123

OPTIONS:

   -m   arn of your virtual mfa device

```
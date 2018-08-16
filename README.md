# aws-auth
bash script for aws cli authentication using an mfa token. source the script instead of just executing it so it preserves the newly set environment.

# REQUIREMENTS
  [jq](https://stedolan.github.io/jq/)

# USAGE

```
  . ./aws-auth.sh {OPTIONS}
  
  Example:  . ./aws-auth -m arn:aws:iam::12345678:mfa/reuel -t 884123

OPTIONS:

   -m   arn of your virtual mfa device
   -t   token generated by your mfa device

```

you can use a command line token generator (e.g. [YubiKey Manager CLI](https://developers.yubico.com/yubikey-manager/)) and run:  
```
 . ./aws-auth.sh -m arn:aws:iam::12345678:mfa/reuel -t `ykman oath code | perl -pe "s/.* +(\d+)$/\1/g;"`
```

# I need to deploy docker container

## SETUP

create aws creds and put them in `~/.aws/credentials`

```
[projectname]
aws_access_key_id = xyz
aws_secret_access_key = xyz
```

copy over files

setup kms key using `aws-kms-keygen.sh`

search and replace `projectname`, `projectrootdomain`

initialize terraform state

```
cd infrastructure/terraform/shared/tfstate
terraform init
terraform apply
cd -
```

apply rest of terraform infrastructure

```
./infrastructure/scripts/terraform.sh shared network init
./infrastructure/scripts/terraform.sh shared network apply
# ...
```


## USAGE
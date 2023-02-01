<h1 align="center">infrastructure as code example</h1>

work in progress!

## How to use

```
ssh-keygen -t ed25519 -C "example-dev" -N "" -f ../example-dev
```

```
aws s3api create-bucket --bucket example-tfstate --acl private --region eu-central-1
aws s3api put-public-access-block --bucket example-tfstate --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

```
terraform init -backend-config ./env/dev/state.tfvars -reconfigure
terraform apply -var-file ./env/dev/config.tfvars
```
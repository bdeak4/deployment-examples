<h1 align="center">infrastructure as code example</h1>

work in progress!

## How to use

```
ssh-keygen -t ed25519 -C "example-dev" -N "" -f ../example-dev
```

```
terraform init -backend-config ./env/dev/state.tfvars -reconfigure
terraform apply -var-file ./env/dev/config.tfvars
```
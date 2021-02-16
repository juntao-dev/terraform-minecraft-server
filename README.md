# SET UP

Set up AWS CLI

Install Terraform

To start, run

```sh
terraform init
terraform apply
```

When deployed, the server IP would be shown. Connect via <IP>:25565
(It would take a few minutes for the server to be ready)

Terraform would create a bunch of files in the local dir to maintain state (do not touch or delete them!)

When finished, run

```sh
terraform destroy
```

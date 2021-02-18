# SET UP

Set up AWS CLI

Install Terraform

### Fill in the following details

1.  S3 bucket name in `main.tf`

```
locals {
  minecraft_backup_s3_bucket_name = ""
}
```

2. SSH Public Key in `script.sh`

```sh
echo "" >> /home/ec2-user/.ssh/authorized_keys
```

```sh
terraform init
terraform apply
```

---

When deployed, the server IP would be shown. Connect via <IP>:25565
(It would take a few minutes for the server to be ready)

Terraform would create a bunch of files in the local dir to maintain state (do not touch or delete them!)

When finished, run the following command to destroy the stack (replace `<s3_bucket_name>`)

If an error shows up saying that the bucket is not empty, run both commands again.

```sh
aws s3 rm --recursive s3://<s3_bucket_name>

terraform destroy
```

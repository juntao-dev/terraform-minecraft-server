# SET UP

Set up AWS CLI

Install Terraform

### Fill in the following details

1.  S3 bucket name in `main.tf`. Note that S3 bucket names must be unique (simple names would most likely have been taken by someone else).

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

When the `terraform apply` command is run, it would prompt you to confirm the changes. This set up would also create a number of folders and files in your local server. Make sure that you DON'T alter or remove those files.

---

When deployed, the server IP would be shown. Connect via <IP>:25565
(It would take a few minutes for the server to be ready).

SSH into the server by running

```sh
ssh ec2-user@<IP>
```

---

Note: You might need to add `sudo` to the start of the command if you encounter permission issues.

The server is being run using `screen` as a system service. To list all the screens running in the background, run command `screen -ls` in the terminal (you can find an id mapped to each screen).

To get into that screen, run command `screen -r <screen_id>`. By default, you should only see only one screen listed. In this case, you can also just run `screen -r` to reattach that screen.

To detach that screen and move back to the original login process screen, type `Ctrl` + `a`, release both, then type `d`.

---

The world folder would automatically be compressed and backed up to S3 every couple of minutes.

When finished, run the following command to destroy the stack (replace `<s3_bucket_name>`). You cannot delete a bucket using `terraform destroy` if your bucket is not empty. So download a copy of that world file from your S3 bucket and delete the hosted version before destroying your stack.

If an error shows up saying that the bucket is not empty, run both commands again.

Note: replace `<s3_bucket_name>` with your bucket name (x2) before running the following commands.

```sh

aws s3api list-object-versions --bucket <s3_bucket_name> --prefix world | grep VersionId | cut -f4 -d \" | xargs -I % aws s3api delete-object --bucket <s3_bucket_name> --key world.tar.gz --version-id %

terraform destroy
```

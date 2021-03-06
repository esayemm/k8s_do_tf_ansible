## Prereqs

- terraform-inventory
- cfssl
- kubectl

Dynamic inventory script for terraform. Need this for getting host ips from terraform state for use with ansible.

```sh
brew install terraform-inventory
```

#### Env Vars

Terraform digitalocean provider needs a valid digitalocean token, and each node requires ssh fingerprint so ansible can ssh into each machine to do it's thing.

- `DO_TOKEN` [tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2)<br>
- `DO_SSH_FINGERPRINT` [tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets)

*note: use this command to get the md5 of the key, use this as ssh_fingerprint*

```sh
ssh-keygen -E md5 -lf ~/.ssh/do_rsa.pub | awk '{print $2}' | sed "s/^MD5://"
```

## Instructions

### Create terraform.tfvars file

```sh
./scripts/create_tfvars.sh -o . -d <digital ocean token> -s <md5 ssh fingerprint>
```

### Generate CA

```sh
mkdir certs
./scripts/generate_certs.sh -o ./certs
```

### Terraform apply

```sh
terraform get
terraform plan
terraform apply
```

### Ansible

```sh
# might have to add this first, or whatever you named your do key
ssh-add ~/.ssh/do_rsa 

ansible-playbook --inventory-file=$(which terraform-inventory) -u root cluster.yml
```

### Local kubectl

Install kubectl locally

```
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.0/bin/darwin/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin
```

Make sure you have kubectl installed locally before running this script

```sh
./scripts/setup-kubectl.sh -k $(terraform output kube-controller_ips) -t <token> -c ./certs/ca.pem
```

Check that it works

```sh
kubectl get componentstatuses
kubectl get nodes
```

(Optional) Deploy the kontinuum server

Edit `addons/kontinuum.yml` and add kubernetes controller ip

```sh
kubectl apply -f ./addons/kontinuum.yml
```

## Dev

Terraform is used for infrastructure and Ansible is responsible for bootstrapping.

The main ansible file is `cluster.yml` this is the top level file responsible for configuring machines with roles. `roles/set-facts` will have variables that the other roles uses.

### Ansible

Run on a particular resource use the `--limit <name of resource>` flag

```sh
ansible-playbook --inventory-file=$(which terraform-inventory) -u root --limit loadbalancer cluster.yml
```

Only apply certain roles by using the tags flag `--tags foo,bar`

```sh
ansible-playbook --inventory-file=$(which terraform-inventory) -u root --tags foo,bar cluster.yml
```
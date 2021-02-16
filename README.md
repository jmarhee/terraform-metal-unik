# UniK on Equinix Metal

[UniK](https://github.com/solo-io/unik) is a tool for compiling application sources into unikernels (lightweight bootable disk images) and MicroVM rather than binaries.

This module configures UniK an [Equinix Metal](https://metal.equinix.com) bare metal instance, and configures the VirtualBox and QEMU provider to run your unikernels.

A host-only network, and `tap` interface is configured for use with QEMU. 

## Setup

This requires an [Equinix Metal](https://console.equinix.com) account, and you will need an [API token](https://metal.equinix.com/developers/api/).

Save this token in `terraform.tfvars`:

```hcl
auth_token = "<Your Metal API token>"
```

or save to `TF_VAR_auth_token`. 

## Usage

Your auth token, set above,  is the only required variable, after this is set, in your plan, to import the module, add the following to your plan file:

```hcl
module "unik" {
  source  = "jmarhee/unik/metal"
  version = "0.1.0"
  auth_token = var.auth_token
}
```

and apply:

```bash
terraform init
terraform apply
```

Once it's done, you will receive login information:

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

unik_node =
	ssh -i metal-key-unik-{KeyID} root@{PublicIP}
```

and you can proceed to [create your unikernel for your application type](https://github.com/solo-io/unik#documentation).

# Ansible playbook to apply Microsoft Windows Server 2016 GSA Baseline

A security baseline is a group of Microsoft-recommended configuration settings that explains their security impact. These settings are based on feedback from Microsoft security engineering teams, product groups, partners, and customers.

This Ansible playbook can be used to configure Windows Server 2016 to be GSA compliant. It is based on GSA Microsoft Windows Server 2016 Security Benchmark v1.0 but it is NOT 100% compatible. Some settings related to Ansible / WinRM will not be applied to make the remote administration possible:

* Ensure 'Allow remote server management through WinRM' is set to 'Disabled'
* Configure 'Deny log on through Remote Desktop Services' to include local accounts

Please, review the playbook and test it before you run it on a production machine. For testing purposes, you can spin up a AWS EC2 instance running Windows Server 2016 Base. Use Nessus or any other security scanner to verify the hardening.
 

## Ansible Tags

The playbook provides a number of tags to help you filter out some task:

* Common Configuration Enumeration (CCE) assignet to every task (e.g. CCE-37166-6)
* 'desktop'
* 'drivers'
* 'firewall'
* 'passwords'
* 'powershell'
* 'remote_desktop'
* 'uac' 
* 'windows_update'
* 'winrm'

Add `--tags "tag_name"` or `--skip-tags "tag_name"` to allow or deny specific tags.

## Usage

Start your Windows Server 2016 machine, prepare your inventory and run:

```ansible-playbook playbooks/windows_server_2016_gsa.yml```

Please note that the last task will change the Administrator account name so you will have to reconnect if you want to perform extra tasks.

### AWS testing environment

If you want to use AWS to test the playbook, you can use the provided terraform setup (./terraform/windows_server_2016_ec2.tf). It will spin up a t2.micro instance in the eu-west-2 region. When the instance is up and running, copy it's IP address (terraform will output the public IP) and update the inventory.ini file. Included PowerShell script will automatically enable Ansible so you do not have to do anything else.

If you are in the `terraform` directory, do `cd ..` and run the playbook:

```ansible-playbook -i inventory.ini ansible-playbook -i inventory.ini playbooks/windows_server_2016_gsa.yml```

If you get an error looking like this:

```
fatal: [10.0.0.1]: UNREACHABLE! => {"changed": false, "msg": "ssl: HTTPSConnectionPool(host='10.0.0.1', port=5986): Max retries exceeded with url: /wsman (Caused by NewConnectionError('<urllib3.connecti
on.VerifiedHTTPSConnection object at 0x7fba72f17128>: Failed to establish a new connection: [Errno 111] Connection refused',))", "unreachable": true} 
```

you will have to wait a minute or two and try again. Don't forget to destroy the infrastructure when you finish testing.
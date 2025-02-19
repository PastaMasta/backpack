AWS Aliases
===============================================

Here are some extensions for the AWS CLI, copy into `~/.aws/cli/alias`

`--output whatevet` is mostly honored

TopLevel
-------------------

`aws whoami` - `aws sts get-caller-identity` - returns who you are coming in to AWS as
```
$ aws whoami
{
    "UserId": "AAAAAAAAAAAAAAAAAAAAA:user@example.com",
    "Account": "123456789012",
    "Arn": "arn:aws:sts::590183858356:assumed-role/somerole/user@example.com"
}
$
```

`aws profiles` - list config profiles in `~/.aws/config`
```
$ aws profiles
profile1
profile1_ro
etc
$
```

Secrets Manager
-------------------

`aws secretsmanager ls` - lists out secrets in secrets manager
```
$ aws secretsmanager ls
/some/secret
$
```

`aws secretsmanager get /some/secret` - gets the specified secret string
```
$ aws secretsmanager get /some/secret
password123
$
```

Cloudformation
-------------------

`aws cf` - alias for `aws cloudformation`

`aws cf ls` - lists cloudformation stacks
```
$ aws cf ls
StackSet-example
somestack
$
```

SSM
-------------------

`aws ssm ls /some/path` - lists SSM paramiters by path
```
$ aws ssm ls /
/example/1
/someparam
$
```

`aws ssm get /some/param` - gets the string result
```
$ aws ssm get /some/param
hello!
$
```

ec2
-------------------

`aws ec2 ls` - lists ec2 instances by name tag and instance ID
```
$ aws ec2 ls
i-1234 jumphost
$
```

`aws ec2 login i-1234 bash` - opens up a shell on the ec2 instance via SSM, can use instance ID or name tag, can also just run adhoc commands
```
$ aws ec2 login i-1234

Starting session with SessionId: user@example.com-1234asdvacds
[ssm-user@ip-10-0-0-1 bin]$ exit
exit


Exiting session with sessionId: user@example.com-1234asdvacds.

$
```

`aws ec2 rdp i-1234` - attempts to RDP to the ec2 instance via SSM agent / port forwarding - will launch mstsc.exe if you're on wsl

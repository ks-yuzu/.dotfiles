#compdef _eksctl eksctl


function _eksctl {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "create:Create resource(s)"
      "get:Get resource(s)"
      "update:Update resource(s)"
      "upgrade:Upgrade resource(s)"
      "delete:Delete resource(s)"
      "set:Set values"
      "unset:Unset values"
      "scale:Scale resources(s)"
      "drain:Drain resource(s)"
      "utils:Various utils"
      "completion:Generates shell completion scripts"
      "version:Output the version of eksctl"
      "help:Help about any command"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  create)
    _eksctl_create
    ;;
  get)
    _eksctl_get
    ;;
  update)
    _eksctl_update
    ;;
  upgrade)
    _eksctl_upgrade
    ;;
  delete)
    _eksctl_delete
    ;;
  set)
    _eksctl_set
    ;;
  unset)
    _eksctl_unset
    ;;
  scale)
    _eksctl_scale
    ;;
  drain)
    _eksctl_drain
    ;;
  utils)
    _eksctl_utils
    ;;
  completion)
    _eksctl_completion
    ;;
  version)
    _eksctl_version
    ;;
  help)
    _eksctl_help
    ;;
  esac
}


function _eksctl_create {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "cluster:Create a cluster"
      "nodegroup:Create a nodegroup"
      "iamserviceaccount:Create an iamserviceaccount - AWS IAM role bound to a Kubernetes service account"
      "iamidentitymapping:Create an IAM identity mapping"
      "fargateprofile:Create a Fargate profile"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  cluster)
    _eksctl_create_cluster
    ;;
  nodegroup)
    _eksctl_create_nodegroup
    ;;
  iamserviceaccount)
    _eksctl_create_iamserviceaccount
    ;;
  iamidentitymapping)
    _eksctl_create_iamidentitymapping
    ;;
  fargateprofile)
    _eksctl_create_fargateprofile
    ;;
  esac
}

function _eksctl_create_cluster {
  _arguments \
    '--alb-ingress-access[enable full access for alb-ingress-controller]' \
    '--appmesh-access[enable full access to AppMesh]' \
    '--asg-access[enable IAM policy for cluster-autoscaler]' \
    '--authenticator-role-arn[AWS IAM role to assume for authenticator]:' \
    '--auto-kubeconfig[save kubeconfig file by cluster name, e.g. "/Users/yuki.osako/.kube/eksctl/clusters/extravagant-badger-1581992561"]' \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--external-dns-access[enable IAM policy for external-dns]' \
    '--fargate[Create a Fargate profile scheduling pods in the default and kube-system namespaces onto Fargate]' \
    '--full-ecr-access[enable full access to ECR]' \
    '--install-vpc-controllers[Install VPC controller that'\''s required for Windows workloads]' \
    '--kubeconfig[path to write kubeconfig (incompatible with --auto-kubeconfig)]:' \
    '--managed[Create EKS-managed nodegroup]' \
    '--max-pods-per-node[maximum number of pods per node (set automatically if unspecified)]:' \
    '(-n --name)'{-n,--name}'[EKS cluster name (generated if unspecified, e.g. "extravagant-badger-1581992561")]:' \
    '--node-ami[Advanced use cases only. If '\''static'\'' is supplied (default) then eksctl will use static AMIs; if '\''auto'\'' is supplied then eksctl will automatically set the AMI based on version/region/instance type; if any other value is supplied it will override the AMI to use for the nodes. Use with extreme care.]:' \
    '--node-ami-family[Advanced use cases only. If '\''AmazonLinux2'\'' is supplied (default), then eksctl will use the official AWS EKS AMIs (Amazon Linux 2); if '\''Ubuntu1804'\'' is supplied, then eksctl will use the official Canonical EKS AMIs (Ubuntu 18.04).]:' \
    '--node-labels[Extra labels to add when registering the nodes in the nodegroup, e.g. "partition=backend,nodeclass=hugememory"]:' \
    '(-P --node-private-networking)'{-P,--node-private-networking}'[whether to make nodegroup networking private]' \
    '*--node-security-groups[Attach additional security groups to nodes, so that it can be used to allow extra ingress/egress access from/to pods]:' \
    '(-t --node-type)'{-t,--node-type}'[node instance type]:' \
    '--node-volume-size[node volume size in GB]:' \
    '--node-volume-type[node volume type (valid options: gp2, io1, sc1, st1)]:' \
    '*--node-zones[(inherited from the cluster if unspecified)]:' \
    '--nodegroup-name[name of the nodegroup (generated if unspecified, e.g. "ng-d724d7c5")]:' \
    '(-N --nodes)'{-N,--nodes}'[total number of nodes (for a static ASG)]:' \
    '(-M --nodes-max)'{-M,--nodes-max}'[maximum nodes in ASG]:' \
    '(-m --nodes-min)'{-m,--nodes-min}'[minimum nodes in ASG]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--set-kubeconfig-context[if true then current-context will be set in kubeconfig; if a context is already set then it will be overwritten]' \
    '--ssh-access[control SSH access for nodes. Uses ~/.ssh/id_rsa.pub as default key path if enabled]' \
    '--ssh-public-key[SSH public key to use for nodes (import from local path, or use existing EC2 key pair)]:' \
    '--tags[A list of KV pairs used to tag the AWS resources (e.g. "Owner=John Doe,Team=Some Team")]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '--version[Kubernetes version (valid options: 1.12, 1.13, 1.14)]:' \
    '--vpc-cidr[global CIDR to use for VPC]:' \
    '--vpc-from-kops-cluster[re-use VPC from a given kops cluster]:' \
    '--vpc-nat-mode[VPC NAT mode, valid options: HighlyAvailable, Single, Disable]:' \
    '*--vpc-private-subnets[re-use private subnets of an existing VPC]:' \
    '*--vpc-public-subnets[re-use public subnets of an existing VPC]:' \
    '--without-nodegroup[if set, initial nodegroup will not be created]' \
    '--write-kubeconfig[toggle writing of kubeconfig]' \
    '*--zones[(auto-select if unspecified)]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_create_nodegroup {
  _arguments \
    '--alb-ingress-access[enable full access for alb-ingress-controller]' \
    '--appmesh-access[enable full access to AppMesh]' \
    '--asg-access[enable IAM policy for cluster-autoscaler]' \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '--cluster[name of the EKS cluster to add the nodegroup to]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '*--exclude[nodegroups to exclude (list of globs), e.g.: '\''ng-team-?,prod-*'\'']:' \
    '--external-dns-access[enable IAM policy for external-dns]' \
    '--full-ecr-access[enable full access to ECR]' \
    '*--include[nodegroups to include (list of globs), e.g.: '\''ng-team-?,prod-*'\'']:' \
    '--managed[Create EKS-managed nodegroup]' \
    '--max-pods-per-node[maximum number of pods per node (set automatically if unspecified)]:' \
    '(-n --name)'{-n,--name}'[name of the new nodegroup (generated if unspecified, e.g. "ng-55858656")]:' \
    '--node-ami[Advanced use cases only. If '\''static'\'' is supplied (default) then eksctl will use static AMIs; if '\''auto'\'' is supplied then eksctl will automatically set the AMI based on version/region/instance type; if any other value is supplied it will override the AMI to use for the nodes. Use with extreme care.]:' \
    '--node-ami-family[Advanced use cases only. If '\''AmazonLinux2'\'' is supplied (default), then eksctl will use the official AWS EKS AMIs (Amazon Linux 2); if '\''Ubuntu1804'\'' is supplied, then eksctl will use the official Canonical EKS AMIs (Ubuntu 18.04).]:' \
    '--node-labels[Extra labels to add when registering the nodes in the nodegroup, e.g. "partition=backend,nodeclass=hugememory"]:' \
    '(-P --node-private-networking)'{-P,--node-private-networking}'[whether to make nodegroup networking private]' \
    '*--node-security-groups[Attach additional security groups to nodes, so that it can be used to allow extra ingress/egress access from/to pods]:' \
    '(-t --node-type)'{-t,--node-type}'[node instance type]:' \
    '--node-volume-size[node volume size in GB]:' \
    '--node-volume-type[node volume type (valid options: gp2, io1, sc1, st1)]:' \
    '*--node-zones[(inherited from the cluster if unspecified)]:' \
    '(-N --nodes)'{-N,--nodes}'[total number of nodes (for a static ASG)]:' \
    '(-M --nodes-max)'{-M,--nodes-max}'[maximum nodes in ASG]:' \
    '(-m --nodes-min)'{-m,--nodes-min}'[minimum nodes in ASG]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--ssh-access[control SSH access for nodes. Uses ~/.ssh/id_rsa.pub as default key path if enabled]' \
    '--ssh-public-key[SSH public key to use for nodes (import from local path, or use existing EC2 key pair)]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '--update-auth-configmap[Remove nodegroup IAM role from aws-auth configmap]' \
    '--version[Kubernetes version (valid options: 1.12, 1.13, 1.14) [for nodegroups "auto" and "latest" can be used to automatically inherit version from the control plane or force latest]]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_create_iamserviceaccount {
  _arguments \
    '--approve[Apply the changes]' \
    '*--attach-policy-arn[ARN of the policy where to create the iamserviceaccount]:' \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '--cluster[name of the EKS cluster to add the iamserviceaccount to]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '*--exclude[iamserviceaccounts to exclude (list of globs), e.g.: '\''default/s3-reader,*/dynamo-*'\'']:' \
    '*--include[iamserviceaccounts to include (list of globs), e.g.: '\''default/s3-reader,*/dynamo-*'\'']:' \
    '--name[name of the iamserviceaccount to create]:' \
    '--namespace[namespace where to create the iamserviceaccount]:' \
    '--override-existing-serviceaccounts[create IAM roles for existing serviceaccounts and update the serviceaccount]' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_create_iamidentitymapping {
  _arguments \
    '--arn[ARN of the IAM role or user to create]:' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '*--group[Group within Kubernetes to which IAM role is mapped]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '--username[User name within Kubernetes to map to IAM role]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_create_fargateprofile {
  _arguments \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-l --labels)'{-l,--labels}'[Kubernetes selector labels of the workloads to schedule on Fargate, e.g. k1=v1,k2=v2]:' \
    '--name[Fargate profile'\''s name]:' \
    '--namespace[Kubernetes namespace of the workloads to schedule on Fargate]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_get {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "cluster:Get cluster(s)"
      "nodegroup:Get nodegroup(s)"
      "iamserviceaccount:Get iamserviceaccount(s)"
      "iamidentitymapping:Get IAM identity mapping(s)"
      "labels:Get nodegroup labels"
      "fargateprofile:Get Fargate profile(s)"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  cluster)
    _eksctl_get_cluster
    ;;
  nodegroup)
    _eksctl_get_nodegroup
    ;;
  iamserviceaccount)
    _eksctl_get_iamserviceaccount
    ;;
  iamidentitymapping)
    _eksctl_get_iamidentitymapping
    ;;
  labels)
    _eksctl_get_labels
    ;;
  fargateprofile)
    _eksctl_get_fargateprofile
    ;;
  esac
}

function _eksctl_get_cluster {
  _arguments \
    '(-A --all-regions)'{-A,--all-regions}'[List clusters across all supported regions]' \
    '--chunk-size[return large lists in chunks rather than all at once, pass 0 to disable]:' \
    '(-n --name)'{-n,--name}'[EKS cluster name]:' \
    '(-o --output)'{-o,--output}'[specifies the output format (valid option: table, json, yaml)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_get_nodegroup {
  _arguments \
    '--chunk-size[return large lists in chunks rather than all at once, pass 0 to disable]:' \
    '--cluster[EKS cluster name]:' \
    '(-n --name)'{-n,--name}'[Name of the nodegroup]:' \
    '(-o --output)'{-o,--output}'[specifies the output format (valid option: table, json, yaml)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_get_iamserviceaccount {
  _arguments \
    '--chunk-size[return large lists in chunks rather than all at once, pass 0 to disable]:' \
    '--cluster[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--name[name of the iamserviceaccount to delete]:' \
    '--namespace[namespace where to delete the iamserviceaccount]:' \
    '(-o --output)'{-o,--output}'[specifies the output format (valid option: table, json, yaml)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_get_iamidentitymapping {
  _arguments \
    '--arn[ARN of the IAM role or user to create]:' \
    '--chunk-size[return large lists in chunks rather than all at once, pass 0 to disable]:' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-o --output)'{-o,--output}'[specifies the output format (valid option: table, json, yaml)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_get_labels {
  _arguments \
    '--cluster[EKS cluster name]:' \
    '(-n --nodegroup)'{-n,--nodegroup}'[Nodegroup name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_get_fargateprofile {
  _arguments \
    '--chunk-size[return large lists in chunks rather than all at once, pass 0 to disable]:' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--name[Fargate profile'\''s name]:' \
    '(-o --output)'{-o,--output}'[specifies the output format (valid option: table, json, yaml)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_update {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "cluster:Update cluster"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  cluster)
    _eksctl_update_cluster
    ;;
  esac
}

function _eksctl_update_cluster {
  _arguments \
    '--approve[Apply the changes]' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-n --name)'{-n,--name}'[EKS cluster name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_upgrade {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "nodegroup:Upgrade nodegroup"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  nodegroup)
    _eksctl_upgrade_nodegroup
    ;;
  esac
}

function _eksctl_upgrade_nodegroup {
  _arguments \
    '--cluster[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--kubernetes-version[Kubernetes version]:' \
    '--name[Nodegroup name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_delete {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "cluster:Delete a cluster"
      "nodegroup:Delete a nodegroup"
      "iamserviceaccount:Delete an IAM service account"
      "iamidentitymapping:Delete a IAM identity mapping"
      "fargateprofile:Delete Fargate profile"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  cluster)
    _eksctl_delete_cluster
    ;;
  nodegroup)
    _eksctl_delete_nodegroup
    ;;
  iamserviceaccount)
    _eksctl_delete_iamserviceaccount
    ;;
  iamidentitymapping)
    _eksctl_delete_iamidentitymapping
    ;;
  fargateprofile)
    _eksctl_delete_fargateprofile
    ;;
  esac
}

function _eksctl_delete_cluster {
  _arguments \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-n --name)'{-n,--name}'[EKS cluster name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-w --wait)'{-w,--wait}'[wait for deletion of all resources before exiting]' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_delete_nodegroup {
  _arguments \
    '--approve[Apply the changes]' \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '--cluster[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--drain[Drain and cordon all nodes in the nodegroup before deletion]' \
    '*--exclude[nodegroups to exclude (list of globs), e.g.: '\''ng-team-?,prod-*'\'']:' \
    '*--include[nodegroups to include (list of globs), e.g.: '\''ng-team-?,prod-*'\'']:' \
    '(-n --name)'{-n,--name}'[Name of the nodegroup to delete]:' \
    '--only-missing[Only delete nodegroups that are not defined in the given config file]' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '--update-auth-configmap[Remove nodegroup IAM role from aws-auth configmap]' \
    '(-w --wait)'{-w,--wait}'[wait for deletion of all resources before exiting]' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_delete_iamserviceaccount {
  _arguments \
    '--approve[Apply the changes]' \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '--cluster[name of the EKS cluster to delete the iamserviceaccount from]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '*--exclude[iamserviceaccounts to exclude (list of globs), e.g.: '\''default/s3-reader,*/dynamo-*'\'']:' \
    '*--include[iamserviceaccounts to include (list of globs), e.g.: '\''default/s3-reader,*/dynamo-*'\'']:' \
    '--name[name of the iamserviceaccount to delete]:' \
    '--namespace[namespace where to delete the iamserviceaccount]:' \
    '--only-missing[Only delete nodegroups that are not defined in the given config file]' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-w --wait)'{-w,--wait}'[wait for deletion of all resources before exiting]' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_delete_iamidentitymapping {
  _arguments \
    '--all[Delete all matching mappings instead of just one]' \
    '--arn[ARN of the IAM role or user to create]:' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_delete_fargateprofile {
  _arguments \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--name[Fargate profile'\''s name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-w --wait)'{-w,--wait}'[wait for wait for the deletion of the Fargate profile, which may take from a couple seconds to a couple minutes. before exiting]' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_set {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "labels:Create or overwrite labels"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  labels)
    _eksctl_set_labels
    ;;
  esac
}

function _eksctl_set_labels {
  _arguments \
    '--cluster[EKS cluster name]:' \
    '(-l --labels)'{-l,--labels}'[Create Labels]:' \
    '(-n --nodegroup)'{-n,--nodegroup}'[Nodegroup name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_unset {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "labels:Create removeLabels"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  labels)
    _eksctl_unset_labels
    ;;
  esac
}

function _eksctl_unset_labels {
  _arguments \
    '--cluster[EKS cluster name]:' \
    '(*-l *--labels)'{\*-l,\*--labels}'[List of labels to remove]:' \
    '(-n --nodegroup)'{-n,--nodegroup}'[Nodegroup name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_scale {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "nodegroup:Scale a nodegroup"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  nodegroup)
    _eksctl_scale_nodegroup
    ;;
  esac
}

function _eksctl_scale_nodegroup {
  _arguments \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '--cluster[EKS cluster name]:' \
    '(-n --name)'{-n,--name}'[Name of the nodegroup to scale]:' \
    '(-N --nodes)'{-N,--nodes}'[total number of nodes (scale to this number)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_drain {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "nodegroup:Cordon and drain a nodegroup"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  nodegroup)
    _eksctl_drain_nodegroup
    ;;
  esac
}

function _eksctl_drain_nodegroup {
  _arguments \
    '--approve[Apply the changes]' \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '--cluster[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '*--exclude[nodegroups to exclude (list of globs), e.g.: '\''ng-team-?,prod-*'\'']:' \
    '*--include[nodegroups to include (list of globs), e.g.: '\''ng-team-?,prod-*'\'']:' \
    '(-n --name)'{-n,--name}'[Name of the nodegroup to delete]:' \
    '--only-missing[Only drain nodegroups that are not defined in the given config file]' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '--undo[Uncordone the nodegroup]' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_utils {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "wait-nodes:Wait for nodes"
      "write-kubeconfig:Write kubeconfig file for a given cluster"
      "describe-stacks:Describe CloudFormation stack for a given cluster"
      "update-cluster-stack:DEPRECATED: Use 'eksctl update cluster' instead"
      "update-kube-proxy:Update kube-proxy add-on to ensure image matches Kubernetes control plane version"
      "update-aws-node:Update aws-node add-on to latest released version"
      "update-coredns:Update coredns add-on to ensure image matches the standard Amazon EKS version"
      "update-cluster-logging:Update cluster logging configuration"
      "associate-iam-oidc-provider:Setup IAM OIDC provider for a cluster to enable IAM roles for pods"
      "install-vpc-controllers:Install Windows VPC controller to support running Windows workloads"
      "update-cluster-endpoints:Update Kubernetes API endpoint access configuration"
      "set-public-access-cidrs:Update public access CIDRs"
      "nodegroup-health:Get nodegroup health for a managed node"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  wait-nodes)
    _eksctl_utils_wait-nodes
    ;;
  write-kubeconfig)
    _eksctl_utils_write-kubeconfig
    ;;
  describe-stacks)
    _eksctl_utils_describe-stacks
    ;;
  update-cluster-stack)
    _eksctl_utils_update-cluster-stack
    ;;
  update-kube-proxy)
    _eksctl_utils_update-kube-proxy
    ;;
  update-aws-node)
    _eksctl_utils_update-aws-node
    ;;
  update-coredns)
    _eksctl_utils_update-coredns
    ;;
  update-cluster-logging)
    _eksctl_utils_update-cluster-logging
    ;;
  associate-iam-oidc-provider)
    _eksctl_utils_associate-iam-oidc-provider
    ;;
  install-vpc-controllers)
    _eksctl_utils_install-vpc-controllers
    ;;
  update-cluster-endpoints)
    _eksctl_utils_update-cluster-endpoints
    ;;
  set-public-access-cidrs)
    _eksctl_utils_set-public-access-cidrs
    ;;
  nodegroup-health)
    _eksctl_utils_nodegroup-health
    ;;
  esac
}

function _eksctl_utils_wait-nodes {
  _arguments \
    '--kubeconfig[path to read kubeconfig]:' \
    '(-m --nodes-min)'{-m,--nodes-min}'[minimum number of nodes to wait for]:' \
    '--timeout[how long to wait]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_write-kubeconfig {
  _arguments \
    '--authenticator-role-arn[AWS IAM role to assume for authenticator]:' \
    '--auto-kubeconfig[save kubeconfig file by cluster name, e.g. "/Users/yuki.osako/.kube/eksctl/clusters/<name>"]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '--kubeconfig[path to write kubeconfig (incompatible with --auto-kubeconfig)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--set-kubeconfig-context[if true then current-context will be set in kubeconfig; if a context is already set then it will be overwritten]' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_describe-stacks {
  _arguments \
    '--all[include deleted stacks]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '--events[include stack events]' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '--trail[lookup CloudTrail events for the cluster]' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_update-cluster-stack {
  _arguments \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_update-kube-proxy {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_update-aws-node {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_update-coredns {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_update-cluster-logging {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '*--disable-types[Log types to be disabled, the rest will be disabled. Supported log types: (all, none, api, audit, authenticator, controllerManager, scheduler)]:' \
    '*--enable-types[Log types to be enabled. Supported log types: (all, none, api, audit, authenticator, controllerManager, scheduler)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_associate-iam-oidc-provider {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_install-vpc-controllers {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_update-cluster-endpoints {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--private-access[access for private (VPC) clients]' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '--public-access[access for public clients]' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_set-public-access-cidrs {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_nodegroup-health {
  _arguments \
    '--cluster[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-n --name)'{-n,--name}'[Name of the nodegroup]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_completion {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "bash:Generates bash completion scripts"
      "zsh:Generates zsh completion scripts"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  bash)
    _eksctl_completion_bash
    ;;
  zsh)
    _eksctl_completion_zsh
    ;;
  esac
}

function _eksctl_completion_bash {
  _arguments \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_completion_zsh {
  _arguments \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_version {
  _arguments \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_help {
  _arguments \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


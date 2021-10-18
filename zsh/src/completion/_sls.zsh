_sls_templates() {
  _values \
    'VALID TEMPLATES' \
    'aws-nodejs' \
    'aws-python' \
    'aws-java-maven' \
    'aws-java-gradle'
}

_sls_regions() {
  _values \
    'VALID REGIONS' \
    'us-east-1' \
    'us-west-1' \
    'us-west-2' \
    'eu-west-1' \
    'ap-southeast-1' \
    'ap-northeast-1' \
    'ap-southeast-2' \
    'sa-east-1'
}

_sls_invoke_types() {
  _values \
    'VALID INVOKE TYPES' \
    'RequestResponse' \
    'Event' \
    'DryRun'
}

_sls_json_files() {
  local json_files
  json_files=("${(@f)$(find . -type f -name "*.json" \
    -not -path "./node_modules/*" \
    -not -path "./.serverless/*" \
    -not -name "package.json")}")
  _values 'JSON FILES FOUND' $json_files
}

_sls_functions() {
  # parse the functions from the serverless.yaml
  # with a whole lot of aws/grep/sed/zsh magic
  local functions
  functions=("${(@f)$(awk '/^functions/{p=1;print;next} p&&/^(resources|package|provider|plugins|service)/{p=0};p' serverless.yml \
    | grep -e "^  \w\+:" \
    | sed 's/ \+//' \
    | sed 's/:\+//')}")
  _values 'VALID FUNCTIONS' $functions
}

_sls () {
  typeset -A opt_args

  _arguments -C \
  '1:cmd:->cmds' \
  '*::arg:->args'

  case "$state" in
    (cmds)
      local commands
      commands=(
        'create:Create new Serverless Service.'
        'deploy:Deploy Service.'
        'info:Displays information about the service.'
        'invoke:Invokes a deployed function.'
        'logs:Outputs the logs of a deployed function.'
        'remove:Remove resources.'
        'tracking:Enable or disable usage tracking.'
      )

      _describe -t commands 'command' commands
      return 0
    ;;
    (args)
      case $line[1] in
        (create)
          _sls_create
        ;;
        (deploy)
          _sls_deploy
        ;;
        (info)
          _sls_info
        ;;
        (invoke)
          _sls_invoke
        ;;
        (logs)
          _sls_logs
        ;;
        (remove)
          _sls_remove
        ;;
        (tracking)
          _sls_tracking
        ;;
      esac;
    ;;
  esac;

  return 1
}

_sls_create(){
  _arguments -s \
    -t'[Template for the service (required)]:sls_templates:_sls_templates' \
    -p'[The path where the service should be created]'
    return 0
}

_sls_deploy(){
  if [[ $line[2] == "function" ]]; then
    # TODO: this doesn't seem to work for the subcommand
    _arguments -s \
      -f'[Name of the function (required)]:sls_functions:_sls_functions' \
      -r'[Region of the service]:sls_regions:_sls_regions' \
      -s'[Stage of the function]'
      return 0
  else
    _arguments -s \
      -n'[Build artifacts without deploying]' \
      -r'[Region of the service]:sls_regions:_sls_regions' \
      -s'[Stage of the service]' \
      -v'[Show all stack events during deployment]'

    local subcommands
    subcommands=(
      'function:Deploys a single function from the service.'
      )
    _describe -t commands 'deploy subcommands' subcommands
    return 0
  fi
  return 1
}

_sls_info() {
  _arguments -s \
    -r'[Region of the service]:sls_regions:_sls_regions' \
    -s'[Stage of the service]'
    return 0
}

_sls_invoke() {
  _arguments -s \
    -f'[The function name (required)]:sls_functions:_sls_functions' \
    -l'[Trigger logging data output]' \
    -p'[Path to JSON file holding input data]:sls_json_files:_sls_json_files' \
    -r'[Region of the service]:sls_regions:_sls_regions' \
    -s'[Stage of the function]' \
    -t'[Type of invocation]:sls_invoke_types:_sls_invoke_types'
    return 0
}

_sls_logs() {
  _arguments -s \
    -f'[The function name (required)]:sls_functions:_sls_functions' \
    --filter'[A filter pattern]' \
    -i'[Tail polling interval in milliseconds. Default: 1000]' \
    -r'[Region of the service]:sls_regions:_sls_regions' \
    -s'[Stage of the function]' \
    --startTime'[Logs before this time will not be displayed]' \
    -t'[Tail the log output]'
    return 0
}

_sls_remove() {
  _arguments -s \
    -r'[Region of the service]:sls_regions:_sls_regions' \
    -s'[Stage of the function]' \
    -v'[Show all stack events during deployment]'
    return 0
}

_sls_tracking() {
  _arguments -s \
    -d'[Disable tracking]' \
    -e'[Enable tracking]'
    return 0
}

compdef _sls sls serverless

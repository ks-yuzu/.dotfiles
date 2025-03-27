zstyle ':completion:*:*:grafana-dashboard-cli:*:*' format '%BCompleting %d%b'

__direnv_completion()
{
	 _arguments \
		 '1:subcommand:__direnv_completion_subcommand' \
}

__direnv_completion_subcommand() {
  _values 'Subcommand' \
          allow
}

compdef __direnv_completion direnv

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/shabib/.oh-my-zsh

# Path to postgres@9.5
export PATH="/usr/local/opt/postgresql@9.5/bin:$PATH"

# test variables for plm-website
export USE_REAL_NEWSWIRE=true
export NEWSWIRE_URL=http://localhost:7000/graphql

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="spaceship"
SPACESHIP_GIT_BRANCH_PREFIX="git:"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  aws
  brews
  bundler
  common-aliases
  dirhistory
  git
  history
  jira
  jsontools
  npm
  rails
  z
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="open ~/.zshrc"
alias ohmyzsh="open ~/.oh-my-zsh"
alias npmstart="npm run clean | npm i | npm run start"
alias testsetup="bin/rails db:environment:set RAILS_ENV=test & bin/rails db:migrate RAILS_ENV=test"
alias stree='/Applications/SourceTree.app/Contents/Resources/stree'

killport(){ 
  lsof -i tcp:"$1" | awk 'NR!=1 {print $2}' | xargs kill
}

eval "$(rbenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

function resetplmdb {
    echo "NOTE: make sure to run this in a rails repo\n"
 
    echo "Dropping plm_development..."
    dropdb --if-exists -U postgres plm_development
 
    echo "Creating plm_development..."
    createdb -U postgres -T plm_development_clean_snapshot plm_development
 
    echo "rake db:migrate_and_seed..."
    bundle exec rake db:migrate_and_seed
 
    echo "Creating users..."
    bundle exec rake plm:users:create_all
     
    echo "Importing interviews..."
    bin/schooner import interview_definitions
 
    echo "Running post push tasks..."
    bin/post_push work
 }

function fetchplmdb {
    echo "Fetching latest dev db to ~/db_dumps (you may need to be connected to the VPN)..."
    wget -O$HOME/db_dumps/plm_development_clean_snapshots.pgdump.$(date +%Y%m%d) http://sanitized.plminternal.com:8080/get/plm_database_backups/sanitized%2Fplm.pgdump
 
    echo "Dropping plm_development_clean_snapshot..."
    dropdb plm_development_clean_snapshot
 
    echo "Creating plm_development_clean_snapshot..."
    createdb plm_development_clean_snapshot
 
    echo "Restoring plm_development_clean_snapshot from pgdump..."
    pg_restore -d plm_development_clean_snapshot ~/db_dumps/plm_development_clean_snapshots.pgdump.$(date +%Y%m%d) -j6 -O -x
} 


source "/Users/shabib/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

bindkey "^[b" backward-word
bindkey "^[f" forward-word

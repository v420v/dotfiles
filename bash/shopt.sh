
[[ $- != *i* ]] && return

#######################################
# Enabled options
#######################################
shopt -s \
  autocd \
  checkwinsize \
  cmdhist \
  complete_fullquote \
  expand_aliases \
  extglob \
  extquote \
  force_fignore \
  globasciiranges \
  globskipdots \
  histappend \
  inherit_errexit \
  interactive_comments \
  patsub_replacement \
  progcomp \
  promptvars \
  sourcepath

#######################################
# Disabled options
#######################################
shopt -u \
  assoc_expand_once \
  cdable_vars \
  cdspell \
  checkhash \
  checkjobs \
  compat31 \
  compat32 \
  compat40 \
  compat41 \
  compat42 \
  compat43 \
  compat44 \
  direxpand \
  dirspell \
  dotglob \
  execfail \
  extdebug \
  failglob \
  globstar \
  gnu_errfmt \
  histreedit \
  histverify \
  hostcomplete \
  huponexit \
  lastpipe \
  lithist \
  localvar_inherit \
  localvar_unset \
  login_shell \
  mailwarn \
  no_empty_cmd_completion \
  nocaseglob \
  nocasematch \
  noexpand_translation \
  nullglob \
  progcomp_alias \
  restricted_shell \
  shift_verbose \
  varredir_close \
  xpg_echo

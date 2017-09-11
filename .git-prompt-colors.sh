# Plague Doctor's bash-git-prompt theme.
#
# Note 1: The theme is designed to work only in GIT Repos.
#         If one needs a coresponding prompt for non GIT locations, here is the code:
#
#         if [ -f <path-to-prompt-colors.sh> ]; then
#             source <path-to-prompt-colors.sh>
#             MYPROMPT="${White}\A${ResetColor} ${BoldGreen}\\u${White}@${BoldYellow}\\h ${Cyan}\w${ResetColor}${BoldWhite} $ ${ResetColor}"
#         else
#             MYPROMPT="\[\033[37m\]\A \[\033[1m\]\[\033[32m\]\u\[\033[0m\]\[\033[37m\]@\[\033[1m\]\[\033[33m\]\h:\[\033[0m\]\[\033[36m\] \w\[\033[0m\]\[\033[1m\]\[\033[37m\] \$ \[\033[0m\]"
#         fi
#         export PS1=$MYPROMPT
#
# Note 2: The theme looks very nice with "FantasqueSansMono Nerd Font" https://github.com/ryanoasis/nerd-fonts

override_git_prompt_colors() {
  GIT_PROMPT_THEME_NAME="Plague Doctor"
  GIT_PROMPT_ONLY_IN_REPO=1
  GIT_PROMPT_LEADING_SPACE=0

  GIT_PROMPT_PREFIX="[ "
  GIT_PROMPT_SUFFIX=" ]"
  GIT_PROMPT_SEPARATOR=" |"
  GIT_PROMPT_STAGED=" ${Red}● ${ResetColor}"
  GIT_PROMPT_CONFLICTS=" ${Red}✖ ${ResetColor}"
  GIT_PROMPT_CHANGED=" ${BoldBlue}✚ ${ResetColor}"
  GIT_PROMPT_UNTRACKED=" ${Cyan}…${ResetColor}"
  GIT_PROMPT_STASHED=" ${Blue}⚑ ${ResetColor}"
  GIT_PROMPT_CLEAN=" ${BoldGreen}✔ ${ResetColor}"
  GIT_PROMPT_SYMBOLS_NO_REMOTE_TRACKING="✭"

  GIT_PROMPT_COMMAND_OK="${Green}✔ "
  GIT_PROMPT_COMMAND_FAIL="${Red}✘ "

  GIT_PROMPT_START_USER="${BoldBlue} ${ResetColor}"
  GIT_PROMPT_START_ROOT="${BoldRed}❖ ${ResetColor}"
  GIT_PROMPT_END_USER="\n_LAST_COMMAND_INDICATOR_${White}${Time12a}${ResetColor} ${BoldBlue}${PathShort}${ResetColor}${BoldWhite} > ${ResetColor}"
  GIT_PROMPT_END_ROOT="\n_LAST_COMMAND_INDICATOR_${White}${Time12a}${ResetColor} ${BoldRed}\\u${White}@${BoldYellow}\\h ${Cyan}${PathShort}${ResetColor}${BoldRed} # ${ResetColor}"
}

reload_git_prompt_colors "Plague Doctor"

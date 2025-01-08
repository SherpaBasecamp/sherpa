# @file Build
# @brief Create the script from partials, generate docs, optimize.
# @description
#
#    To be used from the root of a Sherpa project,
#    created with "sherpa new myProject".
#
#    It will:
#
#      * Generate a list of paths to be combined
#      * Extract paths from `use "collection/lib"` in bin.sh
#      * Put every partials together in a single file
#      * Generates docs from the shdoc comments
#      * Remove all full line comments
#      * Remove all empty lines
#      * Remove leading and trailing spaces
#      * Add the /usr/bin/env shebang
#      * Place the resulted script in target/local
#      * Make it executable
#      * Symlnk it to ~/.sherpa/bin for global availability
#
#  Usage: sherpa b, build
#
#
# **Next: Flags to diferenciate build type**
#
# Usage: sherpa b -t "lib"
#
# - bin: Default. Creating an executable
# - lib: Raw .sh files for fn() libraries
#

# Initialising flags variables
# so that Shellcheck could be Happy.
quiet="off"
verb="off"

#                     #
# --- Let's Roll! --- #
#                     #

if [[ "$1" == "build" || "$1" == "b" ]]; then #build

  shebang="src/_header.sh"
  sourceOrder="src/__paths.txt"
  combinedScript="scriptAlmost.sh"
  finalScript="$(get_yaml_item "package.executable" "Sherpa.yaml")"

  # --- OptionFlags --- #

  type="bin" # bin for an executable script OR lib for raw .sh
  while getopts "t:" opt; do
    case $opt in
    t) type=$OPTARG ;;
    *) echo "Invalid flag" ;;
    esac
  done

  # --- End OptionFlags --- #

  # Creating directories if not exists
  [[ ! -d target ]] && mkdir target
  [[ ! -d target/local ]] && mkdir target/local

  [[ "$quiet" != "on" ]] && h1 " Building..."
  [[ "$quiet" != "on" ]] && br

  # Call use2path script from .sherpa/bin
  use2path

  [[ "$verb" == "on" ]] && echo "VB: Combining files listed in ${sourceOrder}..."
  [[ "$verb" == "on" ]] && echo "VB: Some more lines"

  # cat "$(<"$sourceOrder")" >"$combinedScript"
  # Read the file paths into an array
  mapfile -t files <"$sourceOrder"

  # Concatenate the contents of each file into combinedScript
  cat "${files[@]}" >"$combinedScript"

  if [[ -f "$combinedScript" ]]; then
    p "- Partials combined into ${combinedScript}"
    p "- Generating documentation from that file"
    [[ ! -d docs ]] && mkdir docs
    shdoc <"$combinedScript" >"docs/${finalScript}.md"
    echo -e "--- Commands/Routes & nonFunctions ---\n" >>"docs/${finalScript}.md"
    # Additional parsing with bashdoc
    bashdoc "$combinedScript" >>"docs/${finalScript}.md"
    if [[ -f "docs/${finalScript}.md" ]]; then
      p "  Check docs/${finalScript}.md"
    fi

    p "- Removing comments and empty lines..."
    sed -i '/^\s*#/d; /^\s*$/d' "$combinedScript"

    p "- Removing trailing spaces..."
    sed -i 's/[[:space:]]*$//' "$combinedScript"

    p "- Removing the leading spaces..."
    sed -i 's/^[[:space:]]*//' "$combinedScript"

    p "- Adding the /usr/bin/env bash Shebang..."
    # [[ $# != 2 ]] && echo "Usage: sherpa Make scriptName"

    # Create dirs if necessary
    [[ ! -d target ]] && mkdir "target"
    [[ ! -d target/local ]] && mkdir "target/local"

    # Create the file with the added shebang
    cat "$shebang" "$combinedScript" >"target/local/$finalScript"

    # Clean-up. Remove the temporary file.
    rm "$combinedScript"

    # echo "Check with GREP if # lines exist"
    [[ "$verb" == "on" ]] && p "Making ${finalScript} it executable..."
    chmod +x "target/local/$finalScript"
    echo
    p "${btnSuccess} Done! ${x} Execute it with ${txtGreen}${em}${finalScript}${x}"
    br

    #
    # --- Symlink ---
    #
    # The eventualy existing symlink
    executable=$(get_yaml_item "package.executable" "Sherpa.yaml")
    symlink="${SDD}/bin/${executable}"

    # Get the target of the symlink
    target=$(readlink -f "$symlink")

    if [[ ! -L "$symlink" ]]; then
      # Create a new symlink
      ln -s "$(pwd)/target/local/${executable}" "${SDD}/bin/${executable}"
    fi

    # Check if the target doesn't contain "target/bin"
    if [[ "$target" != *"target/local"* ]]; then
      # Remove the existing symlink
      rm "$symlink"

      # Create a new symlink
      ln -s "$(pwd)/target/local/${executable}" "${SDD}/bin/${executable}"

      echo "Symlink updated successfully."
    else
      echo "local/${executable} still Symlinked to ${SDD}/bin"
    fi

  else
    p "${btnWarning} Oops! ${x} Something went wrong!"
    exit 1
  fi

fi # End build

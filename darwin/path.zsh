# Homebrew's prefix is off the default PATH on Apple Silicon. Evaluate
# brew shellenv with the arch-derived prefix so Intel works from the same file.
if [[ "$(uname -s)" == Darwin ]]
then
    case "$(uname -m)" in
        arm64) homebrew_prefix_=/opt/homebrew ;;
        *) homebrew_prefix_=/usr/local ;;
    esac

    if [[ -x "$homebrew_prefix_/bin/brew" ]]
    then
        eval "$("$homebrew_prefix_/bin/brew" shellenv)"
    fi
    unset homebrew_prefix_
fi

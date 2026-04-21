function RGB($r, $g, $b) {
    if ($r -notin 0..255 -or $g -notin 0..255 -or $b -notin 0..255) {
        throw "RGB values must be 0–255"
    }
    "$([char]27)[38;2;${r};${g};${b}m"
}

$RESET = "$([char]27)[0m"
$BOLD = "$([char]27)[1m"
$ITALIC = "$([char]27)[3m"

$YELLOW = "$([char]27)[0;33m"
$YELLOW_BOLD = "$([char]27)[1;33m"
$RED_BOLD = "$([char]27)[1;31m"
$LIGHT_ORANGE = "$([char]27)[38;5;215m"
$DARK_ORANGE = "$([char]27)[38;5;130m"
$CUSTOM_ORANGE = RGB 220 165 50

# "bright black"
$PROMPT_STYLE = "$RESET$([char]27)[0;90m"
$ERROR_STYLE = $RED_BOLD

# --- git branch (rough equivalent of __git_ps1) ---

function Get-GitBranch {
    try {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -ne 0) { return "" }
        return $branch.Trim()
    }
    catch {
        return ""
    }
}

function Git-Part($part) {
    $branch = Get-GitBranch
    if (-not $branch) { return "" }

    if ($branch -match '([^/]+/)(.*)') {
        if ($part -eq 1) { return "::" + $Matches[1] }
        if ($part -eq 2) { return $Matches[2] }
    }
    else {
        if ($part -eq 1) { return "::" }
        if ($part -eq 2) { return $branch }
    }
}

# --- prompt ---

function prompt {
    # Perhaps one day we can get a standard Unix-y $? value.
    $exit = 0
    $path = (Get-Location).Path

    $git1 = Git-Part 1
    $git2 = Git-Part 2

    $gitPart =
    "$LIGHT_ORANGE$git1" +
    "$BOLD$LIGHT_ORANGE$git2"

    $errorPart = ""
    if ($exit -gt 0) {
        $errorPart = $ERROR_STYLE
    }

    return "$PROMPT_STYLE$path$gitPart$PROMPT_STYLE$errorPart`$ $RESET"
}

Export-ModuleMember -Function prompt

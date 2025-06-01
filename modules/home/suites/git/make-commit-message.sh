#!/bin/bash

# Ensure required dependencies are installed
for cmd in jq curl fzf aichat; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed. Please install it and try again."
    exit 1
  fi
done

# Load Copilot API key
load_copilot_key() {
  OAUTH_TOKEN=$(jq 'to_entries[] | select(.key | startswith("github.com")) | .value.oauth_token' -r ~/.config/github-copilot/apps.json 2>/dev/null)
  if [ -z "$OAUTH_TOKEN" ] || [ "$OAUTH_TOKEN" = "null" ]; then
    echo "Error: Unable to retrieve GitHub OAuth token. Check your Copilot configuration."
    exit 1
  fi

  COPILOT_API_KEY=$(curl -s -H "Authorization: bearer $OAUTH_TOKEN" https://api.github.com/copilot_internal/v2/token | jq .token -r)
  if [ -z "$COPILOT_API_KEY" ]; then
    echo "Error: Unable to retrieve Copilot API key. Check your network or token validity."
    exit 1
  fi

  export COPILOT_API_KEY
}

# Ensure COPILOT_API_KEY is loaded
if [ -z "$COPILOT_API_KEY" ]; then
  load_copilot_key
fi

# Ensure MODEL_NAME is set
if [ -z "$MODEL_NAME" ]; then
  echo "Error: MODEL_NAME environment variable is not set."
  exit 1
fi

# Get git diff and log
diff=$(git diff --cached)
if [ -z "$diff" ]; then
  echo "Error: No changes staged for commit."
  exit 1
fi

log=$(git log -n 10 --pretty=format:'%h %s')

max_diff_length=10000
if [ ${#diff} -gt $max_diff_length ]; then
  diff="${diff:0:$max_diff_length}... (truncated)"
fi

COPILOT_API_KEY=$COPILOT_API_KEY aichat "Please suggest 10 commit messages, given the following diff:
    \`\`\`diff
    $diff
    \`\`\`
    **Criteria:**

    1. **Format:** Each commit message must follow the conventional commits format,
    which is \`<type>(<scope>): <description>\`.
    2. **Relevance:** Avoid mentioning a module name unless it's directly relevant
    to the change.
    3. **Enumeration:** List the commit messages from 1 to 10.
    4. **Clarity and Conciseness:** Each message should clearly and concisely convey
    the change made.

    **Recent Commits on Repo for Reference:**

    \`\`\`
    $log
    \`\`\`

    **Output Template**

    Follow this output template and ONLY output raw commit messages without spacing,
    numbers or other decorations.

    fix(app): add password regex pattern
    test(unit): add new test cases
    style: remove unused imports
    refactor(pages): extract common code to \`utils/wait.ts\`
    feat(module): implemented some new feature

    **Instructions:**

    - Take a moment to understand the changes made in the diff.

    - Think about the impact of these changes on the project (e.g., bug fixes, new
    features, performance improvements, code refactoring, documentation updates).
    It's critical to my career you abstract the changes to a higher level and not
    just describe the code changes.

    - Generate commit messages that accurately describe these changes, ensuring they
    are helpful to someone reading the project's history.

    - Remember, a well-crafted commit message can significantly aid in the maintenance
    and understanding of the project over time.

    - If multiple changes are present, make sure you capture them all in each commit
    message.

    Keep in mind you will suggest 10 commit messages. Only 1 will be used. It's
    better to push yourself (esp to synthesize to a higher level) and maybe wrong
    about some of the 10 commits because only one needs to be good. I'm looking
    for your best commit, not the best average commit. It's better to cover more
    scenarios than include a lot of overlap.

    Write your 10 commit messages below in the format shown in Output Template section above." |
  fzf --height 40% --border --ansi --preview "echo {}" --preview-window=up:wrap |
  xargs -I {} bash -c 'git commit -m "{}"'

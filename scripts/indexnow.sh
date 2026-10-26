#!/usr/bin/env bash
# Tell IndexNow (Bing, Yandex, and through Bing ChatGPT search and Copilot) which
# blog pages the last build commit changed. Google does not take part in IndexNow.
#
#   scripts/indexnow.sh <build-commit>
set -euo pipefail

HOST="blog.innerarc.me"
KEY="9649693995727aabbb80660344b54caf"
KEY_URL="https://${HOST}/${KEY}.txt"

urls=()
while IFS= read -r file; do
  path="${file#docs/}"
  case "$path" in
    404.html) continue ;;
    index.html) path="" ;;
    */index.html) path="${path%index.html}" ;;
  esac
  urls+=("https://${HOST}/${path}")
done < <(git diff --name-only "$1~1" "$1" -- 'docs/*.html' 'docs/**/*.html')

if [ ${#urls[@]} -eq 0 ]; then
  echo "No pages changed, nothing to submit."
  exit 0
fi

# GitHub Pages publishes a minute or two after the push; IndexNow checks the key file.
for _ in $(seq 1 30); do
  [ "$(curl -s "$KEY_URL")" = "$KEY" ] && break
  sleep 10
done

payload=$(printf '%s\n' "${urls[@]}" | jq -R . | jq -s --arg host "$HOST" --arg key "$KEY" --arg loc "$KEY_URL" \
  '{host: $host, key: $key, keyLocation: $loc, urlList: .}')
printf 'Submitting %s URL(s):\n' "${#urls[@]}"; printf '  %s\n' "${urls[@]}"
status=$(curl -s -o /dev/stderr -w '%{http_code}' -X POST https://api.indexnow.org/indexnow \
  -H 'Content-Type: application/json; charset=utf-8' -d "$payload")
echo "IndexNow responded ${status}"
[[ "$status" =~ ^20[02]$ ]]

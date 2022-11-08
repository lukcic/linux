function retry { pytube https://www.youtube.com/playlist\?list\=PL144PdtmXQorbUiZR_ygtu72D-Pyv4jYC && echo "success" || (echo "fail" && retry) }; retry

for p in inte prep prod; do dig +short txt asuid.cms12-${p}-www.some.domain; done

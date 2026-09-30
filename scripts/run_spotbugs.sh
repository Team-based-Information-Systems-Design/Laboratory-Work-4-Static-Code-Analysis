#!/usr/bin/env bash
set -euo pipefail
SB_VERSION=4.8.6
SB="java -jar spotbugs-$SB_VERSION/lib/spotbugs.jar -textui -effort:max -low"
if [ ! -f spotbugs-$SB_VERSION/lib/spotbugs.jar ]; then
  curl -sSL -o spotbugs.tgz https://github.com/spotbugs/spotbugs/releases/download/$SB_VERSION/spotbugs-$SB_VERSION.tgz
  tar -xzf spotbugs.tgz && rm spotbugs.tgz
fi
mkdir -p build results
analyze() {  # name  src_dir  encoding  jar(optional)
  local name=$1 src=$2 enc=$3 jar=${4:-}
  local out=build/$name
  rm -rf "$out"; mkdir -p "$out"
  find "$src" -name '*.java' > "build/${name}_sources.txt"
  local cp=() aux=()
  if [ -n "$jar" ]; then cp=(-cp "$jar"); aux=(-auxclasspath "$jar"); fi
  javac -encoding "$enc" --release 17 -nowarn -proc:none "${cp[@]}" -d "$out" @"build/${name}_sources.txt"
  $SB "${aux[@]}" -sourcepath "$src" -xml:withMessages -output "results/$name.xml" "$out"
  $SB -sortByClass "${aux[@]}" "$out" > "results/$name.txt"
  local n; n=$(grep -c . "results/$name.txt" || true)
  echo "$name: $n warnings"
  if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    { echo "### $name – $n warnings"; echo '```'; head -n 30 "results/$name.txt"; echo '```'; } >> "$GITHUB_STEP_SUMMARY"
  fi
}
analyze task1   src                     UTF-8
analyze library projects/library/src    UTF-8      projects/library/lib/jsr305-2.0.0.jar
analyze colt    projects/colt/src       ISO-8859-1 projects/colt/lib/concurrent.jar

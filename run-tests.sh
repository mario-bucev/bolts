#!/usr/bin/env bash

STAINLESS="stainless-scalac"
if [[ "$#" = 1 ]]; then
  STAINLESS="$1"
fi

function run_tests {
  project=$1
  shift

  echo ""
  echo "------------------------------------------------------------------------------------------"
  echo "Running '$STAINLESS $@' on bolts project: $project..."
  echo "$ find $project -name '*.scala' -exec $STAINLESS $@ {} +"
  find "$project" -name '*.scala' -exec $STAINLESS "$@" {} +

  status=$?

  if [ $status -ne 0 ]
  then
    echo "'$STAINLESS $@' failed on bolts project: $project."
    echo "------------------------------------------------------------------------------------------"
    echo ""
    exit 1
  fi

  echo "------------------------------------------------------------------------------------------"
  echo ""
}

# Tests that use the usual --type-checker=true verification condition generator:

TC_TESTS=`cat tctests.txt`
echo **************************
echo Type Checking vcgen tests:
echo $TC_TESTS
for project in $TC_TESTS; do
  run_tests "$project" "--config-file=stainless.conf.nightly"
done

run_tests "data-structures/sorted-array" "--config-file=stainless.conf.nightly" "--solvers=no-inc:smt-z3:z3 tactic.default_tactic=smt sat.euf=true"

# long map works but uses too many kilowatts:
# run_tests "data-structures/maps/longmap" "--config-file=data-structures/maps/longmap/stainless.conf" "--vc-cache=false" "-J-Xms16G"

run_tests "tutorials/krakow2020/working" "--config-file=stainless.conf.nightly" "--solvers=no-inc:smt-z3:z3 tactic.default_tactic=smt sat.euf=true"

# The `--type-checker` option does not support `forall` so files containing `forall` are done in STD_TESTS:

# for now empty as those needing quantifiers were slow anyway, see WIP-slow
#STD_TESTS=""
#for project in $STD_TESTS; do
#  run_tests "$project" "--config-file=stainless.conf.nightly" "--type-checker=false" "--infer-measures=false"
#done

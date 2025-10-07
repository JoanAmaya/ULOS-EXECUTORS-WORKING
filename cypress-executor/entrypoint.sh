#!/bin/bash
cd
cd /mnt/tests/$DIRECTORY_PATH

mkdir -p results

npm ci
touch results/task.log # create tmp file to indicate status

NO_COLOR=1 npx cypress run | tee results/el_execution_output.txt 
NO_COLOR=1 npx cypress run --browser chromium | tee results/cr_execution_output.txt

/opt/src/scripts/parse-cypress /results/el_execution_output.txt
/opt/src/scripts/parse-cypress /results/cr_execution_output.txt

# Check if both log output files exist (el_execution_passed.log and cr_execution_passed.log)
if [ -f "results/el_execution_passed.log" ] && [ -f "results/cr_execution_passed.log" ]; then
  echo "Creating 'passed' log."
  rm results/el_execution_passed.log
  rm results/cr_execution_passed.log
  touch results/passed.log
else
  echo "One or both log files are missing."
fi

rm results/task.log  
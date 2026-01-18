#!/bin/bash

TIMESTAMP=$(date)

ai_agent_setup() {
  pkill goose > /dev/null 2>&1
  sleep 3s
  killall goose > /dev/null 2>&1
  sleep 3s
  pkill ollama > /dev/null 2>&1
  sleep 3s
  killall ollama > /dev/null 2>&1
  sleep 3s
  clear
  toolkit_root=$(pwd)
  cd "$toolkit_root"
  cat ./automation-resources/config.yaml > $HOME/.config/goose/config.yaml
  goose update
  brew update &&
  brew services start ollama &&
  brew services restart ollama &&
  sleep 10s
  ollama --version > ./automation-resources/ai-agent-output-collector/ollama-output.log 
  echo >> ./automation-resources/ai-agent-output-collector/ollama-output.log 
  ollama list >> ./automation-resources/ai-agent-output-collector/ollama-output.log 
  if grep -q "NAME" ./automation-resources/ai-agent-output-collector/ollama-output.log; then
    echo
    echo
    echo "This ai_agent_setup will continue"
    echo
    echo
  else
    echo
    echo
    echo "[WARNING] Ollama has not been installed properly, or you are not connected to the Internet. If an offline run this was intentional, then this will continue."
    echo
    echo "Please read the documentation found here to fix Codename Goose and Ollama issues ---> https://block.github.io/goose/docs/getting-started/providers#local-llms-ollama"
    echo
    echo "FYI, hundreds of models exist. The suggested models used with this toolkit are mistral or qwen3 for now, but this will definitely change over time as better models get released."
    echo
    echo "Please read this for more information ---> https://en.wikipedia.org/wiki/List_of_large_language_models"
    echo
    echo
  fi
  AGENT_OUTPUT="ai-agent-output"
  AGENT_INPUT="ai-agent-input"
  chmod -R 777 ./goose-main
  cp -R ./goose-main/ai-agent-output ./automation-resources/ai-agent-output-collector
  rm -rf ./goose-main/"$AGENT_OUTPUT"
  mkdir -p ./goose-main/"$AGENT_OUTPUT"
  chmod -R 777 ./goose-main/"$AGENT_OUTPUT"
  mkdir -p ./goose-main/"$AGENT_INPUT"
  chmod -R 777 ./goose-main/"$AGENT_INPUT"
  cp -R ./agent-instructions/detailed-instructions ./goose-main/ai-agent-input
  cp -R ./automation-resources/data-files ./goose-main/ai-agent-input
  cp -R ./automation-resources/data-files ./goose-main/ai-agent-output
  rm -rf ./goose-main/ai-agent-input/data-files/goose-main
}

create_multiple_docker_containers() {
  CONTAINER_AMOUNT="$1"
  echo
  echo
  echo "This workflow requires Docker Desktop to be installed properly first ---> https://docs.docker.com/"
  echo
  echo
  echo "Starting $CONTAINER_AMOUNT instances of the Goose AI agent containers 'goose-cli' service..."
  cd ./goose-main
  docker compose -f ./documentation/docs/docker/docker-compose.yml build 
  docker compose -f ./documentation/docs/docker/docker-compose.yml scale goose-cli="$CONTAINER_AMOUNT"
}

if [ "$1" == "Get-Codename-Goose-AI-Agent" ]; then
  echo
  echo
  echo "------------------------------------[[[[ Get-Codename-Goose-AI-Agent ]]]]------------------------------------"
  echo
  echo "This run started on $TIMESTAMP."
  echo
  wget https://github.com/block/goose/archive/refs/heads/main.zip
  unzip main.zip
  echo
  echo
  echo "Change the GOOGLE_API_KEY, GOOSE_PROVIDER, and GOOSE_MODEL in the goose-main/documentation/docs/docker/docker-compose.yml file. You don't need to use Google." 
  echo "You can use any other provider found here ---> https://block.github.io/goose/docs/getting-started/providers#available-providers"
  echo
  echo
  TIMESTAMP2=$(date)
  echo "This run ended on $TIMESTAMP2."
  echo
  echo
  rm -rf ./main.zip
  ls -la
fi

if [ "$1" == "Get-Files-For-RAG-Analysis" ]; then
  echo
  echo
  echo "------------------------------------[[[[ Get-Files-For-RAG-Analysis ]]]]------------------------------------"
  echo
  brew install wget
  brew install git
  echo "This run started on $TIMESTAMP."
  echo
  toolkit_root=$(pwd)
  cd "$toolkit_root"/automation-resources/data-files
  rm -rf ./*.pdf
  rm -rf ./saas-starter
  rm -rf ./CheatSheetSeries
  rm -rf ./www-project-web-security-testing-guide
  pip3 install virtualenv --user > /dev/null 2>&1
  virtualenv -p python3 venv > /dev/null 2>&1
  source venv/bin/activate
  pip3 install -r "$toolkit_root"/automation-resources/requirements.txt > /dev/null 2>&1
  sleep 5
  wget "https://raw.githubusercontent.com/jg8481/Open-Access-Biology-Books/main/bio(121).pdf"
  wget "https://raw.githubusercontent.com/jg8481/Open-Access-Biology-Books/main/bio(111).pdf"
  marker_single "./bio(121).pdf" --output_dir "$toolkit_root"/automation-resources/data-files
  marker_single "./bio(111).pdf" --output_dir "$toolkit_root"/automation-resources/data-files
  git clone https://github.com/OWASP/wstg.git
  git clone https://github.com/OWASP/owasp-mastg.git
  git clone https://github.com/OWASP/owasp-istg.git
  git clone https://github.com/nextjs/saas-starter
  git clone https://github.com/wikimedia/wikipedia-ios.git
  git clone https://github.com/wikimedia/wikipedia-ios.git
  echo
  TIMESTAMP2=$(date)
  echo "This run ended on $TIMESTAMP2."
  echo
  echo
  rm -rf ./venv
  ls -la
fi

if [ "$1" == "Stop-All-Docker-Containers" ]; then
  echo
  echo
  echo "------------------------------------[[[[ Stop-All-Docker-Containers ]]]]------------------------------------"
  echo
  echo "This run started on $TIMESTAMP."
  echo
  docker stop $(docker ps -a -q) &&
  docker rm $(docker ps -a -q)
  cd ./goose-main
  docker compose -f ./documentation/docs/docker/docker-compose.yml down
  docker compose -f ./documentation/docs/docker/docker-compose.yml rm -f
  echo
  TIMESTAMP2=$(date)
  echo "This run ended on $TIMESTAMP2."
  echo
  echo
fi

if [ "$1" == "Start-One-Docker-Container" ]; then
  ai_agent_setup
  echo
  echo
  echo "------------------------------------[[[[ Start-One-Docker-Container ]]]]------------------------------------"
  echo
  echo "This run started on $TIMESTAMP."
  echo
  cd ./goose-main
  docker compose -f ./documentation/docs/docker/docker-compose.yml build
  docker compose -f ./documentation/docs/docker/docker-compose.yml up -d
  echo
  TIMESTAMP2=$(date)
  echo "This run ended on $TIMESTAMP2."
  echo
  echo
fi

if [ "$1" == "Start-Multiple-Docker-Containers" ]; then
  if [ -z "$2" ]; then
    echo
    echo
    echo "[ERROR] The second argument (number of containers) should not be blank."
    echo
    echo
    exit 1
  fi
  echo
  echo
  echo "------------------------------------[[[[ Start-Multiple-Docker-Containers ]]]]------------------------------------"
  echo
  echo "This run started on $TIMESTAMP."
  echo
  create_multiple_docker_containers "$2"
  echo
  TIMESTAMP2=$(date)
  echo "This run ended on $TIMESTAMP2."
  echo
  echo  
fi

if [ "$1" == "Run-One-Container-And-AI-Task" ]; then
  if [ -z "$2" ]; then
    echo
    echo
    echo "[ERROR] The second argument (prompt text) should not be blank."
    echo
    echo
    exit 1
  fi
  ai_agent_setup
  echo
  echo
  echo "------------------------------------[[[[ Run-One-Container-And-AI-Task ]]]]------------------------------------"
  echo
  echo "This run started on $TIMESTAMP."
  cd ./goose-main
  docker compose -f ./documentation/docs/docker/docker-compose.yml exec goose-cli goose run --with-extension "npx -y @modelcontextprotocol/server-filesystem /root/workspace" --with-extension "npx -y @modelcontextprotocol/server-memory" --with-extension "npx -y @modelcontextprotocol/server-sequential-thinking" --with-builtin "memory,developer,computercontroller" -t "$2" > ./"$AGENT_OUTPUT"/docker-ai-agent.log
  cat ./"$AGENT_OUTPUT"/docker-ai-agent.log
  echo
  TIMESTAMP2=$(date)
  echo "This run ended on $TIMESTAMP2."
  echo
  echo  
fi

if [ "$1" == "Run-Specific-Containers-And-AI-Tasks" ]; then
  if [ -z "$2" ]; then
    echo
    echo
    echo "[ERROR] The second argument (container name) should not be blank."
    echo
    echo
    exit 1
  fi
  if [ -z "$3" ]; then
    echo
    echo
    echo "[ERROR] The third argument (prompt text) should not be blank."
    echo
    echo
    exit 1
  fi
  ai_agent_setup
  echo
  echo "------------------------------------[[[[ Run-Specific-Containers-And-AI-Tasks ]]]]------------------------------------"
  echo
  echo "This run started on $TIMESTAMP."
  cd ./goose-main
  docker exec "$2" goose run --with-extension "npx -y @modelcontextprotocol/server-memory" --with-extension "npx -y @modelcontextprotocol/server-sequential-thinking" --with-builtin "memory,developer,computercontroller" -t "$3" > ./"$AGENT_OUTPUT"/"$2"-ai-agent.log
  cat ./"$AGENT_OUTPUT"/"$2"-ai-agent.log
  echo
  TIMESTAMP2=$(date)
  echo "This run ended on $TIMESTAMP2."
fi

if [ "$1" == "Run-Specific-Local-Goose-AI-Tasks" ]; then
  if [ -z "$2" ]; then
    echo
    echo
    echo "[ERROR] The second argument (prompt text) should not be blank."
    echo
    echo
    exit 1
  fi
  ai_agent_setup
  echo
  echo "------------------------------------[[[[ Run-Specific-Local-Goose-AI-Tasks ]]]]------------------------------------"
  echo
  echo "This run started on $TIMESTAMP."
  goose run --with-extension "npx -y @modelcontextprotocol/server-memory" --with-extension "npx -y @modelcontextprotocol/server-sequential-thinking" --with-builtin "memory,developer,computercontroller" -t "$2" > ./automation-resources/ai-agent-output-collector/"$AGENT_OUTPUT"/local-ai-agent.log
  cat ./automation-resources/ai-agent-output-collector/"$AGENT_OUTPUT"/local-ai-agent.log
  echo
  TIMESTAMP2=$(date)
  echo "This run ended on $TIMESTAMP2."
  pkill goose > /dev/null 2>&1
  sleep 3s
  killall goose > /dev/null 2>&1
  sleep 3s
  pkill ollama > /dev/null 2>&1
  sleep 3s
  killall ollama > /dev/null 2>&1
  sleep 3s
  exit
fi

if [ "$1" == "Run-Datadriven-Sequential-Local-AI-Tasks" ]; then
  ai_agent_setup
  if [ -z "$2" ]; then
    echo
    echo    
    echo "[ERROR] The second argument (Robot Framework Tag) should not be blank."
    echo "The available tags are... Questions, Research"
    echo
    echo
    exit 1
  fi
  echo
  echo
  echo "------------------------------------[[[[ Run-Datadriven-Sequential-Local-AI-Tasks ]]]]------------------------------------"
  echo
  echo "This run started on $TIMESTAMP."
  echo
  toolkit_root=$(pwd)
  cd "$toolkit_root"
  pip3 install virtualenv --user > /dev/null 2>&1
  virtualenv -p python3 venv > /dev/null 2>&1
  source venv/bin/activate
  pip3 install -r ./automation-resources/requirements.txt > /dev/null 2>&1
  sleep 5
  robot --skiponfailure "$2" --rpa --variable INCLUDED_TAG:"$2" --report NONE --log robotframework-sequential-tasks-local-ai-agent-log.html --output robotframework-sequential-tasks-local-ai-agent-output.xml -d ./logs ./robotframework-sequential-tasks-local-ai-agent.robot &&
  cp -R ./goose-main/ai-agent-output ./automation-resources/ai-agent-output-collector
  echo
  TIMESTAMP2=$(date)
  echo "This run ended on $TIMESTAMP2."
  pkill goose > /dev/null 2>&1
  sleep 3s
  killall goose > /dev/null 2>&1
  sleep 3s
  pkill ollama > /dev/null 2>&1
  sleep 3s
  killall ollama > /dev/null 2>&1
  sleep 3s
  exit
fi

if [ "$1" == "Run-Datadriven-Sequential-AI-Tasks-In-Docker" ]; then
  ai_agent_setup
  if [ -z "$2" ]; then
    echo
    echo    
    echo "[ERROR] The second argument (Robot Framework Tag) should not be blank."
    echo "The available tags are... Questions, Research, Evaluation, Analysis Experimental"
    echo
    echo
    exit 1
  fi
  echo
  echo
  echo "------------------------------------[[[[ Run-Datadriven-Sequential-AI-Tasks-In-Docker ]]]]------------------------------------"
  echo
  echo "This run started on $TIMESTAMP."
  echo
  toolkit_root=$(pwd)
  cd "$toolkit_root"
  pip3 install virtualenv --user > /dev/null 2>&1
  virtualenv -p python3 venv > /dev/null 2>&1
  source venv/bin/activate
  pip3 install -r ./automation-resources/requirements.txt > /dev/null 2>&1
  sleep 5
  robot --skiponfailure "$2" --rpa --variable INCLUDED_TAG:"$2" --report NONE --log robotframework-sequential-tasks-docker-ai-agent-log.html --output robotframework-sequential-tasks-docker-ai-agent-output.xml -d ./logs ./robotframework-distributed-tasks-docker-ai-agent1.robot &&
  cp -R ./goose-main/ai-agent-output ./automation-resources/ai-agent-output-collector
  echo
  TIMESTAMP2=$(date)
  echo "This run ended on $TIMESTAMP2."
  exit
fi

if [ "$1" == "Run-Datadriven-Distributed-AI-Tasks-In-Docker" ]; then
  ai_agent_setup
  if [ -z "$2" ]; then
    echo
    echo    
    echo "[ERROR] The second argument (Robot Framework Tag) should not be blank."
    echo "The available tags are... Questions, Research, Evaluation, Analysis, Experimental"
    echo
    echo
    exit 1
  fi  
  echo
  echo
  echo "------------------------------------[[[[ Run-Datadriven-Distributed-AI-Tasks-In-Docker ]]]]------------------------------------"
  echo
  echo "This run started on $TIMESTAMP."
  echo
  toolkit_root=$(pwd)
  cd "$toolkit_root"
  pip3 install virtualenv --user > /dev/null 2>&1
  virtualenv -p python3 venv > /dev/null 2>&1
  source venv/bin/activate
  pip3 install -r ./automation-resources/requirements.txt > /dev/null 2>&1
  sleep 5
  pabot --skiponfailure "$2" --verbose --rpa --variable INCLUDED_TAG:"$2" --report NONE --log robotframework-distributed-tasks-docker-ai-agent-log.html --output robotframework-distributed-tasks-docker-ai-agent-output.xml -d ./logs ./robotframework-distributed-tasks-docker-ai-agent1.robot ./robotframework-distributed-tasks-docker-ai-agent2.robot &&
  cp -R ./goose-main/ai-agent-output ./automation-resources/ai-agent-output-collector
  echo
  TIMESTAMP2=$(date)
  echo "This run ended on $TIMESTAMP2."
  exit
fi

usage_explanation() {
  echo
  echo
  echo "------------------------------------[[[[ Tool Runner Script ]]]]------------------------------------"
  echo
  echo
  echo "This tool runner script can be used to run the following commands to manage various AI agent workflows through Robot Framework RPA."
  echo
  echo "You can view just this help menu again (without triggering any automation) by running 'bash ./start-ai-agent-workflow-experiments.sh -h' or 'bash ./start-ai-agent-workflow-experiments.sh --help'."
  echo
  echo "bash ./start-ai-agent-workflow-experiments.sh Get-Codename-Goose-AI-Agent"
  echo "bash ./start-ai-agent-workflow-experiments.sh Get-Files-For-RAG-Analysis"
  echo "bash ./start-ai-agent-workflow-experiments.sh Stop-All-Docker-Containers"
  echo "bash ./start-ai-agent-workflow-experiments.sh Start-One-Docker-Container"
  echo "bash ./start-ai-agent-workflow-experiments.sh Start-Multiple-Docker-Containers <NUMBER_OF_CONTAINERS>"
  echo "bash ./start-ai-agent-workflow-experiments.sh Run-One-Container-And-AI-Task <PROMPT_TEXT>"
  echo "bash ./start-ai-agent-workflow-experiments.sh Run-Specific-Containers-And-AI-Tasks <DOCKER_CONTAINER_NAME> <PROMPT_TEXT>"
  echo "bash ./start-ai-agent-workflow-experiments.sh Run-Specific-Local-Goose-AI-Tasks <PROMPT_TEXT>"
  echo "bash ./start-ai-agent-workflow-experiments.sh Run-Datadriven-Sequential-Local-AI-Tasks <ROBOT_FRAMEWORK_TAGS>"
  echo "bash ./start-ai-agent-workflow-experiments.sh Run-Datadriven-Sequential-AI-Tasks-In-Docker <ROBOT_FRAMEWORK_TAGS>"
  echo "bash ./start-ai-agent-workflow-experiments.sh Run-Datadriven-Distributed-AI-Tasks-In-Docker <ROBOT_FRAMEWORK_TAGS>"
  echo
  echo "Here are Robot Framework Tag examples that can be used to run specific AI agent RPA workflows"
  echo
  echo "bash ./start-ai-agent-workflow-experiments.sh Run-Datadriven-Sequential-Local-AI-Tasks ResearchORQuestions"
  echo "bash ./start-ai-agent-workflow-experiments.sh Run-Datadriven-Sequential-AI-Tasks-In-Docker Analysis"
  echo "bash ./start-ai-agent-workflow-experiments.sh Run-Datadriven-Distributed-AI-Tasks-In-Docker Evaluation"
  echo
  echo
}

error_handler() {
  local error_message="$@"
  echo
  echo
  echo "${error_message}" 1>&2;
  echo
  echo
}

argument="$1"
if [[ -z $argument ]] ; then
  error_handler Please enter a valid tool runner option. The usage instructions below contains various options for setting up Docker and running the Goose AI agents.
  usage_explanation
else
  case $argument in
    -h|--help)
      error_handler Here is a help menu and usage instructions. The following contains various options for setting up Docker and running the Goose AI agents.
      usage_explanation
      ;;
    *)
      error_handler Here is a help menu and usage instructions. The following contains various options for setting up Docker and running the Goose AI agents.
      usage_explanation
      ;;
  esac
fi

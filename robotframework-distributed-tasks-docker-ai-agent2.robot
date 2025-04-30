*** Settings ***
Resource                  ${EXECDIR}/automation-resources/generic-resources.robot
Library                   DateTime
Library                   OperatingSystem
Library                   Process
Library                   String
Library     DataDriver    ${EXECDIR}/agent-instructions/docker-agent2-distributed-instructions.csv    dialect=unix    include=${INCLUDED_TAG}
Test Template    Run Tasks From Goose AI Agent

*** Tasks ***

DISTRIBUTED RPA AI-AGENT2 TASKS : Run datadriven AI-Agent tasks with this data -> container_name = ${DOCKER_CONTAINER_NAME}, prompt_message = ${GOOSE_AI_PROMPT}, docker_agent2_report_number = ${REPORT_NUMBER}

*** Keywords ***

Run Tasks From Goose AI Agent
    [Arguments]    ${DOCKER_CONTAINER_NAME}    ${GOOSE_AI_PROMPT}    ${REPORT_NUMBER}
    ${TIMESTAMP}=    Get Current Date    result_format=%Y_%m_%d_%H-%M-%S-%f
    Wait Until Docker Goose AI Prompt Succeeds    ${DOCKER_CONTAINER_NAME}    ${GOOSE_AI_PROMPT} write a detailed summary of that work in an docker-agent2-report${REPORT_NUMBER}-${TIMESTAMP}.md file and ${GOOSE_AI_DOCKER_OUTPUT_COLLECTOR}    npx -y @modelcontextprotocol/server-memory    npx -y @modelcontextprotocol/server-sequential-thinking
    Display Goose AI Logs
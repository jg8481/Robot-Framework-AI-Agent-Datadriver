*** Settings ***
Resource                  ${EXECDIR}/automation-resources/generic-resources.robot
Library                   DateTime
Library                   OperatingSystem
Library                   Process
Library                   String
Library     DataDriver    ${EXECDIR}/agent-instructions/local-agent-sequential-instructions.csv    dialect=unix    include=${INCLUDED_TAG}
Test Template    Run Tasks From Local Goose AI Agent

*** Variables ***

${LLM_TIME_CONSTRAINT}    240    ## This is in seconds
${AI_AGENT_OUTPUT_FOLDER}    automation-resources/ai-agent-output-collector/ai-agent-output

*** Tasks ***

SEQUENTIAL RPA AI-AGENT TASKS : Run datadriven AI-Agent tasks with this data -> prompt_message = ${GOOSE_AI_PROMPT}, local_agent_report_number  = ${REPORT_NUMBER}

*** Keywords ***

Run Tasks From Local Goose AI Agent
    [Arguments]    ${GOOSE_AI_PROMPT}    ${INSTRUCTION_TYPE}    ${REPORT_NUMBER}
    ${TIMESTAMP}=    Get Current Date    result_format=%Y_%m_%d_%H-%M-%S-%f
    Set Suite Variable    ${TIMESTAMP}
    Run Goose AI Based On Instruction Type    ${GOOSE_AI_PROMPT}    ${INSTRUCTION_TYPE}
    Create Local Agent Report    ${REPORT_NUMBER}
    Display Goose AI Logs
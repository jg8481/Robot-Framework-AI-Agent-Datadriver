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

*** Tasks ***

SEQUENTIAL RPA AI-AGENT5 TASKS : Run datadriven AI-Agent tasks with this data -> prompt_message = ${GOOSE_AI_PROMPT}, local_agent_report_number  = ${REPORT_NUMBER}

*** Keywords ***

Run Tasks From Local Goose AI Agent
    [Arguments]    ${GOOSE_AI_PROMPT}    ${INSTRUCTION_TYPE}    ${REPORT_NUMBER}
    ${TIMESTAMP}=    Get Current Date    result_format=%Y_%m_%d_%H-%M-%S-%f
    Run Goose AI Based On Instruction Type    ${GOOSE_AI_PROMPT}    ${INSTRUCTION_TYPE}
    Create File    ${EXECDIR}/automation-resources/ai-agent-output-collector/ai-agent-output/local-agent-report${REPORT_NUMBER}-${TIMESTAMP}.md    ${OUTPUT}
    Run    cat ${EXECDIR}/automation-resources/ai-agent-output-collector/ai-agent-output/local-agent-report${REPORT_NUMBER}-${TIMESTAMP}.md | sed -E 's/\x1B\[[0-9;]*[mK]//g' > ${EXECDIR}/automation-resources/ai-agent-output-collector/ai-agent-output/filtered-report${REPORT_NUMBER}-${TIMESTAMP}.md
    Run    mv ${EXECDIR}/automation-resources/ai-agent-output-collector/ai-agent-output/filtered-report${REPORT_NUMBER}-${TIMESTAMP}.md ${EXECDIR}/automation-resources/ai-agent-output-collector/ai-agent-output/local-agent-report${REPORT_NUMBER}-${TIMESTAMP}.md
    Display Goose AI Logs
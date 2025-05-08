*** Settings ***
Library                   ${EXECDIR}/automation-resources/AIAgentLibrary.py
Library                   OperatingSystem
Library                   Process
Library                   String

*** Variables ***
${RETRY}    100
${DELAY}    2
${GOOSE_AI_LOCAL_OUTPUT_COLLECTOR}    put all of that into the ${EXECDIR} folder.
${GOOSE_AI_DOCKER_OUTPUT_COLLECTOR}    put all of that into the /root/workspace/ai-agent-output folder and create the folder if it doesn't exist. Do not ask me permission to create the folder just do it.

*** Keywords ***

Wait Until Docker Goose AI Prompt Succeeds
    [Arguments]    ${DOCKER_CONTAINER_NAME}    ${GOOSE_AI_PROMPT}    ${GOOSE_AI_EXTENSION1}    ${GOOSE_AI_EXTENSION2}
    Wait Until Keyword Succeeds    ${RETRY} times    0.25 seconds    Run Docker Goose AI Prompt And Check Output    ${DOCKER_CONTAINER_NAME}    ${GOOSE_AI_PROMPT}    ${GOOSE_AI_EXTENSION1}    ${GOOSE_AI_EXTENSION2}

Run Docker Goose AI Prompt And Check Output
    [Arguments]    ${DOCKER_CONTAINER_NAME}    ${GOOSE_AI_PROMPT}    ${GOOSE_AI_EXTENSION1}    ${GOOSE_AI_EXTENSION2}
    Sleep    ${DELAY} seconds
    ${OUTPUT}=    Send Docker AI Agent Prompt Message    ${DOCKER_CONTAINER_NAME}    ${GOOSE_AI_PROMPT}    ${GOOSE_AI_EXTENSION1}    ${GOOSE_AI_EXTENSION2}
    Should Not Contain    ${OUTPUT}    Rate limit hit
    Should Not Contain    ${OUTPUT}    crates/goose/src/agents/truncate.rs
    Should Not Contain    ${OUTPUT}    goose::agents::truncate:
    Should Not Contain    ${OUTPUT}    Please retry if you think this is a transient or recoverable error.
    Should Not Contain Any    ${OUTPUT}    UNAVAILABLE    ERROR    Request failed    400 Bad Request    Server error    Ran into this error
    Should Not Contain Any    ${OUTPUT}    I do not have the ability    RPC    GenerateContentRequest
    Set Suite Variable    ${OUTPUT}

Wait Until Local Goose Prompt Succeeds
    [Timeout]    60 minutes
    [Arguments]    ${GOOSE_AI_PROMPT}    #${GOOSE_AI_EXTENSION1}    ${GOOSE_AI_EXTENSION2}
    Wait Until Keyword Succeeds    ${RETRY} times    0.25 seconds    Run Local Goose Prompt And Check Output    ${GOOSE_AI_PROMPT}    #${GOOSE_AI_EXTENSION1}    ${GOOSE_AI_EXTENSION2}

Run Local Goose Prompt And Check Output
    [Arguments]    ${GOOSE_AI_PROMPT}
    Sleep    ${DELAY} seconds
    ${OUTPUT}=    Send Local AI Agent Prompt Message    ${GOOSE_AI_PROMPT}
    ## ${OUTPUT}=    Send Local AI Agent Prompt Message    ${GOOSE_AI_PROMPT}    #${GOOSE_AI_EXTENSION1}    ${GOOSE_AI_EXTENSION2}
    ## The code above is disabled until the Codename Goose and Ollama developers figure out how to fix the following challenges with tools and toolshim...
    ## https://block.github.io/goose/blog/2025/03/31/goose-benchmark/#technical-challenges-with-open-models
    ## https://block.github.io/goose/blog/2025/04/11/finetuning-toolshim/#some-examples-of-model-specific-quirks-wrt-tool-calling
    ## https://github.com/MeetKai/functionary/issues/302#issuecomment-2650187280
    Should Not Contain    ${OUTPUT}    crates/goose/src/agents/truncate.rs
    Should Not Contain    ${OUTPUT}    goose::agents::truncate:
    Should Not Contain    ${OUTPUT}    Please retry if you think this is a transient or recoverable error.
    Should Not Contain Any    ${OUTPUT}    UNAVAILABLE    ERROR    Request failed    400 Bad Request    Server error    Ran into this error
    Should Not Contain Any    ${OUTPUT}    I do not have the ability    RPC    GenerateContentRequest
    Should Not Contain Any    ${OUTPUT}    extension_name:    uri:    Tool not found
    Should Not Contain Any    ${OUTPUT}    platform    search_available_extensions    remember_memory
    Should Not Contain Any    ${OUTPUT}    。    、    大    澳    中    一    ·    文
    Set Suite Variable    ${OUTPUT}

Wait Until Local Goose Instruction File Succeeds
    [Timeout]    120 minutes
    [Arguments]    ${GOOSE_AI_PROMPT}    #${GOOSE_AI_EXTENSION1}    ${GOOSE_AI_EXTENSION2}
    Wait Until Keyword Succeeds    ${RETRY} times    0.25 seconds    Run Local Goose Instruction File Succeeds    ${GOOSE_AI_PROMPT}    #${GOOSE_AI_EXTENSION1}    ${GOOSE_AI_EXTENSION2}

Run Local Goose Instruction File Succeeds
    [Arguments]    ${GOOSE_AI_PROMPT}
    Sleep    ${DELAY} seconds
    ${OUTPUT}=    Send Local AI Agent Instruction File    ${GOOSE_AI_PROMPT}
    Should Not Contain    ${OUTPUT}    crates/goose/src/agents/truncate.rs
    Should Not Contain    ${OUTPUT}    goose::agents::truncate:
    Should Not Contain    ${OUTPUT}    Please retry if you think this is a transient or recoverable error.
    Should Not Contain Any    ${OUTPUT}    UNAVAILABLE    ERROR    Request failed    400 Bad Request    Server error    Ran into this error
    Should Not Contain Any    ${OUTPUT}    I do not have the ability    RPC    GenerateContentRequest
    Should Not Contain Any    ${OUTPUT}    extension_name:    uri:    Tool not found
    Should Not Contain Any    ${OUTPUT}    platform    search_available_extensions    remember_memory
    Should Not Contain Any    ${OUTPUT}    。    、    大    澳    中    一    ·    文
    Set Suite Variable    ${OUTPUT}

Run Goose AI Based On Instruction Type
    [Arguments]    ${GOOSE_AI_PROMPT}    ${INSTRUCTION_TYPE}
    IF    "${INSTRUCTION_TYPE}" == "User_Prompt"
        Wait Until Local Goose Prompt Succeeds    ${GOOSE_AI_PROMPT}
    ELSE IF    "${INSTRUCTION_TYPE}" == "Markdown_File"
        Wait Until Local Goose Instruction File Succeeds    ${EXECDIR}/agent-instructions/detailed-instructions/${GOOSE_AI_PROMPT}
    END

Create Local Agent Report
    [Arguments]    ${REPORT_NUMBER}
    Create File    ${EXECDIR}/${AI_AGENT_OUTPUT_FOLDER}/local-agent-report${REPORT_NUMBER}-${TIMESTAMP}.md    ${OUTPUT}
    Run    cat ${EXECDIR}/${AI_AGENT_OUTPUT_FOLDER}/local-agent-report${REPORT_NUMBER}-${TIMESTAMP}.md | sed -E 's/\x1B\[[0-9;]*[mK]//g' > ${EXECDIR}/${AI_AGENT_OUTPUT_FOLDER}/filtered-report${REPORT_NUMBER}-${TIMESTAMP}.md
    Run    mv ${EXECDIR}/${AI_AGENT_OUTPUT_FOLDER}/filtered-report${REPORT_NUMBER}-${TIMESTAMP}.md ${EXECDIR}/${AI_AGENT_OUTPUT_FOLDER}/local-agent-report${REPORT_NUMBER}-${TIMESTAMP}.md

Display Goose AI Logs
    Log to Console    ...
    Log to Console    ...
    Log to Console    ...
    Log to Console    ${OUTPUT}
    Log to Console    ...
    Log to Console    ...
    Log to Console    ...
    Log    ${OUTPUT}
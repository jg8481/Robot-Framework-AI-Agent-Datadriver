import subprocess
import os


class AIAgentLibrary:

    def send_docker_ai_agent_prompt_message(self, container_name, prompt_message, first_extension, second_extension):
        """
        Use the 'goose run' command to send a prompt message to a specific Goose AI Agent running in a specific Docker container.
        """
        docker_runner = [
            "docker",
            "exec",
            container_name,
            "goose",
            "run",
            "--with-extension",
            first_extension,
            "--with-extension",
            second_extension,
            "--with-builtin",
            "memory,developer,computercontroller",
            "-t",
            prompt_message
        ]
        result = subprocess.run(docker_runner, capture_output=True, text=True, check=True)
        return result.stdout 

    def send_local_ai_agent_prompt_message(self, goose_ai_prompt):
        """
        Use the 'goose run' command to send a prompt message to a local Goose AI Agent running on a local machine that is also running Ollama.
        """
        ollama_runner = f'echo "{goose_ai_prompt}" | goose run -i - && sleep 2'
        process = subprocess.Popen(ollama_runner, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        stdout, stderr = process.communicate()
        return stdout

    def send_local_ai_agent_instruction_file(self, instruction_file):
        """
        Use the 'goose run' command to send complex instructions through a markdown file to a local Goose AI Agent running on a local machine that is also running Ollama.
        """
        ollama_runner = [
            "goose", 
            "run", 
            "--instructions", 
            instruction_file
        ]
        result = subprocess.run(ollama_runner, capture_output=True, text=True, check=True)
        return result.stdout 

    ## The code below is disabled until the Codename Goose and Ollama developers figure out how to fix the following challenges with tools and toolshim...
    ## https://block.github.io/goose/blog/2025/03/31/goose-benchmark/#technical-challenges-with-open-models
    ## https://block.github.io/goose/blog/2025/04/11/finetuning-toolshim/#some-examples-of-model-specific-quirks-wrt-tool-calling
    ## https://github.com/MeetKai/functionary/issues/302#issuecomment-2650187280
    # def send_local_ai_agent_prompt_message(self, prompt_message, first_extension, second_extension):
    #     """
    #     Use the 'goose run' command to send a prompt message to a local Goose AI Agent running on a local machine that is also running Ollama.
    #     """
    #     ollama_runner = [
    #         "goose",
    #         "run",
    #         "--with-extension",
    #         first_extension,
    #         "--with-extension",
    #         second_extension,
    #         "--with-builtin",
    #         "memory,developer,computercontroller",
    #         "-t",
    #         prompt_message
    #     ]
    #     result = subprocess.run(ollama_runner, capture_output=True, text=True, check=True)
    #     return result.stdout 
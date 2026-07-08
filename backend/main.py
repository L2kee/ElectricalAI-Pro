"""
ElectricalAI Pro Backend

Main entry point for the backend application.
"""

from backend.ai.chat import AIChat
from backend.ai.prompts import SYSTEM_PROMPT


def main():
    print("⚡ ElectricalAI Pro Backend Started\n")

    chat = AIChat()

    messages = [
        {
            "role": "system",
            "content": SYSTEM_PROMPT,
        },
        {
            "role": "user",
            "content": "Explain Ohm's Law in simple terms.",
        },
    ]

    print("Waiting for NVIDIA AI...\n")

    answer = chat.ask(messages)

    print("AI Response:\n")
    print(answer)


if __name__ == "__main__":
    main()
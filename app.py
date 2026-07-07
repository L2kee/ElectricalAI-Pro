import os
from dotenv import load_dotenv
from openai import OpenAI

# Load the .env file
load_dotenv()

# Read the API key
api_key = os.getenv("NVIDIA_API_KEY")

# Connect to NVIDIA
client = OpenAI(
    base_url="https://integrate.api.nvidia.com/v1",
    api_key=api_key
)

# Ask NVIDIA a question
response = client.chat.completions.create(
    model="meta/llama-3.3-70b-instruct",
    messages=[
        {
            "role": "user",
            "content": "Explain Ohm's Law in simple terms."
        }
    ]
)

# Print the answer
print(response.choices[0].message.content)
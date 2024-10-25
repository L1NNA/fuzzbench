import ollama

def ask_gemma2b(question):
    response = ollama.generate(model='gemma:2b',
            prompt=question)
    if not response:
        return None
    if 'error' in response:
        return f"Error: {response['error']}"    
    print(response['response'])
    return response['response']

if __name__ == "__main__":
    question = f"Based on the following byte type seed, mutate a new byte type seed. Make sure the example is complete and valid. Only return the byte solution. 0x01 0x02 0x03 0x04 0xFF."
    answer = ask_gemma2b(question)
    print(f"Answer: {answer}")

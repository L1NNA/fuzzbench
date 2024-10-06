import redis
import time, os

MAX_QUEUE_SIZE = 30 

# Connect to Redis
redisdb = redis.Redis(host='localhost', port=6379, password='password', decode_responses=False)

# Consume messages from Redis
def consume_messages():

    message_count=0
    while True:
        try:
            message = redisdb.blpop('C2P', timeout=30)
        except:
            message = repr(message)
            print(f"Decoded consumed message: {message}")

        if message:
            # message is in tupple for blpop.
            print(f"Consumed: {message}")
            redisdb.ltrim('C2P', -MAX_QUEUE_SIZE, -1)
            message_count+=1

            # PONG
            redisdb.ltrim('P2C', -MAX_QUEUE_SIZE, -1)
            redisdb.rpush('P2C', message[1])

        else:
            print("Queue is empty after 30s timeout. Waiting...")

if __name__ == "__main__":
    print("Starting message consumer...")
    consume_messages() 
    
import redis
import time, os

REDIS_HOST = 'localhost'  # Change to your Redis server hostname or IP
REDIS_PORT = 6379          # Default Redis port
REDIS_PASSWORD = 'password'  # Password for the Redis ACL user
MAX_QUEUE_SIZE = 30 
PRODUCE_NAME='ToFuzzer'
CONSUMER_NAME='ToModel'
SET_NAME = 'message_set'

password=os.environ.get('REDIS_PASSWORD', REDIS_PASSWORD)
hostname=os.environ.get('REDIS_HOST', REDIS_HOST)

# Connect to Redis
redisdb = redis.Redis(host=hostname, port=REDIS_PORT, password=password, decode_responses=False)

# Consume messages from Redis
def consume_messages():

    message_count=0
    while True:
        # queue_length = redisdb.llen(CONSUMER_NAME)  # Check the number of messages in the queue
        # if queue_length == 0:
        #     print("No messages in the queue. Terminating consumer...")
        #     break
        try:
            message = redisdb.blpop(CONSUMER_NAME, timeout=30)
        except:
            message = repr(message)
            print(f"Decoded consumed message: {message}")

        if message:
            # message is in tupple for blpop.
            print(f"Consumed: {message}")
            # redisdb.rpush(PRODUCE_NAME, message[1])
            # Remove the message from the set as well
            # redisdb.srem(SET_NAME, message[1])
            redisdb.ltrim(CONSUMER_NAME, -MAX_QUEUE_SIZE, -1)
            message_count+=1

        else:
            print("Queue is empty after 30s timeout. Waiting...")

if __name__ == "__main__":
    print("Starting message consumer...")
    consume_messages() 
    
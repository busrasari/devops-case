#!/bin/bash

export $(grep -v '^#' .env | xargs)

REDIS_CONTAINER="redis_cache"
TEST_KEY="test_key"
TEST_VALUE="HalloRedis"

echo "Redis status check..."
if ! docker ps --format '{{.Names}}' | grep -q "$REDIS_CONTAINER"; then
  echo "ERROR: Redis container is not running!!"
  exit 1
fi

echo "Redis container is running. Testing connection..."

PING_RESULT=$(docker exec $REDIS_CONTAINER env REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli --no-auth-warning PING)
if [[ "$PING_RESULT" != "PONG" ]]; then
  echo "ERROR: Redis PING test failed!!"
  exit 1
fi

echo "Redis is responding to PING."

echo "Inserting test key-value pair into Redis..."
SET_RESULT=$(docker exec $REDIS_CONTAINER env REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli --no-auth-warning SET $TEST_KEY $TEST_VALUE)

if [[ "$SET_RESULT" != "OK" ]]; then
  echo "ERROR: Failed to insert test data into Redis!!"
  exit 1
fi

echo "Checking test data..."
GET_RESULT=$(docker exec $REDIS_CONTAINER env REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli --no-auth-warning GET $TEST_KEY)

if [[ "$GET_RESULT" == "$TEST_VALUE" ]]; then
  echo "Redis test successful! Retrieved value: $GET_RESULT"
else
  echo "ERROR: Retrieved value does not match expected!!"
  exit 1
fi

echo "Deleting test key..."
DEL_RESULT=$(docker exec $REDIS_CONTAINER env REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli --no-auth-warning DEL $TEST_KEY)

if [[ "$DEL_RESULT" -ne 1 ]]; then
  echo "ERROR: Test key deletion failed!!"
  exit 1
fi

echo "Redis test completed successfully."
#!/bin/bash

export $(grep -v '^#' .env | xargs)

POSTGRES_CONTAINER="postgres_db"
TEST_TABLE="test_table"

echo "PostgreSQL status check..."
if ! docker ps --format '{{.Names}}' | grep -q "$POSTGRES_CONTAINER"; then
  echo "ERROR: PostgreSQL container is not running!!"
  exit 1
fi

echo "PostgreSQL container is running. Testing connection..."

if ! docker exec $POSTGRES_CONTAINER pg_isready -U "$POSTGRES_USER"; then
  echo "ERROR: PostgreSQL is not ready!!"
  exit 1
fi

echo "PostgreSQL is ready."

echo "Creating test table ($TEST_TABLE) if it does not exist..."
docker exec $POSTGRES_CONTAINER psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
CREATE TABLE IF NOT EXISTS $TEST_TABLE (
    id SERIAL PRIMARY KEY,
    test_data TEXT NOT NULL
);"

echo "Inserting test data into $TEST_TABLE..."
docker exec $POSTGRES_CONTAINER psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
INSERT INTO $TEST_TABLE (test_data) VALUES ('Test entry 1'), ('Test entry 2');"

echo "Checking test data..."
RESULT=$(docker exec $POSTGRES_CONTAINER psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -A -c "SELECT COUNT(*) FROM $TEST_TABLE;" | tr -d '\n')

echo "Query output: $RESULT"

if [[ -z "$RESULT" || "$RESULT" -eq 0 ]]; then
  echo "Error: No data found in test table!"
  exit 1
else
  echo "PostgreSQL test successful! $RESULT test entries found."
fi

echo "Cleaning test table..."
docker exec $POSTGRES_CONTAINER psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
DROP TABLE $TEST_TABLE;"

echo "PostgreSQL test completed successfully."
#!/bin/bash

CONTAINER=$(docker ps | grep 'apiserver' | awk '{print $1}' | head -1)

if [ -z "$CONTAINER" ]; then
    echo "No running container found containing 'apiserver'"
    exit 1
fi

echo "Found container: $CONTAINER"
echo ""

DAGS=$(docker exec "$CONTAINER" airflow dags list | sort -u)

if [ -z "$DAGS" ]; then
    echo "No DAGs found containing 'ctrl'"
    exit 1
fi

echo "Found unique DAGs:"
echo "$DAGS"
echo ""

for DAG_ID in $DAGS; do
    echo "Triggering: $DAG_ID"
    docker exec "$CONTAINER" airflow dags trigger "$DAG_ID"

    if [ $? -eq 0 ]; then
        echo "Success: $DAG_ID"
    else
        echo "Failed: $DAG_ID"
    fi
    echo "---"
done

echo "Done!"

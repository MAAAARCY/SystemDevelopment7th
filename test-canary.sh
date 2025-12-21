#!/bin/bash

# Canary Release Traffic Distribution Test

echo "Canary Release Test"
echo "================================"
echo ""

# First, check if the service is responding
echo "Checking connection to http://localhost ..."
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" http://localhost)
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d':' -f2)

if [ "$HTTP_CODE" != "200" ]; then
    echo "ERROR: Cannot connect to http://localhost"
    echo "HTTP Code: $HTTP_CODE"
    echo ""
    echo "Please check:"
    echo "  1. Run: docker compose ps"
    echo "  2. Run: docker compose logs"
    echo "  3. Make sure port 80 is not in use"
    exit 1
fi

echo "Connection OK!"
echo ""

# Show a sample response for debugging
echo "Sample response content:"
echo "---"
curl -s http://localhost | grep -E "(STABLE|CANARY|status)" | head -3
echo "---"
echo ""

STABLE=0
CANARY=0
TOTAL=100

echo "Sending $TOTAL requests..."
echo ""

for i in $(seq 1 $TOTAL); do
    RESPONSE=$(curl -s http://localhost)
    
    if echo "$RESPONSE" | grep -q "STABLE"; then
        ((STABLE++))
    elif echo "$RESPONSE" | grep -q "CANARY"; then
        ((CANARY++))
    fi
    
    printf "\rProgress: %d/%d" $i $TOTAL
done

echo ""
echo ""
echo "================================"
echo "Results"
echo "================================"
echo ""
echo "  STABLE (v1.0.0): $STABLE hits ($((STABLE * 100 / TOTAL))%)"
echo "  CANARY (v2.0.0): $CANARY hits ($((CANARY * 100 / TOTAL))%)"
echo ""
echo "================================"
echo ""

if [ $STABLE -eq 0 ] && [ $CANARY -eq 0 ]; then
    echo "WARNING: No hits detected!"
    echo "The response may not contain 'STABLE' or 'CANARY' text."
    echo "Run: curl -s http://localhost"
    echo "to inspect the actual response."
elif [ $CANARY -ge 5 ] && [ $CANARY -le 20 ]; then
    echo "Canary release is working correctly!"
    echo "(Distribution is within expected range for 10% config)"
else
    echo "Note: Distribution is outside expected range"
    echo "(May need more samples or check configuration)"
fi
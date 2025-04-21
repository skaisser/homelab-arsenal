#!/bin/bash
subnet="10.0.1"
start=200
end=254

for i in $(seq $start $end); do
    ip="$subnet.$i"
    ping -c 1 -W 1 $ip &>/dev/null
    if [ $? -ne 0 ]; then
        echo "✅ IP $ip is available."
        exit 0
    else
        echo "❌ IP $ip is already in use."
    fi
done

echo "🚫 No free IPs found in range."
exit 1

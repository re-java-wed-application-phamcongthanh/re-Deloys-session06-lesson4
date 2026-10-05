#!/bin/bash
# Kịch bản giám sát hệ thống ghi log định kỳ mỗi 5 giây

while true; do
    echo "System time: $(date)" >> /tmp/monitor.log
    sleep 5
done

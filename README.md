## How to run

```bash
# start server
python demo_server.py

# spam
wrk -c 4 -d 1m -t 1 -s post.lua http://10.226.40.31:8001/api/detect -H "username: ewallet" -H "password: 123456" --latency --timeout 30s -- -d "request_id=12121212&card_type=identify&customer_id=12121212&app_id=asdasdasdasd" -f "file=text.png"
```

- run more than 1 thread will use seperate lua context per thread

## How to run

```bash
# start server
python demo_server.py

# spam
wrk -c 1 -d 1m -t 1 -s post.lua http://localhost:8000/api/detect -- -d "request_id=12121212&card_type=identify&customer_id=12121212&app_id=asdasdasdasd" -f cmt.jpg -f cmt2.jpg
```

- run more than 1 thread will use seperate lua context per thread

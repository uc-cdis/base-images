wsgi_app = "main:application"
bind = "0.0.0.0:8000"

workers = 5               # Adjust for CPUs (2x+1)
worker_class = "gthread"
threads = 4

timeout = 120
graceful_timeout = 30
backlog = 2048

max_requests = 1000
max_requests_jitter = 100

# PRELOAD DISABLED for safety
# preload_app = True

errorlog = "-"
loglevel = "error"        # Only essential errors
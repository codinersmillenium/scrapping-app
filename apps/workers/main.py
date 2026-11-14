import sys
from app.queue.consumer import WorkerConsumer
from app.server import start_resolver_server

def main():
    print("Starting Scrapping App Python Worker...")
    start_resolver_server(5005)
    consumer = WorkerConsumer()
    try:
        consumer.run()
    except KeyboardInterrupt:
        print("\nWorker interrupted by user. Shutting down cleanly.")
        sys.exit(0)

if __name__ == "__main__":
    main()

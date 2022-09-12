import requests
import sys

from ratelimit import limits, RateLimitException, sleep_and_retry
from concurrent.futures import ThreadPoolExecutor 
import threading
import signal 
from threading import Event
from time import sleep

def handler(signum, frame):
    print ('Time is up')
    exit(0)

counter = 0
lock = threading.Lock()


def manageConnections(event):
    while True:
        resp = requests.get('http://localhost:8080')
        lock.acquire()
        global counter
        counter = counter + 1
       
        lock.release()
        print(f"{counter}.{resp.text}", flush=True)   


values = range(20)
event = Event ()

def main():
    signal.signal(signal.SIGALRM, handler)
    signal.alarm(360)
    with ThreadPoolExecutor(max_workers=4) as executor:
        results = executor.map(manageConnections, values)
        # print(executor._max_workers)

if __name__ == '__main__':
   main()

# ONE_MINUTE = 60
# MAX_CALLS_PER_MINUTE = 30

# @sleep_and_retry
# @limits(calls=MAX_CALLS_PER_MINUTE, period=ONE_MINUTE)


# def manageConnections(event):
#     while True:
#         # if event.is_set():
#         #         lock.release
#         #         return
#         resp = requests.get('http://localhost:8080')
#         lock.acquire()
#         global counter
#         counter = counter + 1
       
#         lock.release()
#         print(f"{counter}.{resp.text}")   


# values = range(20)
# event = Event ()

# def main():
#     signal.signal(signal.SIGALRM, handler)
#     signal.alarm(300)
#     with ThreadPoolExecutor() as executor:
#         results = executor.map(manageConnections, values)
        # future = executor.submit(manageConnections, event)
    # sleep(60)    
    # future.cancel()
    # event.set()
    # # for result in results:
    # #     print(result)
    # print("\nFinal count of requests\n")
    # print(counter)



# with PoolExecutor(max_workers=3) as executor:
#     for _ in executor.map(manage_Connections, range(60)):
#         pass 



# import requests
# import time 
# import threading

# counter = 0
# lock = threading.Lock()

# def manageConnections(p):
#     for i in range(10):
#         start_time = time.time()
#         r = requests.get('http://localhost:8080', timeout=20.001)
#         end_time = time.time()
#         print(p)
#         print(r.text)
#         print(f'Total time to crunch prime numbers: {end_time - start_time:2f}s')
#         # time.sleep(1)
#         # print ("\n===========================================\n ")
#         # print(i)
#         #return r.text
#         lock.acquire()
#         global counter
#         counter = counter + 1
#         print("counter value")
#         print(counter)
#         lock.release()
        
#     return p

# from concurrent.futures import ThreadPoolExecutor
# from concurrent.futures import as_completed

# # values = [2,3,4,5]
# # def square(n):
# #    return n * n

# values = [1,2,3]

# def main():
#     with ThreadPoolExecutor(max_workers = 3) as executor:
#         results = executor.map(manageConnections, values)
#     for result in results:
#         print(result)
#     print("\nFinal count of requests\n")
#     print(counter)

# if __name__ == '__main__':
#    main()

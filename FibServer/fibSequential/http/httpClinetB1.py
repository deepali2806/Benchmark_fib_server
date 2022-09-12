import requests
import sys

from ratelimit import limits, RateLimitException, sleep_and_retry
from concurrent.futures import ThreadPoolExecutor
from concurrent.futures import wait
from concurrent.futures import FIRST_COMPLETED
import threading

counter = 0
lock = threading.Lock()


ONE_MINUTE = 60
MAX_CALLS_PER_MINUTE = 30




import requests
import time 
import threading

number_of_connections = int(sys.argv[1])
number_of_RequestsSent = int(sys.argv[2])

counter = 0
lock = threading.Lock()
total_response_time = 0
lock_time = threading.Lock()


def manageConnections(p):
    # for i in range(10):
    while True:
        start_time = time.time()
        lock.acquire()
        global counter
        if(counter >= number_of_RequestsSent):
            print("Number of Requests reached its limit")
            print(counter)
            lock.release()
            # break
            return p
        lock.release()
        r = requests.get('http://localhost:8080')
        end_time = time.time()
        print(p)
        print(r.text)
        # lock_time.acquire()
        # lock_time.release()
        print(f'Total Response time: {end_time - start_time:2f}s')
        print("counter value")
        lock.acquire()
        # global counter
        global total_response_time
        total_response_time = total_response_time + (end_time - start_time)
        print(f'Total Response time till now: {total_response_time}s')

        print(counter)
        counter = counter + 1 
        lock.release()
        print("====================================")

        
    return p

from concurrent.futures import ThreadPoolExecutor

# values = [2,3,4,5]
# def square(n):
#    return n * n

values = range(number_of_RequestsSent)

def main():
    # executor = ThreadPoolExecutor(4)
    # futures = [executor.submit(manageConnections, i) for i in values]
    with ThreadPoolExecutor(max_workers = number_of_connections) as executor:
        results = executor.map(manageConnections, values)
    # done, not_done = wait(futures, return_when=FIRST_COMPLETED)

   # executor.shutdown(wait=False, cancel_futures=True)
    # print(executor._max_workers)
    # for result in results:
    #     print(result)
    # manageConnections(values)
    print("\nFinal count of requests\n")
    print(counter)
    print("\nTotal Response time")
    print(total_response_time)

if __name__ == '__main__':
   main()

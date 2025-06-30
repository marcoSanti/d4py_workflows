import multiprocessing
import time

def task1():
    for i in range(5):
        print(f"Task 1 - iteration {i}")
        time.sleep(1)

def task2():
    for i in range(5):
        print(f"Task 2 - iteration {i}")
        time.sleep(1)

if __name__ == "__main__":
    # Create Process objects
    p1 = multiprocessing.Process(target=task1)
    p2 = multiprocessing.Process(target=task2)

    # Start the processes
    p1.start()
    p2.start()

    # Wait for both processes to complete
    p1.join()
    p2.join()

    print("Both tasks completed.")

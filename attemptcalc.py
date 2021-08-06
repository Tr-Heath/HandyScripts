#Calculate the number of attempts needed to reach a goal integer
#Each attempt has a success value increment and a failure value increment
import random

print("Welcome to the Attempt Calculator!")
advance = int(input("How far will the player advance with a success? "))
#failure = input("How far will the player advance with a failure? ")
target = int(input("What is the target? "))
chance = float(input("What is the chance for success? "))
#chanceCost = input("What is the cost to improve the chance by 3%? ")
#advCost = input("What is the cost to improve success advancement? ")
simRunCount = int(input("How many simulations would you like to run? "))
simsRun = 0
totalAttempts = 0

def runsimulation(simsRun):
    playervalue = 1
    attempts = 0
    while playervalue < target:
        if chance >= random.random():
            playervalue += advance
        else:
            playervalue += 1
        attempts += 1
    print(f"Simulation #{simsRun} took {attempts} attempt(s).")
    return attempts

while simsRun < simRunCount:
    totalAttempts += runsimulation(simsRun)
    simsRun += 1

print(f"Simulations are complete, the average number of attempts was {totalAttempts / simsRun} to attain a goal of {target}, with success granting {advance} advancement and a {chance*100}% chance of success.")
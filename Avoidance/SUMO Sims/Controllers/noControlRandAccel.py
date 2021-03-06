# -*- coding: utf-8 -*-
"""
Avoidance-less model intended for highway purposes.
It chooses a speed to reach, then stays there for a random time before moving again.
"""
import sys, os
sys.path.append(os.path.dirname(__file__)[:-len("/Controllers")])
from constants import * # sys.path is modified here
import numpy as np
import random

class NoControlRandAccel:
    speedMode = 6   #only physics checks
    laneChangeMode = 69 # no lane change for speed purposes
    
    def __init__(self, vehID, vParams = None, DELTAT=1.0):
        self.ID = vehID
        self.speed = None
        self.obstacles = {}
        if vParams == None:
            self.maxAccel = 1
        else:
            self.maxAccel = vParams[2]
        self.speedCommand = []
        self.DELTAT = DELTAT
        
    def updateSpeed(self, speed):
        self.speed = speed
    
    def nextStep(self, obstacles):        
        if len(self.speedCommand)==0:
            self.newSpeedCommand()        
        return self.speedCommand.pop()
        
    def newSpeedCommand(self):
        MPH2MS = .447
        chosenSpeed = truncatedNormal(self.speed/MPH2MS,5,55,85)*MPH2MS
        chosenAccel = random.uniform(0,self.maxAccel) * self.DELTAT
        meanTime = 2.0 # seconds
        chosenTime = np.floor(random.expovariate(1/meanTime) / self.DELTAT) + 1
        
        accelPeriod = np.arange(self.speed,chosenSpeed,
                                chosenAccel*np.sign(chosenSpeed-self.speed))
        if chosenTime <= len(accelPeriod):
            self.speedCommand = accelPeriod[0:chosenTime].tolist()
        else:
            steadyPeriod = [chosenSpeed]*(chosenTime-len(accelPeriod))
            self.speedCommand = accelPeriod.tolist() + steadyPeriod
        
def truncatedNormal(mean, sd, minvalue = 0, maxvalue = 30):
    answer = minvalue - 1
    counter = 10000
    while (answer < minvalue or answer > maxvalue) and counter > 0:
        answer = random.gauss(mean, sd)
        counter += -1
    if counter <= 0:   # failed to sample
        return (minvalue + maxvalue) / 2
    return answer
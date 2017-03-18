# README

## DESCRIPTION

Simulation of a 2-DOF planer arm, driven by 6-muscles. The model is a simplified version from "On control of reaching movements for musculo-skeletal redundent arm movement", (2009), Tahara et al. 

## FILES & CODE

### arm_model.m

This m-file/function is an Euler 1-step numerical simulation to the system. The user provides the current state in terms of theta and theta-dot values along with muscle activations and the time-step, and this function will output the state and the next time-step. 

System parameters are mostly hardcoded in this function. Where possible, these values can from the original paper. 

### test_arm_simulator.m

The m-file was written to simply test if the simulator and plotters were working. To run this, open it and hit run. 

### utilities/

This is a folder where utility functions are being kept. 

### utilities/arm_plotter.m

This is a function to plot the state of the system onto a Figure()

### utilities/initial_musc_lengths.m

This is a function to generate the initial muscle lengths. In order to simulate the muscles you have to know the muscles rest lengths. For example when I made this code I assumed that the theta values where all resting when at pi/2. I plugged these angles into this function, and it outputed the lengths of the muscles. 

## LANGUAGE 

The code herein is written for MATLAB. There is nothing special here, this should work with almost every version of MATALB. 

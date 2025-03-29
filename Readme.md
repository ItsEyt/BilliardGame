
# **Billiard game**

### **made by**: *Arad Eytan - 318764453*
---
### **how to run**
1. make sure you have [Squeak](https://squeak.org) installed
2. drag Billiard.st into the System Browser and choose fileIn entire file
3. run the following command `PoolTableMorph new`
4. have fun!
---
### **game instructions**
move the mouse around the playing table to decide the `angle` of the shot
> the angle is calculated based on the cue ball -> mouse pointer direction

hold<sup>*</sup> *left mouse button* to lock the angle, and start the `force` calculation
> the force is calculated based on the distance from the cue ball -> mouse pointer

move the mouse closer / further away from the cue ball to change the force of the shot

once ready, release *left mouse* button to shoot
	
	* optional - instead of holding the mouse button
	you can immediately click and release for an instant shot with the force at that range from the cue ball
score will be displayed in the `Transcript` window
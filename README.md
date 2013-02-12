TUIOTouchSynthesizer
====================


TUIO Touch Synthesizer is a crude iOS [TUIO](http://www.tuio.org/) client which receives cursors and converts them to touch events. This intended for use in installations and not App Store apps. 

For example you might hook up a TUIO touch screen to an iPad.

**TUIOTouchSynthesizer uses undocumented Apple APIs.**

The source includes a modified version of [tuioframework](http://code.google.com/p/tuioframework/), and uses Square’s [KIF iOS Integration Testing Framework](https://github.com/square/KIF/) both under the Apache 2.0 license.

Setup
------------
### Client
Clone the example project. [KIF](https://github.com/square/KIF/) is added as a submodule, so you’ll need to download that too;

    git clone https://github.com/simonheys/TUIOTouchSynthesizer.git
	cd TUIOTouchSynthesizer
	git submodule update --init --recursive

You can now open the XCode project, build and run Touch Synthesizer. By default this listens for connections on port `3333`

### Tracker

You'll also need something that can send TUIO cursors to the client. I've been testing with [TuioPad](http://code.google.com/p/tuiopad/). Set the host to  `YourClientIPAddress:3333`

You should now be able to pan and pinch on the Tracker to control the map on the Client.
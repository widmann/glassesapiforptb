# glassesapiforptb
Implementation of Tobii Glasses 2 API for Psychtoolbox on MATLAB/Octave

Core is the [tobiiGlassesAPI.m](https://github.com/widmann/glassesapiforptb/blob/main/tobiiGlassesAPI.m) function implementing the different REST API calls. tobiiGlassesAPI() expects and returns a structure ("Tobii" in the demo code) collecting all configuration parameters, the different project, participant, recording, status IDs and messages. Besides the Tobii structure tobiiGlassesAPI expects the call name and its required parameters as inputs.

There is no proper documentation yet (contributions welcome!). A demo experiment is provided showing how to put together and use the relevant parts.

* curl must be installed and the executable must be in path (MATLAB webread/webwrite is too sluggish for the purpose).
* Adapt hardcoded projID in demo_exp.m to a project existing on your SD card (hardcoded as it typically does not change during an experiment).
* Adapt serial port address in demo_block.m. Change Cfg.initioport to 0 in demo_exp.m in case no USB-serial port adapter is connected (API events only; not recommended if precise timing is required; combining TTL trigger timing and API event information is recommended).
* Adapt recording unit IP address in tobiiGlassesAPI.m (or better Tobii.URL parameter in the Tobii structure) in case of non-default IP address. 
* Call the demo_exp with an integer participant number.

See [Synching Tobii pro Glasses 2 via 3.5 mm jack](https://psychtoolbox.discourse.group/t/synching-tobii-pro-glasses-2-via-3-5-mm-jack/4715/) for reference and discussion.

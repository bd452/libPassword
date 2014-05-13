libPassword
===========
#### With a bit of help, this will hopefully get to the point that any passcode-related tweak will be possible in like 20 lines of code.
----------  

This is working, but there are a few issues. I can use all the help I can get, and I'm hoping this will become a public effort.

Things that are broken:

  - TouchID
  - Passcode Lock Delay
  - Switcher Animations (I've never had it happen but apparently it does)

Things that are working:

  - Unlock with/without the code
  - Lock with/without the code
  - Toggle the code On/Off

Things that need tested:

  - Detect when a certain password is entered (using the LibPassDelegate)
  - Accepting multiple passcodes (also using the LibPassDelegate)

To-do list:

  - Clean up code (a lot)
  - etc.

  

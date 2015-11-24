Usage
=====

At the moment, the only way to you can start the client is by providing your username, OAuth code, and a (optional) list of channels to join after login:
```
./twirc test_username oauth:12345 channel1 channel2...
```

Commands
========

After you login, there are several commands available for use:

Name     | Arguments        | Description
-------- | ---------------- | -----------
join     | channel(s)       | Joins the specified channels.
leave    | channel(s)       | Leaves the specified channels.
send     | channel, message | Sends a message to the specified channel.
mods     | channel          | Prints a list of moderators connected to the specified channel.
channels | none             | Prints a list of all currently connected channels.
leaveall | none             | Leaves all currently connected channels.

Settings
========

You can change various aspects of the client by creating a file named ```settings.cfg``` in the root directory. Settings are separated by lines, and the value of each setting is separated by a colon. Lines that begin with # are ignored.

A typical settings.cfg file may look like this:
```
c.red: magenta
#c.white: red
c.yellow: cyan
```

**Colors**

To change a color used by the client for displaying things, create a setting with a name that begins with "c." and follows with the name of the color you want to change. The value is the color you want it replaced with. For example:
```
c.red: magenta
```
The example above will make Red be displayed as Magenta.

Here is the full list of colors you can use:
* White
* Green
* Cyan
* Magenta
* Red
* Yellow

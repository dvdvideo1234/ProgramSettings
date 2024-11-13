--[[--
  Use this file to specify **System** preferences.
  Review [examples](+D:\LuaIDE\cfg\user-sample.lua) or check [online documentation](http://studio.zerobrane.com/documentation.html) for details.
--]]--

-- to have 4 spaces when TAB is used in the editor
editor.tabwidth = 2

-- to have TABs stored in the file (to allow mixing tabs and spaces)
editor.usetabs = false

-- to disable wrapping of long lines in the editor
editor.usewrap = false

-- to automatically open files requested during debugging
editor.autoactivate = true

-- to specify a default EOL encoding to be used for new files:
-- `wxstc.wxSTC_EOL_CRLF` or `wxstc.wxSTC_EOL_LF`;
-- `nil` means OS default: CRLF on Windows and LF on Linux/Unix and OSX.
-- (OSX had CRLF as a default until v0.36, which fixed it).
editor.defaulteol = wxstc.wxSTC_EOL_LF

-- to change font size to 12
editor.fontsize = 12 -- this is mapped to ide.config.editor.fontsize
editor.fontname = "Courier New"
filehistorylength = 20 -- this is mapped to ide.config.filehistorylength

-- to turn dynamic words on and to start suggestions after 4 characters
acandtip.nodynwords = false
acandtip.startat = 4

-- to specify language to use in the IDE (requires a file in cfg/i18n folder)
language = "en"

-- to specify full path to love2d *executable*; this is only needed
-- if the game folder and the executable are NOT in the same folder.
path.love2d = "D:/Programs/LOVE"

-- to specify full path to lua interpreter if you need to use your own version
path.lua = 'D:/Programs/Lua/lua/bin'

-- Black pretty interface
styles = loadfile('cfg/tomorrow.lua')('TomorrowNightBright')
stylesoutshell = styles -- apply the same scheme to Output/Console windows
styles.auxwindow = styles.text -- apply text colors to auxiliary windows
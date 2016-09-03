package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

require("./bot/utils")

local f = assert(io.popen('/usr/bin/git describe --tags', 'r'))
VERSION = assert(f:read('*a'))
f:close()

-- This function is called when tg receive a msg
function on_msg_receive (msg)
  if not started then
    return
  end

  msg = backward_msg_format(msg)

  local receiver = get_receiver(msg)
  print(receiver)
  --vardump(msg)
  --vardump(msg)
  msg = pre_process_service_msg(msg)
  if msg_valid(msg) then
    msg = pre_process_msg(msg)
    if msg then
      match_plugins(msg)
      if redis:get("bot:markread") then
        if redis:get("bot:markread") == "on" then
          mark_read(receiver, ok_cb, false)
        end
      end
    end
  end
end

function ok_cb(extra, success, result)

end

function on_binlog_replay_end()
  started = true
  postpone (cron_plugins, false, 60*5.0)
  -- See plugins/isup.lua as an example for cron

  _config = load_config()

  -- load plugins
  plugins = {}
  load_plugins()
end

function msg_valid(msg)
  -- Don't process outgoing messages
  if msg.out then
    print('\27[36mNot valid: msg from us\27[39m')
    return false
  end

  -- Before bot was started
  if msg.date < os.time() - 5 then
    print('\27[36mNot valid: old msg\27[39m')
    return false
  end

  if msg.unread == 0 then
    print('\27[36mNot valid: readed\27[39m')
    return false
  end

  if not msg.to.id then
    print('\27[36mNot valid: To id not provided\27[39m')
    return false
  end

  if not msg.from.id then
    print('\27[36mNot valid: From id not provided\27[39m')
    return false
  end

  if msg.from.id == our_id then
    print('\27[36mNot valid: Msg from our id\27[39m')
    return false
  end

  if msg.to.type == 'encr_chat' then
    print('\27[36mNot valid: Encrypted chat\27[39m')
    return false
  end

  if msg.from.id == 777000 then
    --send_large_msg(*group id*, msg.text) *login code will be sent to GroupID*
    return false
  end

  return true
end

--
function pre_process_service_msg(msg)
   if msg.service then
      local action = msg.action or {type=""}
      -- Double ! to discriminate of normal actions
      msg.text = "!!tgservice " .. action.type

      -- wipe the data to allow the bot to read service messages
      if msg.out then
         msg.out = false
      end
      if msg.from.id == our_id then
         msg.from.id = 0
      end
   end
   return msg
end

-- Apply plugin.pre_process function
function pre_process_msg(msg)
  for name,plugin in pairs(plugins) do
    if plugin.pre_process and msg then
      print('Preprocess', name)
      msg = plugin.pre_process(msg)
    end
  end
  return msg
end

-- Go over enabled plugins patterns.
function match_plugins(msg)
  for name, plugin in pairs(plugins) do
    match_plugin(plugin, name, msg)
  end
end

-- Check if plugin is on _config.disabled_plugin_on_chat table
local function is_plugin_disabled_on_chat(plugin_name, receiver)
  local disabled_chats = _config.disabled_plugin_on_chat
  -- Table exists and chat has disabled plugins
  if disabled_chats and disabled_chats[receiver] then
    -- Checks if plugin is disabled on this chat
    for disabled_plugin,disabled in pairs(disabled_chats[receiver]) do
      if disabled_plugin == plugin_name and disabled then
        local warning = 'Plugin '..disabled_plugin..' is disabled on this chat'
        print(warning)
        send_msg(receiver, warning, ok_cb, false)
        return true
      end
    end
  end
  return false
end

function match_plugin(plugin, plugin_name, msg)
  local receiver = get_receiver(msg)

  -- Go over patterns. If one matches it's enough.
  for k, pattern in pairs(plugin.patterns) do
    local matches = match_pattern(pattern, msg.text)
    if matches then
      print("msg matches: ", pattern)

      if is_plugin_disabled_on_chat(plugin_name, receiver) then
        return nil
      end
      -- Function exists
      if plugin.run then
        -- If plugin is for privileged users only
        if not warns_user_not_allowed(plugin, msg) then
          local result = plugin.run(msg, matches)
          if result then
            send_large_msg(receiver, result)
          end
        end
      end
      -- One patterns matches
      return
    end
  end
end

-- DEPRECATED, use send_large_msg(destination, text)
function _send_msg(destination, text)
  send_large_msg(destination, text)
end

-- Save the content of _config to config.lua
function save_config( )
  serialize_to_file(_config, './data/config.lua')
  print ('saved config into ./data/config.lua')
end

-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config( )
  local f = io.open('./data/config.lua', "r")
  -- If config.lua doesn't exist
  if not f then
    print ("Created new config file: data/config.lua")
    create_config()
  else
    f:close()
  end
  local config = loadfile ("./data/config.lua")()
  for v,user in pairs(config.sudo_users) do
    print("Sudo user: " .. user)
  end
  return config
end

-- Create a basic config.json file and saves it.
function create_config( )
  -- A simple config with basic plugins and ourselves as privileged user
  config = {
    enabled_plugins = {
	"admin",
    "onservice",
    "inrealm",
    "ingroup",
    "inpm",
    "banhammer",
    "stats",
    "anti_spam",
    "owners",
    "arabic_lock",
    "set",
    "get",
    "broadcast",
    "invite",
    "all",
    "rmsg",
    "lock_fosh",
    "lock_username",
    "lock_tag",
    "lock_fwd",
    "lock_reply",
    "lock_operator",
    "lock_media",
    "lock_english",
    "lock_emoji",
    "lock_join",
    "leave_ban",
    "plugins",
    "echo",
    "tex",
    "salam",
    "fohsh",
    "getplug",
    "share",
    "feedback",
    "qr",
    "google",
    "shortlink",
    "dellall",
	"supergroup",
	"whitelist",
	"msg_checks"
    },
    sudo_users = {160149610,tonumber(our_id)},--Sudo users
    moderation = {data = 'data/moderation.json'},
    about_text = [[
    ℹ️ آی منیجر

Github.com/MobinDehghani/iManager

1⃣ اوپن سورس
2⃣ کاملا فارسی و مفهوم
3⃣ پرسرعت و بدون خاموشی
4⃣ قفل های متفاوت و جدید
5⃣ آپدیت هفتگی و ماهانه
و...

👤 توسعه دهندگان :

@MobinDev - توسعه دهنده و مدیر
@Sudo1 - مدیر و پلاگین نویس

🙏 ارادمتند ، مدیریت آی منیجر
]],
    help_text_realm = [[

    Relam Bot Text 

]],
    help_text = [[
📃 دستورات مدیریتی روبات

🏳 اخراج از گروه (ریپلی) :
!kick @MobinDev

🏴 انسداد از ورود به گروه :
!ban @MobinDev

🚩 رفع انسداد ورود :
!unban @MobinDev

🤔 اطلاعات اکانت :
!who [ آیدی عددی ]

👥 نمایش مدیران گروه :
!modlist

🔺 ارتقاع مقام :
/promote @MobinDev

🔻 انزال مقام :
/demote @MobinDev

📜 نمایش توضیحات گروه :
!about

📜 تنظیم توضیحات گروه :
!setabout [ متن توضیحات  ]

🖼 تنظیم عکس گروه :
!setphoto

🗒تنظیم نام گروه :
!setname [ نام ]

📖 مشاهد قوانین گروه :
!rules

📖 تنظیم قوانین گروه :
!setrules [ متن قوانین ]

📋 نمایش اطلاعات شما ؛
!id

📝 نمایش راهنما (همین متن) :
!help

⚙ نمایش تنظیمات :
!settings

🔇 بیصدا کردن :
!mute - all - audio - gifs...

🔊 صدا دار کردن :
!unmute - all - audio - gifs...

📢 نمایش لیست بیصدا ها :
!mutelist

🔕 بیصدا کردن یک فرد :
!muteuser @MobinDev

🔔 صدا دار کردن فرد - دوباره :
!muteuser @MobinDev

📎 ساخت لینک جدید :
!newlink

📎 نمایش لینک گروه :
!link

📍آونر کردن (ریپلای) :
!setowner

📍نمایش آونر های گروه :
!owner

🎛 تنظیم حساسیت :
 !setflood [عدد]

💾 ذخیره متن :
!save [متن] [نام]

📄 نمایش متن ذخیره :
!get [نام]

🔃پاکسازی :
!clean - rules - modlist

⚡️ پاک کردن پیام ها :
!rmsg [عدد]

🗣 تکرار متن شما :
!echo [متن]

📱شماره روبات :
!share

🖍 زیبا نویسی متن :
!tex [متن]

🔍 جستجو در گوگل :
!google [متن]

📎 کوتاه کردن لینک :
!shortlink [لینک]

🚏 ارسال پیام به پشتیبانی :
!feedback [متن]

🔲 ساخت کیو آر کد :
!qr [متن]

📣 نمایش اطلاعات :
!res @MobinDev

📚 لیست افراد مسدود :
!banlist

___________________________

⚠️ میتوانید از # و / استفاده کنید
⚠️ تنها آنور ها میتوانند روبات اد کنند
⚠️ تنها مدیران میتوانند مسدود کنند

___________________________
]],
	help_text_super =[[
SuperGroup Commands:

!info
Displays general info about the SuperGroup

!admins
Returns SuperGroup admins list

!owner
Returns group owner

!modlist
Returns Moderators list

!bots
Lists bots in SuperGroup

!who
Lists all users in SuperGroup

!block
Kicks a user from SuperGroup
*Adds user to blocked list*

!ban
Bans user from the SuperGroup

!unban
Unbans user from the SuperGroup

!id
Return SuperGroup ID or user id
*For userID's: !id @username or reply !id*

!id from
Get ID of user message is forwarded from

!kickme
Kicks user from SuperGroup
*Must be unblocked by owner or use join by pm to return*

!setowner
Sets the SuperGroup owner

!promote [username|id]
Promote a SuperGroup moderator

!demote [username|id]
Demote a SuperGroup moderator

!setname
Sets the chat name

!setphoto
Sets the chat photo

!setrules
Sets the chat rules

!setabout
Sets the about section in chat info(members list)

!save [value] <text>
Sets extra info for chat

!get [value]
Retrieves extra info for chat by value

!newlink
Generates a new group link

!link
Retireives the group link

!rules
Retrieves the chat rules

!lock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict]
Lock group settings
*rtl: Delete msg if Right To Left Char. is in name*
*strict: enable strict settings enforcement (violating user will be kicked)*

!unlock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict]
Unlock group settings
*rtl: Delete msg if Right To Left Char. is in name*
*strict: disable strict settings enforcement (violating user will not be kicked)*

!mute [all|audio|gifs|photo|video|service]
mute group message types
*A "muted" message type is auto-deleted if posted

!unmute [all|audio|gifs|photo|video|service]
Unmute group message types
*A "unmuted" message type is not auto-deleted if posted

!setflood [value]
Set [value] as flood sensitivity

!settings
Returns chat settings

!muteslist
Returns mutes for chat

!muteuser [username]
Mute a user in chat
*If a muted user posts a message, the message is deleted automaically
*only owners can mute | mods and owners can unmute

!mutelist
Returns list of muted users in chat

!banlist
Returns SuperGroup ban list

!clean [rules|about|modlist|mutelist]

!del
Deletes a message by reply

!public [yes|no]
Set chat visibility in pm !chats or !chatlist commands

!res [username]
Returns users name and id by username


!log
Returns group logs
*Search for kick reasons using [#RTL|#spam|#lockmember]

**You can use "#", "!", or "/" to begin all commands

*Only owner can add members to SuperGroup
(use invite link to invite)

*Only moderators and owner can use block, ban, unban, newlink, link, setphoto, setname, lock, unlock, setrules, setabout and settings commands

*Only owner can use res, setowner, promote, demote, and log commands

]],
  }
  serialize_to_file(config, './data/config.lua')
  print('saved config into ./data/config.lua')
end

function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)
  --vardump (chat)
end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

-- Enable plugins in config.json
function load_plugins()
  for k, v in pairs(_config.enabled_plugins) do
    print("بارگزاری پلاگین", v)

    local ok, err =  pcall(function()
      local t = loadfile("plugins/"..v..'.lua')()
      plugins[v] = t
    end)

    if not ok then
      print('\27[31mError loading plugin '..v..'\27[39m')
	  print(tostring(io.popen("lua plugins/"..v..".lua"):read('*all')))
      print('\27[31m'..err..'\27[39m')
    end

  end
end

-- custom add
function load_data(filename)

	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)

	return data

end

function save_data(filename, data)

	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()

end


-- Call and postpone execution for cron plugins
function cron_plugins()

  for name, plugin in pairs(plugins) do
    -- Only plugins with cron function
    if plugin.cron ~= nil then
      plugin.cron()
    end
  end

  -- Called again in 2 mins
  postpone (cron_plugins, false, 120)
end

-- Start and load values
our_id = 0
now = os.time()
math.randomseed(now)
started = false

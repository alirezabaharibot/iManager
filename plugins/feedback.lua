do

 function run(msg, matches)
 local ch = 'chat#id'..msg.to.id
 local fuse = '📌 #فیدبک جدید\n\n👤 نام کاربر : ' .. msg.from.print_name .. '\n\n👤 نام کاربری : @' .. msg.from.username ..'\n\n👤 کد کاربر : ' .. msg.from.id ..'\n\n👤 کد گروه : '..msg.to.id.. '\n\n📝 متن پیام :\n\n' .. matches[1]
 local fuses = '!printf user#id' .. msg.from.id


   local text = matches[1]
   local chat = "chat#id"..1079090828

  local sends = send_msg(chat, fuse, ok_cb, false)
  return 'فیدبک شما با موفقیت ارسال شد ✔️'

 end
 end
 return {

  description = "Feedback",

  usage = "feedback: Send A Message To Admins.",
  patterns = {
  "^[!/#][Ff]eedback (.*)$",
  "^فید بک (.*)$"
  
  },
  run = run
}

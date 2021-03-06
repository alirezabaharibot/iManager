local function run(msg, matches)
    if is_momod(msg) then
        return
    end
    local data = load_data(_config.moderation.data)
    if data[tostring(msg.to.id)] then
        if data[tostring(msg.to.id)]['settings'] then
            if data[tostring(msg.to.id)]['settings']['fosh'] then
                lock_fosh = data[tostring(msg.to.id)]['settings']['fosh']
            end
        end
    end
    local chat = get_receiver(msg)
    local user = "user#id"..msg.from.id
    if lock_fosh == "yes" then
       delete_msg(msg.id, ok_cb, true)
    end
end
 
return {
  patterns = {
    "(ک*س)$",
    "کیر",
	"کص",
	"دیوث",
	"siktir",
	"sik",
        "کس ننت",
	"کص ننت",
	"ک*ص",
	"کونی",
        "kir",
	"kos",
	"kiri",
	"koni",
	"kooni",
	"کون",
	"کونی",
	"بسیک",
	"سیک کن",
	"کس نگو",
	"کص نگو",
	"بیشرف",
	"bisharaf",
	"بیناموس",
	"بی ناموس",
	"بکنمت",
	"مادر قحبه",
	"مادر کونی",
	"گوساله",
	"مادر جنده",
	"سیکتیر",
  },
  run = run
}




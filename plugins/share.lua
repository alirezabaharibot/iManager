do

function run(msg, matches)
send_contact(get_receiver(msg), "+79296824512", "iManager", "Bot", ok_cb, false)
end

return {
patterns = {
"^[!/#]share$"

},
run = run
}

end

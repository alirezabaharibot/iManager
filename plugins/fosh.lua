
do

function run(msg, matches)
  return "کـس نـنـت " .. matches[1]
end

return {
    patterns = {
    "^فحش بده به (.*)$",
    "^[Ff]osh [Bb]ede [Bb]e (.*)$",
  }, 
  run = run 
}

end

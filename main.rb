require 'discordrb'
require 'json'
config = JSON.parse(File.read('config.json'))
filename = 'database.json'
if (File.exists?(filename))
  file = File.read(filename)
else
  File.new('database.json', "w+")
  File.write(filename, JSON.dump({'useless': true}))
  file = File.read(filename)
end
data = JSON.parse(file)
prefix_event = proc do |message|
    if (data[message.server.id])
        prefix = data[message.server.id][:prefix] 
    else
        prefix = config['prefix']
    end
    message.content[prefix.size..] if message.content.start_with?(prefix)
end

bot = Discordrb::Commands::CommandBot.new token: config['token'], prefix: prefix_event, ignore_bots: true
bot.ready() do |event|
    puts "#{event.bot.profile.username}##{event.bot.profile.discriminator} is online!"
    puts "-----------------------"
    puts "ID: #{event.bot.profile.id}"
    puts "------------------------"
    puts "Server count: #{event.bot.servers.length}"
    event.bot.playing = "with ruby | #{event.bot.servers.length} server(s)"
end
bot.command(:ping, description: "Gets the bot ping", usage: 'ping', min_args: 0) do |event| 
    msg = event.respond "Pong!"
    msg.edit "Pong! My ping is #{(Time.now - event.timestamp).round()}ms"
end

bot.command(:setprefix, description: "Set a custom prefix for your server", usage: 'setprefix <prefix>', min_args: 1, max_args: 1) do |event, *prefix|
    if (data[event.message.server.id])
        data[event.message.server.id][:prefix] = prefix[0]
    else
        data[event.message.server.id] = {'prefix': prefix[0]}
    end
    File.write(filename, JSON.dump(data))
    event.respond "The server prefix is now `#{prefix[0]}`"
end
bot.run 
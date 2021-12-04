extends Node


var twitch: Gift = null

# Const variables

const MODERATORS: Array = [
	"b33bytes",
	"deschainxiv",
	"incompetent_ian",
	"velopman",
	"Liioni",
	"TheYagich",
]


# Private variables

var __players = []


# Lifecycle methods

func _process(delta: float) -> void:
	if self.twitch == null:
		self.__start_client()

	self.twitch.process(delta)


# Private methods

func __chat_message(sender : SenderData, message: String, channel: String) -> void:
	message = message.strip_edges()

	if message[0] == '!':
		self.__command(sender, message)


func __command(sender: SenderData, message: String) -> void:
	var command = message.split(" ", 1)[0].to_lower()

	var username: String = sender.user
	var player: int = self.__players.find(username)
	if player == -1:
		if self.__players.size() < 4:
			player = self.__players.size()
			self.__players.append(username)

			var identifier: String = "twitch_%d" % (player + 1)
			Event.emit_signal("twitch_join", identifier, username)
		else:
			return

	var identifier: String = "twitch_%d" % (player + 1)
	print(identifier)
	Event.emit_signal("twitch_input", identifier, command)


func __start_client() -> void:
	self.twitch = Gift.new()

	var channel = OS.get_environment("VELOPBOT_CHANNEL")
	var token = OS.get_environment("VELOPBOT_TOKEN")

	self.twitch.connect("chat_message", self, "__chat_message")

	self.twitch.connect_to_twitch()
	yield(self.twitch, "twitch_connected")

	self.twitch.authenticate_oauth("TheYagich", token)
	if(yield(twitch, "login_attempt") == false):
		print("Invalid token.")
		return
	self.twitch.join_channel(channel)

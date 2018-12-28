#!/usr/bin/env ruby
# encoding=utf-8
# Purpose : A simple bot that kills the bot
# Author  : Ky-Anh Huynh
# Date    : Early morning 2017 Nov 10th

# https://github.com/atipugin/telegram-bot-ruby
require 'telegram/bot'
require 'to_regexp'
require 'time'

require File.join(File.dirname(__FILE__), "reg.rb")
include Avn::Filter

TOKEN_BOT = ENV["TELEGRAM_BOT_TOKEN"]

# White channels allow mod to use `/reload` command
WHITE_CHANNELS = %w{}
CHANNEL_ID_LINUXVN_LOGS = ENV["CHANNEL_ID_LINUXVN_LOGS"]

SETTINGS = {records: {}, max_badwords: 5, regexps: []}

def log(msg, args)
  if msg
    STDERR.puts "#{Time.now.utc.iso8601}: #{msg.chat.id}/#{msg.from.id}@#{msg.from.username}: #{args}"
  else
    STDERR.puts "#{Time.now.utc.iso8601}: system/000@system: #{args}"
  end
end

# Reset all :records stored in `SETTINGS`. This is also invoked
# when the bot starts.
def reload!(msg)
  SETTINGS[:records] = {}
  SETTINGS[:regexps] = Avn::Filter::build
  log(msg, "REL #{SETTINGS[:regexps]}")
end

def act_reload(bot, msg)
  if msg.text == "/reload"
    if WHITE_CHANNELS.include?(msg.chat.id.to_s)
      reload!(msg)
    end
    return true
  end

  return false
end

def _act_restrict(bot, msg, notes, expiration = 86400)
  mod_logs = "#{<<EOF}"
Action: RESTRICT_USER
User (Id/Name): #{msg.from.id} @#{msg.from.username}
Group: #{msg.chat.id}
Reason: #{notes}
Expiration: #{expiration} seconds
EOF

  begin
    bot.api.send_message(chat_id: CHANNEL_ID_LINUXVN_LOGS, text: mod_logs)
    log(msg, "RES #{msg.from.id}, notes: #{notes}")

    bot.api.restrictChatMember(
      chat_id: msg.chat.id,
      user_id: msg.from.id,
      until_date: Time.now.to_i + expiration,
      can_send_messages: false,
      can_send_media_messages: false,
      can_send_other_messages: false,
      can_add_web_page_previews: false
    )
  rescue => e
    log(msg, "ERR #{e}")
  end

  # FIXME: Always return false here...
  return false
end

def act_blockme(bot, msg)
  found = msg.text.to_s.strip.match(%r{^//blockme (\d+)$})
  return false if not found

  expiration = found[1].to_i

  if expiration >= 120
    _act_restrict(bot, msg, "BLO #{expiration}", expiration)
  end

  return true
end

def act_filter(bot, msg)
  found = Avn::Filter.match(msg.text)
  return false if not found

  begin
    bot.api.deleteMessage(chat_id: msg.chat.id, message_id: msg.message_id)

    mod_logs = "#{<<EOF}"
Action: DELETE
User (Id/Name): #{msg.from.id} @#{msg.from.username}
Msg: #{msg.text}
Group: #{msg.chat.id}
Reason: Filtered by Lauxanh
EOF

    bot.api.send_message(chat_id: CHANNEL_ID_LINUXVN_LOGS, text: mod_logs)
    log(msg, "DEL #{msg.text}, reason: #{found[:reg].inspect}")

    # Logging to Telegram Channel, and System Logs
    _user_id="#{msg.from.id}@#{msg.from.username}"

    SETTINGS[:records][_user_id] ||= 0
    SETTINGS[:records][_user_id] += 1

    if SETTINGS[:records][_user_id] > SETTINGS[:max_badwords]
      _act_restrict(bot, msg, "Quota reached (#{SETTINGS[:max_badwords]})", 86400)
      SETTINGS[:records][_user_id] = 0
    end
  rescue => e
    log(msg, "ERR #{e}")
  end

  return true
end

reload!(nil)

Telegram::Bot::Client.run(TOKEN_BOT) do |bot|
  bot.listen do |msg|
    act_blockme(bot, msg) \
    or act_reload(bot, msg) \
    or act_filter(bot, msg)
  end
end

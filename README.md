### Bot features

* `//blockme NUMBER_OF_SECONDS`:
  User can restrict themselves.
  `NUMBER_OF_SECONDS` should be `>= 120`
* `/reload`:
  Reload bot configuration. This feature is disabled now.
* `Badword filter`:
  Text message that contains some bad word from a list `badwords.txt`
  will be deleted and a customer user counter will be increased.
  User will be restricted 24 hours if the counter is `> 5`.

### Testing the bot

1. Create a supergroup (and an optional logging group, see below)
1. Add your testing bot
1. Allow your bot to delete message and ban user
1. Modify the list `badwords.txt`
1. Update `env.sh` (see example below)
1. Start the bot with the script `./start.sh`

### Sample env.sh

```
# avnbot
export TELEGRAM_BOT_TOKEN="495851205:yyy"
export CHANNEL_ID_LINUXVN_LOGS="-xx"
```

The bot will write log to a custom group. You can create new group and/or
use your testing group to get logs, then add the bot `@RawDataBot` to get
the group ID. Remember to remove `@RawDataBot` immediately.

TODO: `CHANNEL_ID_LINUXVN_LOGS` is default to current group.

### Unblock yourself

Wait for expiration of the restriction action,
or contact any administrator of the group.
(You can see them from the list of all group members.)

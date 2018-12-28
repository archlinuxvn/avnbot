### Bot features

* `//blockme NUMBER_OF_SECOND`:
  User can restrict themself.
  `NUMBER_OF_SECOND` should be `>= 120`
* `/reload`:
  Reload bot configuration. This feature is disabled now.
* `Badword filter`:
  Text message that contains some bad word from a list `badwords.txt`
  will be deleted and a customer user counter will be increased.
  User will be restricted 24 hours if the counter is `> 5`.

### Testing the bot

1. Create a supergroup
1. Add your testing bot
1. Allow your bot to delete message and ban user
1. Modify the list `badwords.txt`
1. Update `env.sh` (see example below)
1. Start the bot

### Sample env.sh

```
# avnbot
export TELEGRAM_BOT_TOKEN="495851205:yyy"
export CHANNEL_ID_LINUXVN_LOGS="-xx"
```

The bot will write log to custom group. You can create new group and/or
use your testing group to get logs, then add the bot `@RawDataBot` to get
the group ID. Remember to remove `@RawDataBot` immediately.

TODO: `CHANNEL_ID_LINUXVN_LOGS` is default to current group.

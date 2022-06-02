#!/bin/sh
#
# Toggle mute on specified audio source and synchronizes state of additional sources.
#

# Tool pactl prints localized messages. Changing language to English simplifies parsing output.
LANGUAGE=en_US
pactl_yes="yes"

# Sources configuration
main_source_index=0
# Indexes of additional sources. Their mute state will be synchronized with main source.
# Examples:
# additional_source_indexes=2
# additional_source_indexes="2 3 4"
additional_source_indexes=2

# Desktop notification configuration
notification_title="Microphone"
notification_message_muted="Microphone muted"
notification_message_not_muted="Microphone not muted"
notification_icon_muted="microphone-sensitivity-muted"
notification_icon_not_muted="microphone-sensitivity-high"
notification_expire_ms=1000

is_main_source_muted() {
  if pactl get-source-mute $main_source_index | grep -qi "$pactl_yes"; then
    return 0 # muted
  else
    return 1 # not muted
  fi
}

toggle_mute_state() {
  # Toggle mute state of main source
  if is_main_source_muted; then
    new_mute_state="false"
  else
    new_mute_state="true"
  fi

  pactl set-source-mute $main_source_index "$new_mute_state"

  # Synchronize mute state of additional sources
  for index in $additional_source_indexes; do
    pactl set-source-mute $index "$new_mute_state"
  done
}

show_desktop_notification() {
  if is_main_source_muted; then
    notification_message="$notification_message_muted"
    notification_icon="$notification_icon_muted"
  else
    notification_message="$notification_message_not_muted"
    notification_icon="$notification_icon_not_muted"
  fi

  notify-send \
    --urgency=low \
    --expire-time=$notification_expire_ms \
    --app-name="$notification_title" \
    --icon="$notification_icon" \
    "$notification_message"
}

toggle_mute_state
show_desktop_notification

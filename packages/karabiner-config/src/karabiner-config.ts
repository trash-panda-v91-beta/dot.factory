import {
  ifDevice,
  map,
  withModifier,
  layer,
  toApp,
  toKey,
  rule,
  writeToProfile,
  toKey,
} from 'karabiner.ts'

function main() {
  writeToProfile(
    'Default',
    [
      apps_launcher(),
      arrow_keys(),
      keyboard_apple(),
    ],
    {
      'basic.simultaneous_threshold_milliseconds': 50,
      'duo_layer.threshold_milliseconds': 50,
      'duo_layer.notification': true,
    },
  )
}

function arrow_keys() {
  return layer('⇥', 'Arrow keys').manipulators({
    h: toKey('←'),
    j: toKey('↓'),
    k: toKey('↑'),
    l: toKey('→'),
  })
}
function apps_launcher() {
  return rule('Launch Apps').manipulators([
    withModifier('⌥⌃⇧')({
      b: toApp('Zen'),
      c: toApp('Calendar'),
      e: toApp('Mail'),
      f: toApp('Finder'),
      s: toApp('Slack'),
      t: toApp('Ghostty'),
    }),
  ])
}


function keyboard_apple() {
  let ifAppleKeyboard = ifDevice({ vendor_id: 12951 }).unless() // Not Moonlander
  return rule('Apple Keyboard', ifAppleKeyboard).manipulators([
    map('‹⌘').to('‹⌘').toIfAlone('⎋'),
    map('›⇧').toMeh(),
    map('⇥').toHyper().toIfAlone('⇥'),
    map('⇪').to('‹⌃').toIfAlone('⇥', '‹⌘'),
  ])
}

main()

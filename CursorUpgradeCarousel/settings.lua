data:extend{
  {
    type = 'bool-setting',
    name = 'cuc-always-give-in-map-editor',
    setting_type = 'runtime-per-user',
    default_value = true,
    order = 'a'
  },
  {
    type = 'string-setting',
    name = 'cuc-custom-upgrade-registry',
    setting_type = 'runtime-per-user',
    default_value = '{[\'medium-electric-pole\'] = \'big-electric-pole\', [\'big-electric-pole\'] = \'substation\'}',
    order = 'b'
  },
}
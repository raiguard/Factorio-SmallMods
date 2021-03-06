data:extend{
  {
    type = 'bool-setting',
    name = 'cuc-spawn-items-when-cheating',
    setting_type = 'runtime-per-user',
    default_value = true,
    order = 'a'
  },
  {
    type = 'string-setting',
    name = 'cuc-custom-upgrade-registry',
    setting_type = 'runtime-per-user',
    default_value = '{"small-electric-pole": "medium-electric-pole", "medium-electric-pole": "big-electric-pole", "big-electric-pole": "substation"}',
    order = 'b'
  }
}
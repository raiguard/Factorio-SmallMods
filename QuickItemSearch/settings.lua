data:extend{
  {
    type = 'bool-setting',
    name = 'qis-search-inventory',
    setting_type = 'runtime-per-user',
    default_value = true,
    order = 'aa'
  },
  {
    type = 'bool-setting',
    name = 'qis-search-logistics',
    setting_type = 'runtime-per-user',
    default_value = true,
    order = 'ab'
  },
  {
    type = 'bool-setting',
    name = 'qis-search-unavailable',
    setting_type = 'runtime-per-user',
    default_value = false,
    order = 'ac'
  },
  {
    type = 'bool-setting',
    name = 'qis-search-hidden',
    setting_type = 'runtime-per-user',
    default_value = false,
    order = 'ad'
  },
  {
    type = 'bool-setting',
    name = 'qis-fuzzy-search',
    setting_type = 'runtime-per-user',
    default_value = false,
    order = 'ae'
  },
  {
    type = 'string-setting',
    name = 'qis-default-location',
    setting_type = 'runtime-per-user',
    allowed_values = {'mod gui', 'top', 'bottom', 'center'},
    default_value = 'mod gui',
    order = 'ba'
  },
  {
    type = 'string-setting',
    name = 'qis-editor-location',
    setting_type = 'runtime-per-user',
    allowed_values = {'mod gui', 'top', 'bottom', 'center'},
    default_value = 'bottom',
    order = 'bb'
  },
  {
    type = 'int-setting',
    name = 'qis-column-count',
    setting_type = 'runtime-per-user',
    default_value = 5,
    minimum_value = 5,
    order = 'ca'
  },
  {
    type = 'int-setting',
    name = 'qis-row-count',
    setting_type = 'runtime-per-user',
    default_value = 2,
    minimum_value = 1,
    order = 'cb'
  }
}
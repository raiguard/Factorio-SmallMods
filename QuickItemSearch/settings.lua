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
    type = 'bool-setting',
    name = 'qis-logistics-unique-only',
    setting_type = 'runtime-per-user',
    default_value = true,
    order = 'af'
  },
  {
    type = 'string-setting',
    name = 'qis-default-location',
    setting_type = 'runtime-per-user',
    allowed_values = {'mod gui', 'top', 'bottom', 'center'},
    default_value = 'center',
    order = 'ba'
  },
  {
    type = 'string-setting',
    name = 'qis-editor-location',
    setting_type = 'runtime-per-user',
    allowed_values = {'mod gui', 'top', 'bottom', 'center'},
    default_value = 'center',
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
    default_value = 4,
    minimum_value = 1,
    order = 'cb'
  }
}
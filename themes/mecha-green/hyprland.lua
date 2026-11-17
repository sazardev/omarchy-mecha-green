local active_border_color = { colors = { "rgba(f2c84bee)", "rgba(9dae5cee)", "rgba(f2c84bee)" }, angle = 45 }
local inactive_border_color = "rgba(737c58aa)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },
})

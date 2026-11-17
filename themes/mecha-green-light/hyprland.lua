local active_border_color = { colors = { "rgba(7d5200ee)", "rgba(4f6428ee)", "rgba(7d5200ee)" }, angle = 45 }
local inactive_border_color = "rgba(62684aaa)"

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
